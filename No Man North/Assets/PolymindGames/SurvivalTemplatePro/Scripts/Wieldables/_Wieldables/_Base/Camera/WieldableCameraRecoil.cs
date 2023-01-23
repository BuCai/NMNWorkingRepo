using SurvivalTemplatePro.CameraSystem;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Event Listeners/Camera Recoil")]
    public class WieldableCameraRecoil : STPWieldableEventsListener<WieldableCameraRecoil>
    {
        #region Internal
        [System.Serializable]
        protected class CameraRecoilEventSettings : STPEventListenerBehaviour
        {
            public RecoilType RecoilType;

            [Space]

            public Vector2 ControllableRecoil;
            public float RecoilDuration;

            [Space]

            public FPRecoilForce Force;
            public ShakeSettings Shake;

            protected override void OnActionTriggered(float value) => Instance.DoRecoil(this, value);
        }

        [System.Flags]
        protected enum RecoilType
        {
            Controllable = 1,
            SpringForce = 2,
            Shake = 4
        }
        #endregion

        [SerializeField]
        private Spring.Settings m_SpringSettings = Spring.Settings.Default;

        [SpaceArea]

        [SerializeField, ReorderableList(elementLabel: "Recoil", Foldable = true)]
        private CameraRecoilEventSettings[] m_RecoilSettings;

        private ICameraMotionHandler m_CameraMotion;
        private ILookHandler m_LookHandler;


        protected override IEnumerable<STPEventListenerBehaviour> GetEvents() => m_RecoilSettings;

        protected override void OnInitialized(ICharacter character)
        {
            character.TryGetModule(out m_CameraMotion);
            character.TryGetModule(out m_LookHandler);
        }

        protected override void OnWieldableEquipped()
        {
            base.OnWieldableEquipped();
            m_CameraMotion.SetCustomForceSpringSettings(m_SpringSettings);
        }

        protected override void OnWieldableHolstered(float holsterSpeed)
        {
            m_CameraMotion.ClearCustomForceSpringSettings();
        }

        private void DoRecoil(CameraRecoilEventSettings settings, float recoilMod)
        {
            recoilMod = Mathf.Max(recoilMod, 0.3f);
            RecoilType recoilTypeFlags = settings.RecoilType;

            if ((recoilTypeFlags & RecoilType.Controllable) == RecoilType.Controllable)
            {
                Vector2 recoil = new Vector2(-settings.ControllableRecoil.x, Random.Range(settings.ControllableRecoil.y, -settings.ControllableRecoil.y)) * recoilMod;
                m_LookHandler.AddAdditiveLookOverTime(recoil, settings.RecoilDuration);
            }

            if ((recoilTypeFlags & RecoilType.SpringForce) == RecoilType.SpringForce)
                m_CameraMotion.AddRotationForce(settings.Force.GetRotationForce() * recoilMod);

            if ((recoilTypeFlags & RecoilType.Shake) == RecoilType.Shake)
                CameraShakeHandler.DoShake(settings.Shake, recoilMod);
        }

#if UNITY_EDITOR
        private void OnValidate()
        {
            if (Application.isPlaying && m_CameraMotion != null)
                m_CameraMotion.SetCustomForceSpringSettings(m_SpringSettings);
        }
#endif
    }
}