using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    public class CharacterSlideState : CharacterMotionState
    {
        public override MotionStateType StateType => MotionStateType.Slide;
        public override bool ApplyGravity => false;
        public override bool SnapToGround => true;
        public override float StepCycleLength => 1.5f;

        [Space]

        [Tooltip("Sliding speed over time.")]
        [SerializeField]
        private AnimationCurve m_SlideSpeed;

        [SerializeField, Range(0f, 100f)]
        private float m_SlideImpulse = 10f;

        [SerializeField, Range(0f, 100f)]
        [Tooltip("How fast will the character stop when there's no input (a high value will make the movement feel snappier).")]
        private float m_SlideFriction = 10f;

        [Space]

        [Tooltip("The controllers height when sliding.")]
        [SerializeField, Range(0f, 2f)]
        private float m_SlideHeight = 1f;

        [SerializeField]
        private AnimationCurve m_SlideEnterSpeed;

        [SerializeField, Range(0f, 25f)]
        private float m_MinSlideSpeed = 4f;

        [SerializeField, Range(0.1f, 10f)]
        private float m_SlideStopSpeed = 2f;

        [Space]

        [Tooltip("How much control does the Player input have on the slide direction.")]
        [SerializeField, Range(0f, 10f)]
        private float m_InputFactor;

        [SerializeField, Range(0f, 50f)]
        private float m_SlopeAscendSpeedMod = 0.5f;

        [SerializeField, Range(0f, 50f)]
        private float m_SlopeDescendSpeedMod = 2f;

        private Vector3 m_SlideDirection;
        private float m_SlideStartTime;
        private float m_InitialSlideImpulseMod;


        public override bool IsStateValid()
        {
            bool canSlide =
                Motor.Velocity.magnitude > m_MinSlideSpeed &&
                Motor.IsGrounded &&
                Motor.CanSetHeight(m_SlideHeight);

            return canSlide;
        }

        public override void OnStateEnter()
        {
            m_SlideDirection = Vector3.ClampMagnitude(Motor.SimulatedVelocity, 1f);
            m_SlideStartTime = Time.time;
            Motor.SetHeight(m_SlideHeight);

            m_InitialSlideImpulseMod = m_SlideEnterSpeed.Evaluate(Motor.Velocity.magnitude) * m_SlideImpulse;

            if (Controller.PrevStateType == MotionStateType.Airborne)
                m_InitialSlideImpulseMod *= 0.33f;

            Input.UseRunInput();
        }

        public override void UpdateLogic()
        {
            // Transition to airborne state.
            if (!Motor.IsGrounded && Controller.TrySetState(MotionStateType.Airborne)) return;

            if (Motor.Velocity.magnitude < m_SlideStopSpeed)
            {
                // Transition to a running state.
                if (Input.RunInput && Controller.TrySetState(MotionStateType.Run)) return;

                // Transition to a crouch state.
                if ((Motor.Velocity.sqrMagnitude < 2f || Input.RawMovementInput.sqrMagnitude > 0.1f) && Controller.TrySetState(MotionStateType.Crouch)) return;
            }

            // Transition to a jump state.
            if (Input.JumpInput && Controller.TrySetState(MotionStateType.Jump)) return;
        }

        public override Vector3 UpdateVelocity(Vector3 currentVelocity, float deltaTime)
        {
            // Calculate the sliding impulse velocity.
            Vector3 targetVelocity = m_SlideDirection * (m_SlideSpeed.Evaluate(Time.time - m_SlideStartTime) * m_InitialSlideImpulseMod);

            // Sideways movement.
            if (Mathf.Abs(Input.RawMovementInput.x) > 0.01f)
                targetVelocity += Vector3.ClampMagnitude(Motor.transform.TransformVector(new Vector3(Input.RawMovementInput.x, 0f, 0f)), 1f);

            // Combine the target velocity with the sideways movement.
            float previousMagnitude = targetVelocity.magnitude;
            targetVelocity = Vector3.ClampMagnitude((Input.MovementInput * m_InputFactor) + targetVelocity, previousMagnitude);

            // Lower velocity if the motor has collided with anything.
            if (Motor.CollisionFlags.HasFlag(CollisionFlags.CollidedSides))
                targetVelocity *= 0.1f;

            // Multiply the speed with the current velocity mod.
            targetVelocity *= Controller.VelocityMod;

            // Make sure to increase the speed when descending steep surfaces.
            float surfaceAngle = Motor.GroundSurfaceAngle;
            if (surfaceAngle > 3f)
            {
                bool isDescendingSlope = Vector3.Dot(Motor.GroundNormal, Motor.SimulatedVelocity) > 0f;
                float slope = Mathf.Min(surfaceAngle, Motor.SlopeLimit) / Motor.SlopeLimit;
                Vector3 slopeDirection = Motor.GroundNormal;
                slopeDirection.y = 0f;

                if (isDescendingSlope)
                {
                    // Increase the sliding force when going down slopes.
                    currentVelocity += slopeDirection * (slope * m_SlopeDescendSpeedMod * deltaTime * 10f);
                }
                else
                {
                    // Reduce the sliding force when going up slopes.
                    currentVelocity -= -(slopeDirection * (slope * m_SlopeAscendSpeedMod * deltaTime * 20f));
                }
            }

            currentVelocity = Vector3.Lerp(currentVelocity, targetVelocity, deltaTime * m_SlideFriction);

            return currentVelocity;
        }
    }
}