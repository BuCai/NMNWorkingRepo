using SurvivalTemplatePro.BodySystem;
using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public class CharacterPreviewUI : PlayerUIBehaviour
    {
        [Title("References")]

        [SerializeField]
        private Camera m_Camera;

        [SerializeField]
        private BodyClothing m_BodyClothing;

        [Title("Equipment Containers")]

        [SerializeField]
        private string m_HeadContainerName = "Head";

        [SerializeField]
        private string m_TorsoContainerName = "Torso";

        [SerializeField]
        private string m_LegsContainerName = "Legs";

        [SerializeField]
        private string m_FeetContainerName = "Feet";

        private IInventoryInspectManager m_InventoryInspectManager;


        private void OnClothingSlotChanged(IItemSlot itemSlot, ClothingType clothingType)
        {
            if (itemSlot.HasItem)
                m_BodyClothing.ShowClothing(itemSlot.Item.Id);
            else
                m_BodyClothing.HideClothing(clothingType);
        }

        public override void OnAttachment()
        {
            var inventory = Player.Inventory;

            var headContainer = inventory.GetContainerWithName(m_HeadContainerName);
            var torsoContainer = inventory.GetContainerWithName(m_TorsoContainerName);
            var LegsContainer = inventory.GetContainerWithName(m_LegsContainerName);
            var FeetContainer = inventory.GetContainerWithName(m_FeetContainerName);

            headContainer.onContainerChanged += ((IItemSlot slot, ItemSlotChangeType changeType) => OnClothingSlotChanged(slot, ClothingType.Head));
            torsoContainer.onContainerChanged += ((IItemSlot slot, ItemSlotChangeType changeType) => OnClothingSlotChanged(slot, ClothingType.Torso));
            LegsContainer.onContainerChanged += ((IItemSlot slot, ItemSlotChangeType changeType) => OnClothingSlotChanged(slot, ClothingType.Legs));
            FeetContainer.onContainerChanged += ((IItemSlot slot, ItemSlotChangeType changeType) => OnClothingSlotChanged(slot, ClothingType.Feet));

            OnClothingSlotChanged(headContainer.Slots[0], ClothingType.Head);
            OnClothingSlotChanged(torsoContainer.Slots[0], ClothingType.Torso);
            OnClothingSlotChanged(LegsContainer.Slots[0], ClothingType.Legs);
            OnClothingSlotChanged(FeetContainer.Slots[0], ClothingType.Feet);

            m_Camera.enabled = false;

            if (TryGetModule(out m_InventoryInspectManager))
            {
                m_InventoryInspectManager.onInspectStarted += OnInspectionStarted;
                m_InventoryInspectManager.onInspectEnded += OnInspectionEnded;
            }
        }

        private void OnInspectionEnded()
        {
            if (m_Camera != null)
                m_Camera.enabled = false;
        }

        private void OnInspectionStarted(InventoryInspectState state)
        {
            if (m_Camera != null)
                m_Camera.enabled = true;
        }
    }
}