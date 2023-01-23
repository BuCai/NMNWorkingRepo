namespace SurvivalTemplatePro
{
    public interface ISleepModule : ICharacterModule
    {
        void DoSleepEffects(ISleepingPlace sleepingPlace, float duration);
        void DoWakeUpEffects(float duration);
    }
}