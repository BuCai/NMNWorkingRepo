using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    public class CharacterIdleState : CharacterMotionState
    {
        public override MotionStateType StateType => MotionStateType.Idle;
        public override float StepCycleLength => 0f;
        public override bool ApplyGravity => false;
        public override bool SnapToGround => true;


        public override bool IsStateValid() => Motor.CanSetHeight(Motor.DefaultHeight);

        public override void OnStateEnter()
        {
            Input.UseRunInput();
            Motor.SetHeight(Motor.DefaultHeight);
        }

        public override void UpdateLogic()
        {
            // Transition to a walking state.
            if ((Input.RawMovementInput.sqrMagnitude > 0.1f || Motor.Velocity.sqrMagnitude > 0.001f) && Controller.TrySetState(MotionStateType.Walk)) return;

            // Transition to a jumping state.
            if (Input.JumpInput && Controller.TrySetState(MotionStateType.Jump)) return;

            // Transition to a crouched state.
            if (Input.CrouchInput && Controller.TrySetState(MotionStateType.Crouch)) return;

            // Transition to an airborne state.
            if (!Motor.IsGrounded && Controller.TrySetState(MotionStateType.Airborne)) return;
        }

        public override Vector3 UpdateVelocity(Vector3 currentVelocity, float deltaTime) => Vector3.MoveTowards(currentVelocity, Vector3.zero, deltaTime);
    }
}