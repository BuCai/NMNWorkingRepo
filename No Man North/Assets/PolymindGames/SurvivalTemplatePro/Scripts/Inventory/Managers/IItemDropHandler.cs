using SurvivalTemplatePro.InventorySystem;

namespace SurvivalTemplatePro
{
    public interface IItemDropHandler : ICharacterModule
    {
        void DropItem(IItem itemToDrop, float dropDelay = 0f);
        void DropItem(IItemSlot itemSlot, float dropDelay = 0f);
    }
}