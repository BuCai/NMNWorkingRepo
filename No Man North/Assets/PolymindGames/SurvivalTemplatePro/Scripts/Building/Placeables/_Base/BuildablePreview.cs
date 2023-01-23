using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.BuildingSystem
{
    public abstract class BuildablePreview : MonoBehaviour, ISaveableComponent
    {
        public static List<BuildablePreview> AllPreviewsInScene = new List<BuildablePreview>();

        public event UnityAction<BuildablePreview> onMaterialAdded;
        public event UnityAction onBuildCompleted;

        public Vector3 PreviewCenter => m_PreviewCenter;
        public bool PreviewEnabled => m_PreviewEnabled;

        protected Vector3 m_PreviewCenter = Vector3.zero;
        protected bool m_PreviewEnabled = false;

        protected static Collider[] s_CollisionResults = new Collider[10];
        protected Dictionary<Buildable, BuildRequirement[]> m_BuildableRequirements;


        /// <summary>
        /// Converts all of the build requirements from all of the attached buildables to one list.
        /// Make sure to cache this list and not call this every frame as it can be relatively expensive.
        /// </summary>
        /// <returns></returns>
        public List<BuildRequirement> GetAllBuildRequirements()
        {
            if (m_BuildableRequirements == null)
                return null;

            var buildRequirements = new List<BuildRequirement>();

            foreach (var buildableReq in m_BuildableRequirements.Values)
            {
                foreach (var req in buildableReq)
                {
                    var newReq = GetRequirementWithId(buildRequirements, req.BuildingMaterialId);

                    if (newReq != null)
                    {
                        newReq.RequiredAmount += req.RequiredAmount;
                        newReq.CurrentAmount += req.CurrentAmount;
                    }
                    else
                    {
                        newReq = new BuildRequirement(req.BuildingMaterialId, req.RequiredAmount, req.CurrentAmount);
                        buildRequirements.Add(newReq);
                    }
                }
            }

            return buildRequirements;
        }

        public virtual void EnablePreview() => RegisterPreview(this);
        public virtual void DisablePreview() => UnregisterPreview(this);

        public virtual void CancelPreview() => Destroy(gameObject);

        public bool TryAddBuildingMaterial(BuildingMaterialInfo matInfo)
        {
            if (!CanAddBuildMaterials(matInfo))
                return false;

            foreach (var buildableReq in m_BuildableRequirements.Values)
            {
                var buildReq = GetRequirementWithId(buildableReq, matInfo.Id);

                if (buildReq != null && !buildReq.IsCompleted())
                {
                    buildReq.CurrentAmount++;
                    OnMaterialAdded(matInfo);

                    return true;
                }
            }

            return false;
        }

        protected virtual bool CanAddBuildMaterials(BuildingMaterialInfo matInfo) => true;

        protected void RegisterBuildable(Buildable buildable) 
        {
            if (m_BuildableRequirements == null)
                m_BuildableRequirements = new Dictionary<Buildable, BuildRequirement[]>();

            if (!m_BuildableRequirements.ContainsKey(buildable))
                m_BuildableRequirements.Add(buildable, GetBuildReqForBuildable(buildable));
        }

        protected void UnregisterBuildable(Buildable buildable)
        {
            if (m_BuildableRequirements == null)
                return;

            m_BuildableRequirements.Remove(buildable);
        }

        private BuildRequirement[] GetBuildReqForBuildable(Buildable buildable)
        {
            var buildReq = new BuildRequirement[buildable.BuildRequirements.Length];

            for (int i = 0; i < buildable.BuildRequirements.Length; i++)
            {
                var buildableReq = buildable.BuildRequirements[i];
                buildReq[i] = new BuildRequirement(buildableReq);
            }

            return buildReq;
        }

        protected virtual void OnMaterialAdded(BuildingMaterialInfo matInfo)
        {
            CalculateCenter(ref m_PreviewCenter);
            matInfo.UseSound.PlayAtPosition(transform.position);
            onMaterialAdded?.Invoke(this);

            bool allBuildablesComplete = true;

            // Itterate through all of the build requirements and check if all of them are completed.
            foreach (var buildableReq in m_BuildableRequirements)
            {
                bool buildComplete = AreRequirementsMet(buildableReq.Value);

                if (buildComplete)
                    OnBuildComplete(buildableReq.Key);

                allBuildablesComplete &= buildComplete;
            }

            if (allBuildablesComplete)
            {
                OnAllBuildablesComplete();
                DisablePreview();

                onBuildCompleted?.Invoke();
            }
        }

        protected virtual void OnBuildComplete(Buildable buildable) { }
        protected virtual void OnAllBuildablesComplete() { }
        protected virtual void CalculateCenter(ref Vector3 center) { }

        protected bool AreRequirementsMet(BuildRequirement[] buildReq)
        {
            bool buildComplete = true;

            for (int i = 0; i < buildReq.Length; i++)
            {
                if (!buildReq[i].IsCompleted())
                    buildComplete = false;
            }

            return buildComplete;
        }

        private void OnDestroy() => UnregisterPreview(this);

        private BuildRequirement GetRequirementWithId(IEnumerable<BuildRequirement> list, int materialId)
        {
            foreach (var req in list)
            {
                if (req.BuildingMaterialId == materialId)
                    return req;
            }

            return null;
        }

        // Enables and registers this preview as active.
        private static void RegisterPreview(BuildablePreview preview)
        {
            if (!AllPreviewsInScene.Contains(preview))
            {
                AllPreviewsInScene.Add(preview);

                preview.CalculateCenter(ref preview.m_PreviewCenter);
                preview.m_PreviewEnabled = true;
            }
        }

        // Disables and unregisters this preview from the active pool.
        private static void UnregisterPreview(BuildablePreview preview)
        {
            if (AllPreviewsInScene.Contains(preview))
            {
                AllPreviewsInScene.Remove(preview);
                preview.m_PreviewEnabled = false;
            }
        }

        #region Save & Load
        public virtual void LoadMembers(object[] members) { }
        public virtual object[] SaveMembers() => null;
        #endregion
    }
}