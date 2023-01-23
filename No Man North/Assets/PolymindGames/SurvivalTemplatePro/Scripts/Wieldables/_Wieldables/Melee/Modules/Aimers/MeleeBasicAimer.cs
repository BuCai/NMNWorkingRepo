using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [RequireComponent(typeof(IWieldable))]
	[AddComponentMenu("Wieldables/Melee/Basic Aimer")]
	public class MeleeBasicAimer : MeleeAimerBehaviour
    {
        [SerializeField, Range(0f, 5f)]
        private float m_AimThreshold;

		[SerializeField]
		private DelayedSoundRandom m_AimSounds;

		[Title("Crosshair")]

		[SerializeField, Range(-1, 24)]
		private int m_AimCrosshairIndex = 0;

		[SerializeField]
		private STPEventReference m_AimStartEvent = new STPEventReference("On Aim Start", true);

		[SerializeField]
		private STPEventReference m_AimEndEvent = new STPEventReference("On Aim End", true);

		private ICrosshairHandler m_CrosshairHandler;
		private float m_NextPossibleAimTime;


		public override bool TryStartAim()
		{
			if (IsAiming || Time.time < m_NextPossibleAimTime)
				return false;

			m_NextPossibleAimTime = Time.time + m_AimThreshold;

			// Crosshair
			m_CrosshairHandler.CrosshairIndex = m_AimCrosshairIndex;

			// Audio
			Wieldable.AudioPlayer.PlaySound(m_AimSounds);

			// Event
			Wieldable.EventHandler.TriggerAction(m_AimStartEvent);

			IsAiming = true;

			return true;
		}

        public override bool TryEndAim()
        {
			// Crosshair
			m_CrosshairHandler.ResetCrosshair();

			// Event
			Wieldable.EventHandler.TriggerAction(m_AimEndEvent);

			IsAiming = false;

			return true;
		}

        protected override void Start()
        {
            base.Start();
			m_CrosshairHandler = Wieldable as ICrosshairHandler;
		}
    }
}