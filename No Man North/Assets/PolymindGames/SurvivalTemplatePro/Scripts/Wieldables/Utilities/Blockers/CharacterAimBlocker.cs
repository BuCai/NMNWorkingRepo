using SurvivalTemplatePro.MovementSystem;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [RequireComponent(typeof(Wieldable))]
    [AddComponentMenu("Wieldables/ActionBlockers/Aim Blocker")]
    public class CharacterAimBlocker : CharacterActionBlocker
    {
        [SerializeField, Space]
        private bool m_AimWhileAirborne;

        [SerializeField]
        private bool m_AimWhileRunning;

        private IAimHandler m_AimHandler;
        private IMotionController m_Motion;
        private ICharacterMotor m_Motor;


        public override void OnInitialized()
        {
            m_AimHandler = GetComponent<IAimHandler>();

            GetModule(out m_Motor);
            GetModule(out m_Motion);
        }

        protected override bool IsActionValid()
        {
            bool isValid = (m_AimWhileAirborne || m_Motor.IsGrounded) &&
                           (m_AimWhileRunning || m_Motion.ActiveStateType != MotionStateType.Run);

            return isValid;
        }

        protected override void BlockAction() => m_AimHandler.RegisterAimBlocker(this);
        protected override void UnblockAction() => m_AimHandler.UnregisterAimBlocker(this);
    }
}
