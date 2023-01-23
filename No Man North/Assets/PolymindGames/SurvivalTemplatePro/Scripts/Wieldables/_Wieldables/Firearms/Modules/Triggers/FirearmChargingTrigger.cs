using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Firearms/Triggers/Charging Trigger")]
	public class FirearmChargingTrigger : FirearmTriggerBehaviour, IChargeHandler
	{
		[Space]

		[SerializeField, Range(0f, 10f)]
		[Tooltip("The minimum time that can pass between consecutive shots.")]
		private float m_PressCooldown = 0f;

		[SerializeField, Range(0f, 0.95f)]
		[Tooltip("Minimum charge needed to shoot")]
		private float m_MinChargeTime = 0f;

		[SerializeField, Range(0f, 10f)]
		private float m_MaxChargeTime = 1f;

		[SerializeField]
		private AnimationCurve m_ChargeCurve;

		[Space]

		[SerializeField]
		private bool BlockAimWhenUncharged = true;

		[Title("Audio")]

		[SerializeField]
		private StandardSound m_ChargeStartSound;

		[SerializeField]
		private StandardSound m_ChargeEndSound;

		[SerializeField, HideInInspector]
		private STPEventReference m_TriggerChargeStartEvent = new STPEventReference("On Trigger Charge Start");

		[SerializeField, HideInInspector]
		private STPEventReference m_TriggerChargeEndEvent = new STPEventReference("On Trigger Charge End");

		[SerializeField, HideInInspector]
		private STPEventReference m_TriggerMaxChargeEvent = new STPEventReference("On Trigger Max Charge");

		private float m_NextTimeCanHold;
		private float m_TriggerChargeStartTime;
		private bool m_TriggerChargeStarted = false;
		private bool m_ChargeMaxed = false;

		private IAimHandler m_AimHandler;
		private bool m_AimerBlocked;


        public override void HoldTrigger()
		{
			if (Time.time < m_NextTimeCanHold)
				return;

			if (Firearm.Reloader.IsReloading || Firearm.Reloader.IsMagazineEmpty)
			{
				Shoot(0f);
				return;
			}

			base.HoldTrigger();

			// Charge Start
			if (!m_TriggerChargeStarted && GetNormalizedCharge() > m_MinChargeTime)
			{
				// Audio
				Firearm.AudioPlayer.PlaySound(m_ChargeStartSound);

				// Events
				Firearm.EventHandler.TriggerAction(m_TriggerChargeStartEvent, 1f);

				m_TriggerChargeStarted = true;
				m_TriggerChargeStartTime = Time.time;

				UnblockAimer();
			}

			// Charge Max
			if (!m_ChargeMaxed && GetNormalizedCharge() > (m_MaxChargeTime - 0.01f))
			{
				// Local Effects
				Firearm.EventHandler.TriggerAction(m_TriggerMaxChargeEvent, 1f);
				m_ChargeMaxed = true;
			}
		}

		public override void ReleaseTrigger()
		{
			if (!IsTriggerHeld)
				return;

			// Charge end
			if (GetNormalizedCharge() >= m_MinChargeTime)
			{
				float normalizedCharge = GetNormalizedCharge();
				float chargeAmount = normalizedCharge * m_ChargeCurve.Evaluate(normalizedCharge);

				Shoot(chargeAmount);

				// Audio
				Firearm.AudioPlayer.PlaySound(m_ChargeEndSound);

				// Local Effects
				Firearm.EventHandler.TriggerAction(m_TriggerChargeEndEvent, chargeAmount);
			}

			m_TriggerChargeStarted = false;
			m_ChargeMaxed = false;

			m_NextTimeCanHold = Time.time + m_PressCooldown;
			IsTriggerHeld = false;

			BlockAimer();
		}

        public float GetNormalizedCharge()
        {
			if (!IsTriggerHeld)
				return 0f;

			float normalizedCharge = (Time.time - m_TriggerChargeStartTime) / m_MaxChargeTime;
			normalizedCharge = Mathf.Clamp(normalizedCharge, 0.05f, 1f);

			return normalizedCharge;
		}

		protected override void OnEnable()
		{
			base.OnEnable();

			m_AimHandler = Firearm as IAimHandler;
			BlockAimer();
		}

        protected override void OnDisable()
        {
            base.OnDisable();

			UnblockAimer();
		}

		private void BlockAimer()
		{
			if (BlockAimWhenUncharged && !m_AimerBlocked)
			{
				m_AimHandler.RegisterAimBlocker(this);
				m_AimerBlocked = true;
			}
		}

		private void UnblockAimer() 
		{
			if (BlockAimWhenUncharged && m_AimerBlocked)
			{
				m_AimHandler.UnregisterAimBlocker(this);
				m_AimerBlocked = false;
			}
		}
    }
}