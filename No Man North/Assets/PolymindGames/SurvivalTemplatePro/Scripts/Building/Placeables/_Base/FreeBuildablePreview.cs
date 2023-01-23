using UnityEngine;

namespace SurvivalTemplatePro.BuildingSystem
{
    public class FreeBuildablePreview : BuildablePreview, ISaveableComponent
    {
        private Buildable m_Buildable;


        public override void EnablePreview()
        {
            base.EnablePreview();

            m_Buildable.SetActivationState(BuildableActivationState.Preview);
            RegisterBuildable(m_Buildable);
        }

        public override void CancelPreview() => Destroy(gameObject);

        protected override void OnAllBuildablesComplete()
        {
            m_Buildable.SetActivationState(BuildableActivationState.Placed);
        }

        protected override void CalculateCenter(ref Vector3 center) => center = m_Buildable.transform.position;

        protected void Awake() => m_Buildable = GetComponent<Buildable>();

        protected override bool CanAddBuildMaterials(BuildingMaterialInfo matInfo)
        {
            // Check if there's any characters inside this preview.
            int colliderCount = Physics.OverlapBoxNonAlloc(
                m_Buildable.Bounds.center,
                m_Buildable.Bounds.extents,
                s_CollisionResults,
                m_Buildable.transform.rotation,
                PlaceableDatabase.GetCharacterMask(),
                QueryTriggerInteraction.Ignore);

            return colliderCount == 0;
        }

        #region Save & Load
        public override void LoadMembers(object[] members)
        {
            if ((bool)members[0])
            {
                EnablePreview();

                var buildRequirements = members[1] as BuildRequirement[];
                if (buildRequirements != null)
                    m_BuildableRequirements[m_Buildable] = buildRequirements;
            }
            else
                DisablePreview();
        }

        public override object[] SaveMembers()
        {
            var buildReq = m_BuildableRequirements != null ? m_BuildableRequirements[m_Buildable] : null;

            object[] members = new object[]
            {
                m_PreviewEnabled,
                buildReq
            };

            return members;
        }
        #endregion
    }
}