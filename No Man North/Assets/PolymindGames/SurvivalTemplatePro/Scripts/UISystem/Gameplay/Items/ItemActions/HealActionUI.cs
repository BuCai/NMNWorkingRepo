using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public class HealActionUI : ItemActionUI
    {
        [Space]

        [SerializeField]
        private ItemPropertyReference m_HealthRestoreProperty;


        public override bool IsViableForItem(ItemSlotUI itemSlot) => itemSlot.Item.HasProperty(m_HealthRestoreProperty);

        protected override void PerformAction(ItemSlotUI itemSlot)
        {
            float healthRestore = itemSlot.Item.GetProperty(m_HealthRestoreProperty).Float;
            Player.HealthManager.RestoreHealth(healthRestore);

            itemSlot.ItemSlot.RemoveFromStack(1);
        }
    }
}