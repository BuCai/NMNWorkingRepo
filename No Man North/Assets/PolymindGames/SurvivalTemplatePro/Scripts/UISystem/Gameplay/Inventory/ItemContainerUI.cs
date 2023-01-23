using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem {
    public class ItemContainerUI : ContainerUI<ItemSlotUI> {
        #region Internal

        public enum SlotLinkMethod {
            GenerateAndLinkSlots,
            LinkChildSlots
        }

        #endregion

        public IItemContainer ItemContainer {
            get {
                if (m_ItemContainer != null)
                    return m_ItemContainer;
                else {
                    Debug.LogError("There's no item container linked. Can't retrieve any!");

                    return null;
                }
            }
        }

        [Header("Item Container")]

        [SerializeField]
        private bool m_IsPlayerContainer = true;

        [SerializeField]
        private string m_ContainerName;

        [SerializeField]
        private SlotLinkMethod m_SlotLinkMethod = SlotLinkMethod.GenerateAndLinkSlots;

        private IItemContainer m_ItemContainer;


        public override void OnAttachment() {
            if (m_IsPlayerContainer) {
                IItemContainer itemContainer = PlayerInventory.GetContainerWithName(m_ContainerName);

                if (itemContainer != null)
                    AttachToContainer(itemContainer);
            }
        }

        public void AttachToContainer(IItemContainer container) {
            if (m_SlotLinkMethod == SlotLinkMethod.LinkChildSlots) {
                m_SlotInterfaces = GetComponentsInChildren<ItemSlotUI>();
            } else if (m_SlotLinkMethod == SlotLinkMethod.GenerateAndLinkSlots) {
                GenerateSlots(container.Count);
            }

            for (int i = 0; i < container.Count; i++)
                m_SlotInterfaces[i].LinkToSlot(container[i]);

            m_ItemContainer = container;
        }

        public void DetachFromContainer() {
            for (int i = 0; i < m_SlotInterfaces.Length; i++)
                m_SlotInterfaces[i].UnlinkFromSlot();
        }

        public override bool GenerateSlots() {
            if (m_SlotLinkMethod == SlotLinkMethod.LinkChildSlots)
                return false;
            return base.GenerateSlots();
        }

        public override bool GenerateSlots(int count) {
            if (m_SlotLinkMethod == SlotLinkMethod.LinkChildSlots)
                return false;
            return base.GenerateSlots(count);
        }
    }
}