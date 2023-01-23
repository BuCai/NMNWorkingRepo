using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public class EquipActionUI : ItemActionUI
    {
        [SerializeField, Space]
        private ItemTagReference[] m_ValidTags;


        public override bool IsViableForItem(ItemSlotUI itemSlot)
        {
            if (itemSlot.Parent.ItemContainer.Flag == ItemContainerFlags.Holster)
                return false;

            string itemTag = itemSlot.Item != null ? itemSlot.Item.Info.Tag : "";

            for (int i = 0; i < m_ValidTags.Length; i++)
            {
                if (itemTag == m_ValidTags[i])
                    return true;
            }

            return false;
        }

        protected override void PerformAction(ItemSlotUI itemSlotUI)
        {
            PlayerInventory.AddOrSwap(itemSlotUI.Parent.ItemContainer, itemSlotUI.ItemSlot, ItemContainerFlags.Holster);
        }
    }
}
