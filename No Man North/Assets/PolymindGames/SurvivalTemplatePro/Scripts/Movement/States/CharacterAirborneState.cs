using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    public class CharacterAirborneState : CharacterMotionState
    {
        public override MotionStateType StateType => MotionStateType.Airborne; 
        public override float StepCycleLength => 1f;
        public override bool ApplyGravity => true;
        public override bool SnapToGround => false;

        [SerializeField, Range(0f, 10f)]
        protected float m_AirborneControl = 5f;

        [SerializeField, Range(0f, 5f)]
        protected float m_LandVelocityMod = 0.8f;


        public override bool IsStateValid() => !Motor.IsGrounded;

        public override void UpdateLogic()
        {
            // Try double, triple... jump.
            if (Input.JumpInput && Controller.TrySetState(MotionStateType.Jump)) return;

            if (Motor.IsGrounded)
            {
                // Transition to a run state.
                if (Input.RunInput && Controller.TrySetState(MotionStateType.Run)) return;

                // Transition to a slide or crouch state.
                if (Input.CrouchInput && (Controller.TrySetState(MotionStateType.Slide) || Controller.TrySetState(MotionStateType.Crouch))) return;

                // Transition to a walking state.
                if (Controller.TrySetState(MotionStateType.Walk)) return;

                // Transition to an idle state.
                if (Controller.TrySetState(MotionStateType.Idle)) return;
            }
        }

        public override Vector3 UpdateVelocity(Vector3 currentVelocity, float deltaTime)
        {
            // Modify the current velocity by taking into account how well we can change direction when not grounded (see "m_AirControl" tooltip).
            currentVelocity += Input.MovementInput * (deltaTime * m_AirborneControl);

            if (Motor.CollisionFlags == CollisionFlags.CollidedAbove && currentVelocity.y > 0.1f)
                currentVelocity.y = -currentVelocity.y;

            // Apply a velocity mod on landing.
            if (Motor.IsGrounded)
            {
                float groundImpactVelocityMod = m_LandVelocityMod;
                Vector3 normalizedVelocity = Vector3.ClampMagnitude(currentVelocity, 1f);
                groundImpactVelocityMod *= Mathf.Abs(normalizedVelocity.x) + Mathf.Abs(normalizedVelocity.z); 

                currentVelocity.x *= groundImpactVelocityMod;
                currentVelocity.z *= groundImpactVelocityMod;
            }

            return currentVelocity;
        }
    }
}