namespace SurvivalTemplatePro
{
    public interface IPlayerCompanionHandler : ICharacterModule
    {
        DogCompanion DogCompanion { get; }
        HitchhikerCompanion HitchhikerCompanion { get; }
        
        bool AddCompanion(ICompanion companion);
        bool RemoveCompanion(ICompanion companion);
    }
}