using SurvivalTemplatePro.InventorySystem;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.WieldableSystem {
    /// <summary>
    /// Takes care of selecting wieldables based on inventory items.
    /// </summary>
    [RequireComponent(typeof(IWieldablesController))]
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/wieldable#wieldable-inventory-select-handler-module")]
    public class WieldableInventorySelectionHandler : CharacterBehaviour, IWieldableSelectionHandler, ISaveableComponent {
        public int SelectedIndex => Mathf.Max(m_SelectedIndex, 0);
        public int PreviousIndex => m_PrevIndex;

        public event UnityAction<int> onSelectedChanged;

        [SerializeField]
        [InfoBox("Found in the Inventory Module.")]
        [Tooltip("The corresponding inventory container (e.g. holster, backpack etc.) that this behaviour will use for selecting items.")]
        private string m_HolsterContainer = "Holster";

        [SerializeField, Range(1, 8)]
        [Tooltip("The fist slot that will be selected.")]
        private int m_StartingSlot;

        [SpaceArea]

        [SerializeField, ReorderableList(HasLabels = false)]
        [Tooltip("All of the wieldables that are also inventory items (e.g. bows, spears etc.).")]
        private WieldableItemReference[] m_InventoryBasedWieldables;

#if UNITY_EDITOR
        [Space, FolderReference]
        public string WieldableLoadFolder;
#endif

        private int m_SelectedIndex = -1;
        private int m_PrevIndex = -1;
        private IItemContainer m_Holster;

        private readonly Dictionary<int, IWieldable> m_Wieldables = new Dictionary<int, IWieldable>();

        private IWieldablesController m_WieldableController;
        private IInventory m_Inventory;


        public override void OnInitialized() {
            GetModule(out m_WieldableController);
            GetModule(out m_Inventory);

            SpawnWieldables();

            StartCoroutine(C_SelectItemAtStartDelayed());
        }

        private void OnHolsterChanged(IItemSlot slot, ItemSlotChangeType slotChangeType) {
            if (slotChangeType == ItemSlotChangeType.PropertyChanged)
                return;

            // get index of slot
            int indexOfSlot = m_Holster.GetSlotIndex(slot);

            if (m_SelectedIndex == indexOfSlot)
                SelectAtIndex(indexOfSlot, 1.5f);
            else if (slot.HasItem)
                SelectAtIndex(indexOfSlot, 1f);
        }

        public void Refresh() => SelectAtIndex(m_SelectedIndex, 1f);

        public void SelectAtIndex(int indexToSelect, float holsterPrevSpeedMod = 1f) {
            m_SelectedIndex = Mathf.Clamp(indexToSelect, 0, m_Holster.Count - 1);

            EquipWieldable(m_Holster[m_SelectedIndex].Item, holsterPrevSpeedMod);

            //if (m_SelectedIndex != m_PrevIndex)
            onSelectedChanged?.Invoke(m_SelectedIndex);

            m_PrevIndex = m_SelectedIndex;
        }

        private void EquipWieldable(IItem itemToAttach, float holsterPrevSpeedMod) {
            if (itemToAttach != null && m_Wieldables.TryGetValue(itemToAttach.Id, out IWieldable wieldable)) {
                if (m_WieldableController.TryEquipWieldable(wieldable, holsterPrevSpeedMod))
                    wieldable.AttachItem(itemToAttach);
            } else {
                m_WieldableController.TryEquipWieldable(null, holsterPrevSpeedMod);
            }
        }

        private IEnumerator C_SelectItemAtStartDelayed() {
            yield return null;
            yield return null;

            m_Holster = m_Inventory.GetContainerWithName(m_HolsterContainer);
            if (m_Holster == null || m_Holster.Count == 0) {
                Debug.LogError("Holster null or has no slots");
            }
            m_Holster.onContainerChanged += OnHolsterChanged;

            if (m_WieldableController.IsEquipping || m_WieldableController.ActiveWieldable != null)
                yield break;

            if (m_SelectedIndex < 0) {
                int startingSlot = Mathf.Clamp(m_StartingSlot - 1, 0, m_Holster.Count);
                SelectAtIndex(startingSlot);
            }

            SelectAtIndex(m_SelectedIndex);
        }

        private void SpawnWieldables() {
            for (int i = 0; i < m_InventoryBasedWieldables.Length; i++) {
                if (m_InventoryBasedWieldables[i] != null) {
                    int itemId = m_InventoryBasedWieldables[i].GetItemId();

                    if (!m_Wieldables.ContainsKey(itemId))
                        m_Wieldables.Add(itemId, m_WieldableController.SpawnWieldable(m_InventoryBasedWieldables[i].Wieldable));
                    else
                        Debug.LogError("You're trying to spawn a wieldable with an id that has already been spawned.");
                }
            }
        }

        #region Save & Load
        public void LoadMembers(object[] members) {
            m_SelectedIndex = (int)members[0];
        }

        public object[] SaveMembers() {
            object[] members = new object[]
            {
                m_SelectedIndex
            };

            return members;
        }
        #endregion

        #region Editor
#if UNITY_EDITOR
        public void AddCustomWieldable(WieldableItemReference wieldableItemReference) {
            if (wieldableItemReference != null && !UnityEditor.ArrayUtility.Contains(m_InventoryBasedWieldables, wieldableItemReference)) {
                UnityEditor.ArrayUtility.Add(ref m_InventoryBasedWieldables, wieldableItemReference);
                UnityEditor.EditorUtility.SetDirty(this);
            }
        }
#endif
        #endregion
    }
}