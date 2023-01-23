using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Firearms/Ammo/Inventory Ammo")]
    public class FirearmInventoryAmmo : FirearmAmmoBehaviour
    {
        [Space]

        [SerializeField]
        private ItemReference m_AmmoItem;

        private IInventory m_Inventory;


        protected override void OnEnable()
        {
            base.OnEnable();

            m_Inventory = Firearm.Character.Inventory;
            m_Inventory.onInventoryChanged += OnInventoryChanged;
        }

        protected override void OnDisable()
        {
            if (m_Inventory != null)
                m_Inventory.onInventoryChanged -= OnInventoryChanged;
        }

        private void OnInventoryChanged(IItemSlot itemSlot, ItemSlotChangeType slotChangeType)
        {
            if (slotChangeType != ItemSlotChangeType.PropertyChanged)
                RaiseAmmoChangedEvent(GetAmmoCount());
        }

        public override int RemoveAmmo(int amount)
        {
            return m_Inventory.RemoveItems(m_AmmoItem, amount, ItemContainerFlags.Storage);
        }

        public override int AddAmmo(int amount)
        {
            return m_Inventory.AddItems(m_AmmoItem, amount, ItemContainerFlags.Storage);
        }

        public override int GetAmmoCount()
        {          
            return m_Inventory.GetItemCount(m_AmmoItem, ItemContainerFlags.Storage);
        }
    }
}