using SurvivalTemplatePro.InventorySystem;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro {
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/interaction/interactable/demo-interactables")]
    public class StorageStation : Interactable, IExternalContainer, ISaveableComponent {
        public ItemContainer ItemContainer => m_ItemContainer;

        [Title("Settings (Storage Station)")]

        [SerializeField, Range(0, 100)]
        [Tooltip("How many slots should this storage crate have.")]
        private int m_StorageSpots;

        [SerializeField, ReorderableList]
        private ItemGenerator[] m_InitialItems;

        [SerializeField, Tooltip("Can a character add items to this storage.")]
        private bool m_CanAddItems = true;

        [SerializeField, Tooltip("Can a character remove items from this storage.")]
        private bool m_CanRemoveItems = true;

        [SerializeField]
        [Tooltip("Only items from the specified categories can be added")]
        private ItemCategoryReference[] m_ValidCategories;

        [SerializeField]
        [Tooltip("Only items with the specified properties can be added.")]
        private ItemPropertyReference[] m_RequiredProperties;

        [SerializeField]
        [Tooltip("Only items that are tagged with the specified tag can be added.")]
        private string m_RequiredTag;

        [Title("Audio")]

        [SerializeField]
        private SoundPlayer m_OpenSound;

        [SerializeField]
        private SoundPlayer m_CloseSound;

        [Title("Events")]

        [SerializeField, Tooltip("Open Station Event.")]
        private UnityEvent m_OnOpenCallback;

        [SerializeField, Tooltip("Close Station Event.")]
        private UnityEvent m_OnCloseCallback;

        private ItemContainer m_ItemContainer;


        public virtual void OpenStation() {
            m_OnOpenCallback?.Invoke();
            m_OpenSound.Play2D();
        }

        public virtual void CloseStation() {
            m_OnCloseCallback?.Invoke();
            m_CloseSound.Play2D();
        }

        protected virtual void Start() {
            if (m_ItemContainer == null)
                GenerateContainer();
        }

        protected virtual void GenerateContainer() {
            m_ItemContainer = new ItemContainer("Storage", 100, m_StorageSpots, ItemContainerFlags.External, m_ValidCategories, m_RequiredProperties, m_RequiredTag);

            foreach (var itemGenerator in m_InitialItems)
                m_ItemContainer.AddItem(itemGenerator.GenerateItem());

            m_ItemContainer.CanAddItems = m_CanAddItems;
            m_ItemContainer.CanRemoveItems = m_CanRemoveItems;
        }

        #region Save & Load
        public void LoadMembers(object[] members) {
            m_ItemContainer = members[0] as ItemContainer;
        }

        public object[] SaveMembers() {
            object[] members = new object[]
            {
                m_ItemContainer
            };

            return members;
        }
        #endregion
    }
}