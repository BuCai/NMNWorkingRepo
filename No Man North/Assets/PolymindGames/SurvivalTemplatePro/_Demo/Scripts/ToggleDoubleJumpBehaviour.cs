using SurvivalTemplatePro.MovementSystem;
using UnityEngine;

namespace SurvivalTemplatePro.Demo
{
    public class ToggleDoubleJumpBehaviour : MonoBehaviour
    {
        public void ToggleDoubleJump(ICharacter character) 
        {
            if (character.TryGetModule(out IMotionController motionController))
            {
                var jumpState = motionController.GetStateOfType<CharacterJumpState>();

                if (jumpState != null)
                {
                    if (jumpState.DefaultJumpsCount == jumpState.MaxJumpsCount)
                        jumpState.MaxJumpsCount++;
                    else
                        jumpState.MaxJumpsCount--;
                }
            }
        }
    }
}