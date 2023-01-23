using UnityEngine;

namespace SurvivalTemplatePro.BuildingSystem
{
    public class StructurePreview : BuildablePreview
    {
        private StructureManager m_Structure;


        public override void CancelPreview()
        {
            int index = 0;

            var buildables = m_Structure.Buildables;

            while (index < m_BuildableRequirements.Count)
            {
                if (m_BuildableRequirements.TryGetValue(buildables[index], out var buildReq))
                {
                    if (!AreRequirementsMet(buildReq))
                    {
                        m_Structure.RemovePart(buildables[index]);
                        continue;
                    }
                }

                index++;
            }

            if (buildables.Count == 0)
                Destroy(gameObject);
            else
                DisablePreview();
        }

        protected override bool CanAddBuildMaterials(BuildingMaterialInfo matInfo)
        {
            // Check if there's any characters inside this structure preview.
            foreach (Buildable buildable in m_Structure.Buildables)
            {
                int colliderCount = Physics.OverlapBoxNonAlloc(
                    buildable.Bounds.center,
                    buildable.Bounds.extents,
                    s_CollisionResults,
                    buildable.transform.rotation,
                    PlaceableDatabase.GetCharacterMask(),
                    QueryTriggerInteraction.Ignore);

                if (colliderCount > 0)
                    return false;
            }

            return true;
        }

        protected override void OnBuildComplete(Buildable buildable) => buildable.SetActivationState(BuildableActivationState.Placed);
        protected override void OnAllBuildablesComplete() => m_Structure.PlayBuildEffects();

        protected override void CalculateCenter(ref Vector3 center)
        {
            center = Vector3.zero;

            for (int i = 0; i < m_Structure.Buildables.Count; i++)
                center += m_Structure.Buildables[i].transform.position;

            center /= m_Structure.Buildables.Count;
        }

        protected void Awake() => m_Structure = GetComponent<StructureManager>();

        private void Start()
        {
            if (m_PreviewEnabled)
            {
                foreach (var buildable in m_Structure.Buildables)
                    RegisterBuildable(buildable);
            }

            m_Structure.onPartAdded += RegisterBuildable;
            m_Structure.onPartRemoved += UnregisterBuildable;
        }

        #region Save & Load
        public override void LoadMembers(object[] members)
        {
            var buildRequirements = members[1] as BuildRequirement[][];
            var buildables = m_Structure.Buildables;

            for (int i = 0; i < buildables.Count; i++)
            {
                if (buildRequirements[i] != null)
                {
                    RegisterBuildable(buildables[i]);
                    m_BuildableRequirements[buildables[i]] = buildRequirements[i];
                }
            }

            if ((bool)members[0])
                EnablePreview();
        }

        public override object[] SaveMembers()
        {
            var buildRequirements = new BuildRequirement[m_Structure.Buildables.Count][];
            var buildables = m_Structure.Buildables;

            for (int i = 0; i < buildables.Count; i++)
            {
                if (m_BuildableRequirements.TryGetValue(buildables[i], out var req))
                    buildRequirements[i] = req;
            }

            object[] members = new object[]
            {
                m_PreviewEnabled,
                buildRequirements
            };

            return members;
        }
        #endregion
    }
}