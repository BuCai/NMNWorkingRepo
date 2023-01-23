using SurvivalTemplatePro.InventorySystem;
using System;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public class ItemAttachmentsUI : MonoBehaviour
    {
        #region Internal
        [Serializable]
        private class PropertySlot
        {
            public ItemSlotUI SlotUI { get; set; }
            public bool HasListener { get; set; }

            public ItemPropertyReference Property;
            public Sprite BackgroundIcon;
        }
        #endregion

        [SerializeField]
        private ItemSlotUI m_AttachmentSlotTemplate;

        [SerializeField]
        private RectTransform m_AttachmentSlotsRoot;

        [Space]

        [SerializeField]
        private PropertySlot[] m_AttachmentSlots;

        private ItemSlotUI m_InspectedSlot;


        public void UpdatePropertySlots(ItemSlotUI itemSlotUI)
        {
            m_InspectedSlot = itemSlotUI;
            if (m_AttachmentSlots == null || m_AttachmentSlots.Length == 0) {
                return;
            }
            for (int i = 0; i < m_AttachmentSlots.Length; i++)
            {
                var slotUI = m_AttachmentSlots[i].SlotUI;

                IItemProperty correspodingProperty = null;

                if (itemSlotUI != null && itemSlotUI.HasItem)
                    correspodingProperty = itemSlotUI.Item.GetProperty(m_AttachmentSlots[i].Property);

                if (correspodingProperty != null)
                {
                    int attachedItemId = correspodingProperty.ItemId;
                    IItem attachedItem = null;

                    if (attachedItemId != ItemDatabase.NullItem.Id)
                        attachedItem = new Item(ItemDatabase.GetItemById(attachedItemId));

                    slotUI.ItemSlot.SetItem(attachedItem);
                    slotUI.gameObject.SetActive(true);

                    if (!m_AttachmentSlots[i].HasListener)
                        slotUI.ItemSlot.onChanged += OnSlotChanged;
                }
                else
                {
                    slotUI.gameObject.SetActive(false);

                    if (m_AttachmentSlots[i].HasListener)
                        slotUI.ItemSlot.onChanged -= OnSlotChanged;
                }
            }
        }

        private void OnSlotChanged(IItemSlot itemSlot, ItemSlotChangeType changeType)
        {
            if (m_InspectedSlot == null)
                return;

            if (changeType == ItemSlotChangeType.ItemChanged)
            {
                var propertySlot = GetPropertySlotWithItemSlot(itemSlot);

                if (m_InspectedSlot.Item.TryGetProperty(propertySlot.Property, out var itemProperty))
                    itemProperty.ItemId = itemSlot.Item != null ? itemSlot.Item.Id : ItemDatabase.NullItem.Id;
            }
        }

        private PropertySlot GetPropertySlotWithItemSlot(IItemSlot itemSlot) 
        {
            for (int i = 0; i < m_AttachmentSlots.Length; i++)
            {
                if (m_AttachmentSlots[i].SlotUI.ItemSlot == itemSlot)
                    return m_AttachmentSlots[i];
            }

            return null;
        }

        private void Awake()
        {
            for (int i = 0; i < m_AttachmentSlots.Length; i++)
            {
                m_AttachmentSlots[i].SlotUI = Instantiate(m_AttachmentSlotTemplate, m_AttachmentSlotsRoot);
                m_AttachmentSlots[i].SlotUI.BackgroundIcon.sprite = m_AttachmentSlots[i].BackgroundIcon;

                m_AttachmentSlots[i].SlotUI.LinkToSlot(new ItemSlot());
            }
        }
    }
}