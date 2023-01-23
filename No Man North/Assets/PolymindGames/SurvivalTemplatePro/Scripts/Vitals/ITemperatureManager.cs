using UnityEngine.Events;

namespace SurvivalTemplatePro {
    public interface ITemperatureManager : ICharacterModule {
        float PlayerTemperature { get; }
        float EnviroTemperature { get; }
        float tempOffset { get; set; }
    }
}