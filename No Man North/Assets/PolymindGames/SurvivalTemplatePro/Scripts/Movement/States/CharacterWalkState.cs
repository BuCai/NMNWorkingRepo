namespace SurvivalTemplatePro.MovementSystem
{
    public class CharacterWalkState : CharacterGroundedState
    {
        public override MotionStateType StateType => MotionStateType.Walk;


        public override bool IsStateValid() => Motor.IsGrounded && Motor.CanSetHeight(Motor.DefaultHeight);
        public override void OnStateEnter() => Motor.SetHeight(Motor.DefaultHeight);

        public override void UpdateLogic()
        {
            // Transition to an idle state.
            if (Input.RawMovementInput.sqrMagnitude < 0.1f && Motor.SimulatedVelocity.sqrMagnitude < 0.01f && Controller.TrySetState(MotionStateType.Idle)) return;

            // Transition to a run state.
            if (Input.RunInput && Controller.TrySetState(MotionStateType.Run)) return;

            // Transition to a slide state.
            if (Input.CrouchInput && Controller.TrySetState(MotionStateType.Slide)) return;

            // Transition to a crouch state.
            if (Input.CrouchInput && Controller.TrySetState(MotionStateType.Crouch)) return;

            // Transition to an airborne state.
            if (!Motor.IsGrounded && Controller.TrySetState(MotionStateType.Airborne)) return;

            // Transition to a jumping state.
            if (Input.JumpInput && Controller.TrySetState(MotionStateType.Jump)) return;
        }

    }
}