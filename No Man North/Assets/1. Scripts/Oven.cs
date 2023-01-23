using SurvivalTemplatePro.InventorySystem;
using SurvivalTemplatePro.WorldManagement;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.BuildingSystem {

    //TODO: Add propane use
    public class Oven : Interactable, IExternalContainer, ISaveableComponent {

        public ItemContainer ItemContainer { get; private set; }
        public RvResources resources;

        //Amount of propane used per in-game hour (1f = 1L of propane)
        [SerializeField] private float propaneUsePerHour = 1f;

        [SerializeField, Range(1, 10)]
        [Tooltip("How many cooking spots (item slots) this campfire has.")]
        private int m_CookingSpots = 3;

        [SerializeField]
        [Tooltip("The property that tells the campfire how cooked an item is.")]
        private ItemPropertyReference m_CookedAmountProperty;

        [SerializeField]
        [Tooltip("The property that tells the campfire in what item should the cooked item transform.")]
        private ItemPropertyReference m_CookedOutputProperty;

        [SerializeField, Range(1f, 12f)]
        [Tooltip("The amount of in-game hours it takes to cook an item.")]
        private float m_ItemCookDuration = 4f;

        private void Start() {
            ItemContainer = new ItemContainer("Cooking", 100, m_CookingSpots, ItemContainerFlags.External, null, null, null);
        }

        private void Update() {
            if (resources.propaneLeft > 0) {
                UpdateCooking();
            }
        }

        private void UpdateCooking() {
            bool cooking = false;
            for (int i = 0; i < ItemContainer.Slots.Length; i++) {
                if (ItemContainer.Slots[i].HasItem) {
                    IItem item = ItemContainer.Slots[i].Item;
                    if (item.TryGetProperty(m_CookedAmountProperty, out IItemProperty cookedAmount)) {
                        cooking = true;
                        cookedAmount.Float += (Time.deltaTime * WorldManagement.WorldManager.Instance.GetTimeIncrementPerSecond() * 24f) / m_ItemCookDuration;
                        if (cookedAmount.Float >= 1f) {
                            if (item.TryGetProperty(m_CookedOutputProperty, out IItemProperty cookedOutputProperty)) {
                                ItemInfo cookOutput = ItemDatabase.GetItemById(cookedOutputProperty.ItemId);
                                if (cookOutput != null)
                                    ItemContainer.Slots[i].SetItem(new Item(cookOutput, item.CurrentStackSize));
                            }
                        }
                    }
                }
            }
            if (cooking) {
                resources.propaneLeft -= propaneUsePerHour * Time.deltaTime * WorldManagement.WorldManager.Instance.GetTimeIncrementPerSecond() * 24f;
            }
        }

        #region Save & Load
        public void LoadMembers(object[] members) {
            ItemContainer = members[0] as ItemContainer;
        }

        public object[] SaveMembers() {
            object[] members = new object[]
            {
                ItemContainer,
            };

            return members;
        }
        #endregion
    }
}