using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    public class CharacterRunState : CharacterGroundedState
    {
        public override MotionStateType StateType => MotionStateType.Run;

        [Space]

        [SerializeField, Range(0f, 20f)]
        private float m_MinRunSpeed = 3f;

        public override bool IsStateValid() => CanRun(Input.MovementInput);

        public override void OnStateEnter()
        {
            base.OnStateEnter();

            Motor.SetHeight(Motor.DefaultHeight);
            Input.UseCrouchInput();
        }

        public override void UpdateLogic()
        {
            // Transition to an airborne state.
            if (Controller.TrySetState(MotionStateType.Airborne)) return;

            //Transition to a walk state.
            if ((!Input.RunInput || !CanRun(Input.MovementInput)) && Controller.TrySetState(MotionStateType.Walk)) return;

            // Transition to a slide or crouch state.
            if (Input.CrouchInput && (Controller.TrySetState(MotionStateType.Slide) || Controller.TrySetState(MotionStateType.Crouch))) return;

            // Transition to a jumping state.
            if (Input.JumpInput && Controller.TrySetState(MotionStateType.Jump)) return;
        }

        private bool CanRun(Vector3 movementInput)
        {
            bool canRun = Input.MovementInput.sqrMagnitude > 0.1f &&
                          Motor.Velocity.sqrMagnitude > m_MinRunSpeed &&
                          Motor.CanSetHeight(Motor.DefaultHeight) &&
                          !Controller.IsStateLocked(StateType) &&
                          Motor.IsGrounded;

            return canRun;

            // if (!canRun)
            //     return false;

            // Vector3 moveDirectionLocal = transform.InverseTransformVector(movementInput);
            // bool wantsToMoveBack = moveDirectionLocal.z < 0f;
            // bool wantsToMoveOnlySideways = Mathf.Abs(moveDirectionLocal.x) > 0.9f;
            //
            // // return !wantsToMoveBack && !wantsToMoveOnlySideways;
        }
    }
}