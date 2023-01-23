using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    public abstract class CharacterGroundedState : CharacterMotionState
    {
        public override bool ApplyGravity => false;
        public override bool SnapToGround => true;
        public override float StepCycleLength => m_StepLength;

        [SerializeField, Range(0f, 20f)]
        [Tooltip("How fast can this character achieve max velocity.")]
        protected float m_Acceleration = 5f;

        [SerializeField, Range(0f, 20f)]
        [Tooltip("How fast will the character stop when there's no input (a high value will make the movement feel snappier).")]
        protected float m_Damping = 8f;

        [SerializeField]
        [Tooltip("Lowers/Increases the moving speed of the character when moving on sloped surfaces (e.g. lower speed when walking up a hill).")]
        private AnimationCurve m_SlopeSpeedMod;

        [Tooltip("How much distance does this character need to cover to be considered a step.")]
        [SerializeField, Range(0.1f, 10f)]
        protected float m_StepLength = 1.2f;

        [Tooltip("The forward speed of this character.")]
        [SerializeField, Range(0.1f, 10f)]
        protected float m_ForwardSpeed = 2.5f;

        [Tooltip("The backward speed of this character.")]
        [SerializeField, Range(0.1f, 10f)]
        protected float m_BackSpeed = 2.5f;

        [Tooltip("The sideway speed of this character.")]
        [SerializeField, Range(0.1f, 10f)]
        protected float m_SideSpeed = 2.5f;

        public float ForwardSpeed() => m_ForwardSpeed; 
        
        public override bool IsStateValid() => Motor.IsGrounded;

        public override Vector3 UpdateVelocity(Vector3 currentVelocity, float deltaTime)
        {
            Vector3 targetVelocity = GetTargetVelocity(Input.MovementInput, currentVelocity);

            // Make sure to lower the speed when ascending steep surfaces.
            float surfaceAngle = Motor.GroundSurfaceAngle;
            if (surfaceAngle > 5f)
            {
                bool isAscendingSlope = Vector3.Dot(Motor.GroundNormal, Motor.SimulatedVelocity) < 0f;

                if (isAscendingSlope)
                    targetVelocity *= m_SlopeSpeedMod.Evaluate(surfaceAngle / Motor.SlopeLimit);
            }

            // Multiply the speed with the current velocity mod.
            targetVelocity *= Controller.VelocityMod;

            // Calculate the rate at which the current speed should increase / decrease. 
            // If the player doesn't press any movement button, use the "m_Damping" value, otherwise use "m_Acceleration".
            float targetAccel = targetVelocity.sqrMagnitude > 0f ? m_Acceleration : m_Damping;

            currentVelocity = Vector3.Lerp(currentVelocity, targetVelocity, targetAccel * deltaTime);

            return currentVelocity;
        }

        protected virtual Vector3 GetTargetVelocity(Vector3 moveDirection, Vector3 currentVelocity)
        {
            bool wantsToMove = moveDirection.sqrMagnitude > 0f;
            moveDirection = (wantsToMove ? moveDirection : currentVelocity.normalized);

            float desiredSpeed = 0f;

            if (wantsToMove)
            {
                // Set the default speed (forward)
                desiredSpeed = m_ForwardSpeed;

                // Sideways movement
                if (Mathf.Abs(Input.RawMovementInput.x) > 0.01f)
                    desiredSpeed = m_SideSpeed;

                // Back movement
                if (Input.RawMovementInput.y < 0f)
                    desiredSpeed = m_BackSpeed;
            }

            return moveDirection * desiredSpeed;
        }
    }
}