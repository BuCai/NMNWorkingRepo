using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    public interface IRadiationManager : ICharacterModule
    {
        bool HasMaxRadiation { get; }

        float Radiation { get; set; }
        float MaxRadiation { get; set; }

        event UnityAction<float> onThirstChanged;
        event UnityAction<float> onMaxThirstChanged;
    }
}