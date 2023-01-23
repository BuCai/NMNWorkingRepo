using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public class DismantleActionUI : ItemActionUI
    {
        [Space]

        [SerializeField, Range(0f, 10f)]
        private float m_DurationPerBlueprintItem = 2f;

        [SerializeField]
        private ItemPropertyReference m_DurabilityProperty;

        private IItemDropHandler m_DropHandler;


        public override void OnAttachment() => GetModule(out m_DropHandler);

        public override bool IsViableForItem(ItemSlotUI itemSlot) => itemSlot.Item.Info.Crafting.AllowDismantle;

        protected override void PerformAction(ItemSlotUI itemSlot)
        {
            var crafting = itemSlot.Item.Info.Crafting;

            if (crafting.Blueprint.Count <= 0)
                return;

            var durabilityProp = itemSlot.Item.GetProperty(m_DurabilityProperty);
            float dismantleEfficiency = crafting.DismantleEfficiency * (durabilityProp != null ? durabilityProp.Float / 100f : 1f);

            // Add the blueprint items to the inventory
            for (int i = 0; i < crafting.Blueprint.Count; i++)
            {
                int amountToAdd = Mathf.CeilToInt(crafting.Blueprint[i].Amount * dismantleEfficiency);
                int addedCount = PlayerInventory.AddItems(crafting.Blueprint[i].Item, amountToAdd, ItemContainerFlags.Storage);

                // If there's no space in the inventory, drop the item
                if (addedCount < amountToAdd)
                    m_DropHandler.DropItem(new Item(crafting.Blueprint[i].Item.GetItem(), amountToAdd - addedCount));
            }

            itemSlot.ItemSlot.RemoveFromStack(1);
        }

        protected override void CancelAction(ItemSlotUI itemSlot) { }
        protected override float GetDuration(ItemSlotUI itemSlot) => itemSlot.Item.Info.Crafting.Blueprint.Count * m_DurationPerBlueprintItem;
    }
}