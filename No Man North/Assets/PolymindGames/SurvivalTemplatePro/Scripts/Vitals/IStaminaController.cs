using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    public interface IStaminaController : ICharacterModule
    {
        /// <summary>
        /// Current stamina, 0 - 1 range
        /// </summary>
        float Stamina { get; set; }

        event UnityAction<float> onStaminaChanged;
    }
}