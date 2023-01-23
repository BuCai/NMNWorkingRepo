using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/movement#character-run-blocker-behaviour")]
    public class CharacterRunBlocker : CharacterBehaviour
    {
        [SerializeField, Range(0f, 0.5f)]
        [Tooltip("At which stamina value (0-1) will the ability to run be disabled.")]
        private float m_DisableRunOnStaminaValue = 0.1f;

        [SerializeField, Range(0f, 0.5f)]
        [Tooltip("At which stamina value (0-1) will the ability to run be re-enabled (if disabled)")]
        private float m_EnableRunOnStaminaValue = 0.3f;

        private IMotionController m_Motion;
        private IStaminaController m_Stamina;

        private bool m_RunDisabled;


        public override void OnInitialized()
        {
            GetModule(out m_Motion);
            GetModule(out m_Stamina);

            m_Stamina.onStaminaChanged += OnStaminaChanged;
        }

        private void OnStaminaChanged(float stamina)
        {
            if (!m_RunDisabled && stamina < m_DisableRunOnStaminaValue)
            {
                m_Motion.AddStateLocker(this, MotionStateType.Run);
                m_RunDisabled = true;
            }
            else if (m_RunDisabled && stamina > m_EnableRunOnStaminaValue)
            {
                m_Motion.RemoveStateLocker(this, MotionStateType.Run);
                m_RunDisabled = false;
            }
        }
    }
}