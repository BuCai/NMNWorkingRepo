using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    public interface ILookHandler : ICharacterModule
    {
        Vector2 LookAngle { get; } 
        Vector2 CurrentInput { get; }

        event UnityAction onPostViewUpdate;

        void AddAdditiveLookOverTime(Vector2 amount, float duration);
        void SetSensitivityMod(float mod);

        /// <summary>
        /// A method that will be used when the look handler needs input. 
        /// </summary>
        void SetLookInput(LookInputCallback lookInputCallback);
    }

    /// <summary>
    /// A delegate that will be used when the look handler needs input. 
    /// </summary>
    public delegate Vector2 LookInputCallback();
}