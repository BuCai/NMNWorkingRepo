using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    public interface ICharacterMotionInputHandler
    {
        Vector2 RawMovementInput { get; }
        Vector3 MovementInput { get; }

        bool RunInput { get; }
        bool CrouchInput { get; }
        bool JumpInput { get; }


        void TickInput();

        void ResetAllInputs();
        void UseCrouchInput();
        void UseRunInput();
        void UseJumpInput();
    }
}