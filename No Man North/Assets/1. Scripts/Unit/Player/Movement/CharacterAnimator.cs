
using SurvivalTemplatePro;
using SurvivalTemplatePro.MovementSystem;
using UnityEngine;

/// <summary>
/// The goal of this script is to integrate the easy character movement plugin animations with survival pack pro movement module.
/// </summary>
namespace EasyCharacterMovement.Examples.Animation.UnityCharacterAnimatorExample
{
    /// <summary>
    /// This example shows how to externally animate a ECM2 character based on its current movement mode and / or state.
    /// </summary>
    public sealed class CharacterAnimator : MonoBehaviour
    {
        private static readonly int Forward = Animator.StringToHash("Forward");
        private static readonly int Turn = Animator.StringToHash("Turn");
        private static readonly int Ground = Animator.StringToHash("OnGround");
        private static readonly int Crouch = Animator.StringToHash("Crouch");
        private static readonly int Jump = Animator.StringToHash("Jump");
        private static readonly int JumpLeg = Animator.StringToHash("JumpLeg");

        [SerializeField] private Character character;

        [SerializeField] private CharacterControllerMotor motor;
        [SerializeField] private CharacterRunState runState;
        [SerializeField] private CharacterCrouchState crouchState;

        private bool _isCharacterNull;

        private void Update()
        {
            if (_isCharacterNull)
                return;

            float deltaTime = Time.deltaTime;

            // Get Character animator

            Animator animator = character.GetAnimator();

            // Compute input move vector in local space
            Vector3 move = transform.InverseTransformDirection(motor.Velocity);
            
            // Update the animator parameters
            float forwardAmount = motor && runState
                ? Mathf.InverseLerp(0, runState.ForwardSpeed(),
                    move.z)
                : 0.0f;

            animator.SetFloat(Forward, forwardAmount, 0.1f, deltaTime);
            animator.SetFloat(Turn, Mathf.Atan2(move.x, move.z), 0.1f, deltaTime);

            animator.SetBool(Ground, motor.IsGrounded);
            animator.SetBool(Crouch, crouchState.IsCrouching);
            
            if (move.y < 0)
                animator.SetFloat(Jump, move.y, 0.1f, deltaTime);

            // Calculate which leg is behind, so as to leave that leg trailing in the jump animation
            // (This code is reliant on the specific run cycle offset in our animations,
            // and assumes one leg passes the other at the normalized clip times of 0.0 and 0.5)

            float runCycle = Mathf.Repeat(animator.GetCurrentAnimatorStateInfo(0).normalizedTime + 0.2f, 1.0f);
            float jumpLeg = (runCycle < 0.5f ? 1.0f : -1.0f) * forwardAmount;
            
            if (motor.IsGrounded)
                animator.SetFloat(JumpLeg, jumpLeg);
        }

        private void Start()
        {
            _isCharacterNull = character == null;
        }
    }
}