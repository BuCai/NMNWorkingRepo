using SurvivalTemplatePro.MovementSystem;
using System;
using UnityEngine;

namespace SurvivalTemplatePro
{
    /// <summary>
    /// Handles playing sounds for humanoid characters.
    /// </summary>
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/audio#audio-player-module")]
	public class HumanSoundsManager : CharacterBehaviour
    {
		#region Internal
		[Serializable]
		private struct MotionStateAudio
		{
			public MotionStateType StateType;
			public StandardSound EnterAudio;
			public StandardSound ExitAudio;

			[Space]

			public bool PlayLoopAudio;

			[ShowIf("PlayLoopAudio", true)]
			public StandardSound LoopAudio;
		}

		[Serializable]
		private struct DamageAudio
		{
			[Range(0f, 100f), Tooltip("")]
			public float DamageAmountThreshold;

			[Tooltip("The sounds that will be played when this entity receives damage.")]
			public StandardSound GenericDamageAudio;

			[Range(0f, 50f), Tooltip("")]
			public float FallDamageSpeedThreshold;

			public StandardSound FallDamageAudio;
			public StandardSound DeathAudio;

			[Range(0f, 100f), Tooltip("")]
			public float HeartbeatHealthThreshold;

			public StandardSound HeartbeatAudio;
		}

		[Serializable]
		private struct StaminaAudio
		{
			[Range(0.1f, 25f)]
			public float BreathingHeavyDuration;

			public StandardSound BreathingHeavyAudio;
		}
		#endregion

		[Title("Damage Audio"), SerializeField]
		private DamageAudio m_Damage;

		[Title("Stamina Audio"), SerializeField]
		private StaminaAudio m_Stamina;

		[Title("Motion Audio"), SerializeField]
		[LabelByChild("StateType"), ReorderableList(ListStyle.Round, Foldable = true)]
		private MotionStateAudio[] m_Motions;

		private IAudioPlayer m_AudioPlayer;
		private IMotionController m_Motion;
		private ICharacterMotor m_Motor;
		private IHealthManager m_HealthManager;
		private IStaminaController m_StaminaController;

		private bool m_HeartbeatActive;
		private float m_LastHeavyBreathTime;


        public override void OnInitialized()
        {
			GetModule(out m_Motion);
			GetModule(out m_Motor);
			GetModule(out m_AudioPlayer);
			GetModule(out m_HealthManager);
			GetModule(out m_StaminaController);

			m_Motor.onFallImpact += OnFallImpact;

			m_HealthManager.onDeath += OnDeath;
			m_HealthManager.onHealthChanged += OnHealthChanged;

			m_StaminaController.onStaminaChanged += OnStaminaChanged;

			CreateMotionAudioEvents();
		}

		private void CreateMotionAudioEvents() 
		{
			foreach (var motion in m_Motions)
			{
				m_Motion.AddStateEnterListener(motion.StateType, () =>
				{
					m_AudioPlayer.PlaySound(motion.EnterAudio);

					if (motion.PlayLoopAudio)
						m_AudioPlayer.LoopSound(motion.LoopAudio, 0f);
				});

				m_Motion.AddStateExitListener(motion.StateType, () =>
				{
					m_AudioPlayer.PlaySound(motion.ExitAudio);

					if (motion.PlayLoopAudio)
						m_AudioPlayer.StopLoopingSound(motion.LoopAudio, 0.1f);
				});
			}
		}

        private void OnDestroy()
        {
			if (m_HealthManager != null)
			{
				m_HealthManager.onDeath -= OnDeath;
				m_HealthManager.onHealthChanged -= OnHealthChanged;
			}

			if (m_StaminaController != null)
				m_StaminaController.onStaminaChanged -= OnStaminaChanged;
		}

        private void OnDeath() => m_AudioPlayer.PlaySound(m_Damage.DeathAudio);

		private void OnFallImpact(float impactSpeed)
		{
			// Don't play the clip when the impact speed is low
			bool wasHardImpact = Mathf.Abs(impactSpeed) >= m_Damage.FallDamageSpeedThreshold;
			wasHardImpact &= m_HealthManager.Health < m_HealthManager.PrevHealth;

			if (wasHardImpact)
				m_AudioPlayer.PlaySound(m_Damage.FallDamageAudio);
		}

		private void OnHealthChanged(float health)
		{
			// On damage...
			if (health < m_HealthManager.PrevHealth)
			{
				if ((m_HealthManager.PrevHealth - health) > m_Damage.DamageAmountThreshold)
					m_AudioPlayer.PlaySound(m_Damage.GenericDamageAudio);

				// Start heartbeat loop sound...
				if (!m_HeartbeatActive && health < m_Damage.HeartbeatHealthThreshold)
				{
					m_AudioPlayer.LoopSound(m_Damage.HeartbeatAudio, 1000f);
					m_HeartbeatActive = true;
				}
			}
			// On health restored...
			else
			{
				// Stop heartbeat loop sound...
				if (m_HeartbeatActive && health > m_Damage.HeartbeatHealthThreshold)
				{
					m_AudioPlayer.StopLoopingSound(m_Damage.HeartbeatAudio);
					m_HeartbeatActive = false;
				}
			}
		}

		private void OnStaminaChanged(float stamina)
		{
			if (Time.time - m_LastHeavyBreathTime > m_Stamina.BreathingHeavyDuration)
			{
				if (stamina < 0.01f)
				{
					m_AudioPlayer.LoopSound(m_Stamina.BreathingHeavyAudio, m_Stamina.BreathingHeavyDuration);
					m_LastHeavyBreathTime = Time.time;
				}
			}
		}
    }
}