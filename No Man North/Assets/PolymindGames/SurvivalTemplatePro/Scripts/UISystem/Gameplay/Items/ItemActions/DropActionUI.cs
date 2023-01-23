namespace SurvivalTemplatePro.UISystem
{
    public class DropActionUI : ItemActionUI
    {
        public override bool IsViableForItem(ItemSlotUI itemSlot) => true;

        protected override void PerformAction(ItemSlotUI itemSlot)
        {
            if (Player.TryGetModule(out IItemDropHandler itemDropHandler))
                itemDropHandler.DropItem(itemSlot.ItemSlot);
        }
    }
}