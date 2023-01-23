using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    public class CharacterCrouchState : CharacterGroundedState
    {
        public override MotionStateType StateType => MotionStateType.Crouch;
        public bool IsCrouching { get; private set; }

        [Space]

        [Tooltip("The controllers height when crouching.")]
        [SerializeField, Range(0f, 2f)]
        private float m_CrouchHeight = 1f;

        [Tooltip("How long does it take to crouch.")]
        [SerializeField, Range(0f, 1f)]
        private float m_CrouchDuration = 0.3f;

        private float m_NextTimeCanCrouch;


        public override bool IsStateValid()
        {
            bool canCrouch =
                Time.time > m_NextTimeCanCrouch &&
                Motor.IsGrounded &&
                Motor.CanSetHeight(m_CrouchHeight);

            return canCrouch;
        }

        public override void OnStateEnter()
        {
            m_NextTimeCanCrouch = Time.time + m_CrouchDuration;
            Motor.SetHeight(m_CrouchHeight);
            IsCrouching = true;
        }

        public override void UpdateLogic()
        {
            // Transition to an airborne state.
            if (Controller.TrySetState(MotionStateType.Airborne)) return;

            // Transition to an idle or walk state.
            if (CanStandUp() && (!Input.CrouchInput || Input.JumpInput || Input.RunInput))
            {
                Input.UseCrouchInput();
                Input.UseJumpInput();
                Controller.TrySetState(Motor.SimulatedVelocity.sqrMagnitude > 0.1f ? MotionStateType.Walk : MotionStateType.Idle);
                IsCrouching = false;
            }
        }

        public override void OnStateExit()
        {
            m_NextTimeCanCrouch = Time.time + m_CrouchDuration;
        }

        private bool CanStandUp() => Time.time > m_NextTimeCanCrouch + m_CrouchDuration;
    }
}