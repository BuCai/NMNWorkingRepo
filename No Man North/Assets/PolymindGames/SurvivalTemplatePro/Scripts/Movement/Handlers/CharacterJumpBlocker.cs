using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/movement#character-jump-blocker-behaviour")]
    public class CharacterJumpBlocker : CharacterBehaviour
    {
        [SerializeField, Range(0f, 0.5f)]
        [Tooltip("At which stamina value (0-1) will the ability to jump be disabled.")]
        private float m_DisableJumpOnStaminaValue = 0.1f;

        [SerializeField, Range(0f, 0.5f)]
        [Tooltip("At which stamina value (0-1) will the ability to jump be re-enabled (if disabled)")]
        private float m_EnableJumpOnStaminaValue = 0.3f;

        private IMotionController m_Motion;
        private IStaminaController m_Stamina;

        private bool m_JumpDisabled;


        public override void OnInitialized()
        {
            GetModule(out m_Motion);
            GetModule(out m_Stamina);

            m_Stamina.onStaminaChanged += OnStaminaChanged;
        }

        private void OnStaminaChanged(float stamina)
        {
            if (!m_JumpDisabled && stamina < m_DisableJumpOnStaminaValue)
            {
                m_Motion.AddStateLocker(this, MotionStateType.Jump);
                m_JumpDisabled = true;
            }
            else if (m_JumpDisabled && stamina > m_EnableJumpOnStaminaValue)
            {
                m_Motion.RemoveStateLocker(this, MotionStateType.Jump);
                m_JumpDisabled = false;
            }
        }
    }
} 