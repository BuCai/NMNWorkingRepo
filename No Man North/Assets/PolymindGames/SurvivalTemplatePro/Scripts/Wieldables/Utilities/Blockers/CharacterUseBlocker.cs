using SurvivalTemplatePro.MovementSystem;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [RequireComponent(typeof(Wieldable))]
    [AddComponentMenu("Wieldables/ActionBlockers/Use Blocker")]
    public class CharacterUseBlocker : CharacterActionBlocker
    {
        [SerializeField, Space]
        private bool m_UseWhileAirborne;

        [SerializeField]
        private bool m_UseWhileCrouched = true;

        [SerializeField]
        private bool m_UseWhileRunning;

        [SerializeField]
        private bool m_UseWithoutStamina = true;

        private IStaminaController m_StaminaController;

        private IUseHandler m_UseHandler;
        private IMotionController m_Motion;
        private ICharacterMotor m_Motor;


        public override void OnInitialized()
        {
            m_UseHandler = GetComponent<IUseHandler>();

            GetModule(out m_StaminaController);
            GetModule(out m_Motion);
            GetModule(out m_Motor);
        }

        protected override bool IsActionValid()
        {
            bool isValid = (m_UseWhileAirborne || m_Motor.IsGrounded) &&
                           (m_UseWhileCrouched || m_Motion.ActiveStateType != MotionStateType.Crouch) &&
                           (m_UseWhileRunning || m_Motion.ActiveStateType != MotionStateType.Run);

            isValid &= (m_UseWithoutStamina || m_StaminaController.Stamina > 0.01f);

            return isValid;
        }

        protected override void BlockAction() => m_UseHandler.RegisterUseBlocker(this);
        protected override void UnblockAction() => m_UseHandler.UnregisterUseBlocker(this);
    }
}