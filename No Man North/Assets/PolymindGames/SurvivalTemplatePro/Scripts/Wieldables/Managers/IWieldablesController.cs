using SurvivalTemplatePro.WieldableSystem;

namespace SurvivalTemplatePro
{
    public interface IWieldablesController : ICharacterModule
    {
        IWieldable ActiveWieldable { get; }
        bool IsEquipping { get; }

        event WieldableEquipCallback onWieldableHolsterStart;
        event WieldableEquipCallback onWieldableEquipped;

        bool GetWieldableOfType<T>(out T wieldable) where T : IWieldable;
        bool HasWieldable(IWieldable wieldable);

        bool TryEquipWieldable(IWieldable wieldable, float holsterSpeed = 1f);

        IWieldable SpawnWieldable(IWieldable wieldable);
        bool DestroyWieldable(IWieldable wieldable);
    }

    public delegate void WieldableEquipCallback(IWieldable equippedWieldable);
}