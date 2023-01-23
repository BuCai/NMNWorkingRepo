using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    public interface ICharacterMotionState
    {
        MotionStateType StateType { get; }
        float StepCycleLength { get; }
        bool ApplyGravity { get; }
        bool SnapToGround { get; }
        bool enabled { get; set; }


        /// <summary>
        /// Called when updating this state, returns a translation vector and the next state.
        /// </summary>
        void OnStateInitialized(IMotionController motionController, ICharacterMotionInputHandler input, ICharacterMotor motor);

        /// <summary>
        /// Can this state be transitioned to.
        /// </summary>
        bool IsStateValid();

        /// <summary>
        /// Called when entering this state.
        /// </summary>
        void OnStateEnter();

        /// <summary>
        /// Updates this state's logic, it also handles transitions.
        /// </summary>
        void UpdateLogic();

        /// <summary>
        /// Updates the character motor's velocity.
        /// </summary>
        /// <returns> New velocity </returns>
        Vector3 UpdateVelocity(Vector3 currentVelocity, float deltaTime);

        /// <summary>
        /// Called when exiting this state.
        /// </summary>
        void OnStateExit();
    }
}