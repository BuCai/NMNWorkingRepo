using SurvivalTemplatePro.MovementSystem;
using SurvivalTemplatePro.Surfaces;
using UnityEngine;

namespace SurvivalTemplatePro
{
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/audio#footsteps-manager-behaviour")]
    public class FootstepsManager : CharacterBehaviour
    {
        #region Internal
        [System.Serializable]
        private struct StateStepVolume
        {
            public MotionStateType StateType;

            [SerializeField, Range(0f, 2f)]
            public float Volume;
        }
        #endregion

        [Title("Raycast Settings")]

        [SerializeField]
        private LayerMask m_GroundMask;

        [SerializeField, Range(0.01f, 1f)]
        private float m_RaycastDistance = 0.3f;

        [SerializeField, Range(0.01f, 0.5f)]
        private float m_RaycastRadius = 0.3f;

        [Title("Fall Impact Thresholds")]

        [SerializeField, Range(0f, 25f)]
        [Tooltip("If the impact speed is higher than this threeshold, an effect will be played.")]
        private float m_FallImpactThreshold = 4f;

        [SerializeField, Range(0f, 25f)]
        [Tooltip("If the impact speed is at this threeshold, the fall impact effect audio will be at full effect.")]
        private float m_MaxFallImpactThreshold = 12f;

        [Title("Footsteps Volume")]

        [SerializeField]
        [ReorderableList(ListStyle.Round, elementLabel: "Motion")]
        private StateStepVolume[] m_VolumeMultipliers;

        private IMotionController m_Motion;


        public override void OnInitialized()
        {
            GetModule(out m_Motion);
            m_Motion.onStepCycleEnded += PlayFootstepEffect;

            GetModule<ICharacterMotor>().onFallImpact += PlayFallImpactEffects;
        }

        public void PlayFootstepEffect()
        {
            MotionStateType stateType = m_Motion.ActiveStateType;

            if (CheckGround(out RaycastHit hitInfo))
                SurfaceManager.SpawnEffect(hitInfo, GetEffectType(stateType), GetFootStepVolume(stateType));
        }

        private SurfaceEffects GetEffectType(MotionStateType stateType)
        {
            bool isRunning = stateType == MotionStateType.Run;
            SurfaceEffects footstepType = isRunning ? SurfaceEffects.HardFootstep : SurfaceEffects.SoftFootstep;

            return footstepType;
        }

        private float GetFootStepVolume(MotionStateType stateType) 
        {
            for (int i = 0; i < m_VolumeMultipliers.Length; i++)
            {
                if (stateType == m_VolumeMultipliers[i].StateType)
                    return m_VolumeMultipliers[i].Volume;
            }

            return 0f;
        }

        public void PlayFallImpactEffects(float impactSpeed)
        {
            if (Mathf.Abs(impactSpeed) >= m_FallImpactThreshold)
            {
                if (CheckGround (out RaycastHit hitInfo))
                    SurfaceManager.SpawnEffect(hitInfo, SurfaceEffects.FallImpact, Mathf.Min(1f, impactSpeed / (m_MaxFallImpactThreshold - m_FallImpactThreshold)));
            }
        }

        private bool CheckGround(out RaycastHit hitInfo)
        {
            Ray ray = new Ray(transform.position + Vector3.up * 0.3f, Vector3.down);

            bool hitSomething = Physics.Raycast(ray, out hitInfo, m_RaycastDistance, m_GroundMask, QueryTriggerInteraction.Ignore);

            if (!hitSomething)
                hitSomething = Physics.SphereCast(ray, m_RaycastRadius, out hitInfo, m_RaycastDistance, m_GroundMask, QueryTriggerInteraction.Ignore);

            return hitSomething;
        }
    }
}