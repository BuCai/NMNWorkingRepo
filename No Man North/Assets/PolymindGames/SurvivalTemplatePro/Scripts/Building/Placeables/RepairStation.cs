using SurvivalTemplatePro.InventorySystem;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.BuildingSystem
{
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/interaction/interactable/demo-interactables")]
    public class RepairStation : Interactable, IExternalContainer, ISaveableComponent
    {
        public ItemContainer ItemContainer => m_ItemContainer;
        public List<CraftRequirement> RepairRequirementsForCurrentItem => m_RepairRequirements;

        public IItem ItemToRepair => m_ItemContainer.Slots[0].Item;
        public float RepairDuration => m_RepairDuration;

        public event UnityAction onItemToRepairChanged;

        [Title("Settings (Repair Station)")]

        [SerializeField, Range(0f, 25f)]
        [Tooltip("The time it takes to repair an item at this station.")]
        private float m_RepairDuration = 1f;

        [SerializeField]
        [Tooltip("The id of the durability property. After repairing an item the workbench will increase the value of that property for the repaired item.")]
        private ItemPropertyReference m_DurabilityProperty;

        [Space]

        [SerializeField]
        [Tooltip("Repair sound to be played after successfully repairing an item.")]
        private SoundPlayer m_RepairAudio;

        private ItemContainer m_ItemContainer;
        private List<CraftRequirement> m_RepairRequirements;


        public bool CanRepairItem()
        {
            if (ItemToRepair == null)
                return false;

            IItem itemToRepair = ItemContainer.Slots[0].Item;
            bool canRepairItem = itemToRepair != null && itemToRepair.HasProperty(m_DurabilityProperty) && itemToRepair.GetProperty(m_DurabilityProperty).Float < 100f;

            return canRepairItem;
        }

        public void RepairItem(ICharacter character)
        {
            foreach (var req in m_RepairRequirements)
                character.Inventory.RemoveItems(req.Item, req.Amount, ItemContainerFlags.Storage);

            ItemToRepair.GetProperty(m_DurabilityProperty).Float = 100f;

            m_RepairAudio.PlayAtPosition(transform.position, 1f);
        }

        protected virtual void Start()
        {
            if (m_ItemContainer == null)
            {
                m_ItemContainer = new ItemContainer("Workspace", 100, 1, ItemContainerFlags.External, null, null, null);

                m_RepairRequirements = new List<CraftRequirement>();
                m_ItemContainer.onContainerChanged += OnContainerChanged;
            }
        }

        private void OnContainerChanged(IItemSlot itemSlot, ItemSlotChangeType slotChangeType)
        {
            m_RepairRequirements.Clear();

            var item = itemSlot.Item;

            if (item != null)
            {
                if (item.TryGetProperty(m_DurabilityProperty, out IItemProperty durabilityProperty))
                {
                    float durability = durabilityProperty.Float;

                    foreach (var req in item.Info.Crafting.Blueprint)
                    {
                        int requiredAmount = Mathf.Max(Mathf.RoundToInt(req.Amount * Mathf.Clamp01((100f - durability) / 100f)), 1);
                        m_RepairRequirements.Add(new CraftRequirement(req.Item, requiredAmount));
                    }
                }
            }

            onItemToRepairChanged?.Invoke();
        }

        #region Save & Load
        public void LoadMembers(object[] members)
        {
            m_ItemContainer = members[0] as ItemContainer;
            m_RepairRequirements = members[1] as List<CraftRequirement>;

            m_ItemContainer.onContainerChanged += OnContainerChanged;
        }

        public object[] SaveMembers()
        {
            object[] members = new object[]
            {
                m_ItemContainer,
                m_RepairRequirements,
            };

            return members;
        }
        #endregion
    }
}