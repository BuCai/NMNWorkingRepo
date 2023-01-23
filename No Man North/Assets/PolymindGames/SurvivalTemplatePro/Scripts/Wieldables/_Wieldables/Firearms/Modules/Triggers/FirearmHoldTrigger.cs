using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    public class FirearmHoldTrigger : FirearmTriggerBehaviour
	{
		[Space]

		[SerializeField, Range(0f, 10f)]
		[Tooltip("The minimum time that can pass between consecutive shots.")]
		private float m_PressCooldown = 0.22f;

		[SerializeField, Range(0f, 3f)]
		private float m_PressTime = 0f;

		[SerializeField, HideInInspector]
		private STPEventReference m_PressHoldStartEvent = new STPEventReference("On Trigger Press Hold Start");

		private float m_NextTimeCanPress;
		private float m_TriggerHoldTime;
		private bool m_CanHoldTrigger;


		public override void HoldTrigger()
		{
			base.HoldTrigger();

			if (m_CanHoldTrigger)
			{
				m_TriggerHoldTime += Time.deltaTime;

				if (m_TriggerHoldTime > m_PressTime && Time.time > m_NextTimeCanPress)
				{
					Shoot(1f);

					m_NextTimeCanPress = Time.time + m_PressCooldown;
					m_CanHoldTrigger = false;
				}

				// Events
				Firearm.EventHandler.TriggerAction(m_PressHoldStartEvent, 1f);
			}
		}

		protected override void TapTrigger()
		{
			m_CanHoldTrigger = true;
			m_TriggerHoldTime = 0f;

			if (Time.time > m_NextTimeCanPress)
			{
				Shoot(1f);

				m_NextTimeCanPress = Time.time + m_PressCooldown;
			}
		}
	}
}