using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Firearms/Aimers/Basic Aimer")]
    public class FirearmBasicAimer : FirearmAimerBehaviour
    {
        public override float AimShootSpread => m_AimShootSpread;
        public override float HipShootSpread => m_HipShootSpread;

        [Title("Aiming")]

        [SerializeField, Range(0f, 5f)]
        private float m_AimThreshold = 0.3f;

        [SerializeField, Range(0f, 10f)]
        private float m_HipShootSpread = 1f;

        [SerializeField, Range(0f, 10f)]
        private float m_AimShootSpread = 1f;

        [Title("Crosshair")]

        [SerializeField, Range(-1, 100)]
        private int m_AimCrosshairIndex = 0;

        [Title("Audio")]

        [SerializeField]
        private StandardSound m_AimAudio;

        [SerializeField]
        private StandardSound m_AimEndAudio;

        [SerializeField, HideInInspector]
        private STPEventReference m_AimEvent = new STPEventReference("On {0} Aim", false);

        [SerializeField, HideInInspector]
        private STPEventReference m_AimEndEvent = new STPEventReference("On Aim End");

        private ICrosshairHandler m_CrosshairHandler;
        private float m_NextPossibleAimTime;


        public override bool TryStartAim()
        {
            if (IsAiming || Time.time < m_NextPossibleAimTime)
                return false;

            // Crosshair
            m_CrosshairHandler.CrosshairIndex = m_AimCrosshairIndex;

            // Audio
            Firearm.AudioPlayer.PlaySound(m_AimAudio);

            // Events
            Firearm.EventHandler.TriggerAction(m_AimEvent);

            IsAiming = true;

            return true;
        }

        public override bool TryEndAim()
        {
            if (!IsAiming)
                return false;

            m_NextPossibleAimTime = Time.time + m_AimThreshold;

            // Crosshair
            m_CrosshairHandler.ResetCrosshair();

            // Audio
            Firearm.AudioPlayer.PlaySound(m_AimEndAudio);

            // Local Effects
            Firearm.EventHandler.TriggerAction(m_AimEndEvent);

            IsAiming = false;

            return true;
        }

        protected override void Awake()
        {
            base.Awake();

            m_CrosshairHandler = Firearm as ICrosshairHandler;
        }
    }
}
