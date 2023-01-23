using SurvivalTemplatePro.InventorySystem;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public class CraftingUI : PlayerUIBehaviour
    {
        [SerializeField]
        private PanelUI m_CraftingPanel;

        [SerializeField]
        private SelectableGroupUI m_CraftingLevelsGroup;

        [Title("Items")]

        [SerializeField]
        private CraftingSlotUI m_Template;

        [SerializeField]
        private RectTransform m_TemplateSpawnRect;

        [SerializeField, Range(5, 20)]
        private int m_MaxTemplateInstanceCount = 10;

        private int m_CurrentCraftingLevel = -1;
        private ICraftingManager m_CraftingManager;
        private SelectableUI[] m_CraftingLevels;

        /// <summary>
        /// <para> Key: Crafting level. </para>
        /// Value: List of items that correspond to the crafting level.
        /// </summary>
        private readonly Dictionary<int, List<ItemInfo>> m_CraftableItemsDictionary = new Dictionary<int, List<ItemInfo>>();
        private readonly List<CraftingSlotUI> m_CachedSlots = new List<CraftingSlotUI>();


        public override void OnAttachment()
        {
            GetModule(out m_CraftingManager);

            InitializeDictionary();
            InitializeCraftingSlots();
            InitializeCraftingLevels();

            m_CraftingPanel.onToggled += OnPanelToggled;
            m_CraftingLevelsGroup.onSelected += OnCraftingLevelSelected;
            m_CraftingLevelsGroup.SetSelectables(m_CraftingLevels);

            SetAvailableCraftingLevels(0);
        }

        private void OnCraftingLevelSelected(SelectableUI selectable)
        {
            int craftLevel = m_CraftingLevelsGroup.GetIndexOfSelectable(selectable);
            UpdateCraftingLevel(craftLevel);
        }

        public override void OnDetachment()
        {
            m_CraftingPanel.onToggled -= OnPanelToggled;
        }

        public void SetAvailableCraftingLevels(params int[] levels)
        {
            for (int i = 0; i < m_CraftingLevels.Length; i++)
            {
                if (i.IsPartOfArray(levels))
                    m_CraftingLevels[i].gameObject.SetActive(true);
                else
                    m_CraftingLevels[i].gameObject.SetActive(false);
            }

            var highestCraftableLevel = m_CraftingLevels[levels.GetLargestValue()];
            m_CraftingLevelsGroup.SelectSelectable(highestCraftableLevel);
        }

        public void ShowPanel(bool show) => m_CraftingPanel.Show(show);

        private void UpdateCraftingLevel(int level)
        {
            if (level == m_CurrentCraftingLevel)
                return;

            if (m_CraftableItemsDictionary.TryGetValue(level, out List<ItemInfo> list))
            {
                int itterationCount = list.Count < m_CachedSlots.Count ? list.Count : m_CachedSlots.Count;

                for (int i = 0; i < itterationCount; i++)
                {
                    m_CachedSlots[i].DisplayItem(list[i]);
                    m_CachedSlots[i].UpdateRequirementsUI(PlayerInventory);
                }

                // Hide the remainning slots.
                if (itterationCount < m_CachedSlots.Count)
                {
                    int slotStartIndex = list.Count;

                    for (int i = slotStartIndex; i < m_CachedSlots.Count; i++)
                        m_CachedSlots[i].DisplayItem(null);
                }

                m_CurrentCraftingLevel = level;
            }
        }

        public void ResetCraftingLevel() => SetAvailableCraftingLevels(0);

        private void InitializeDictionary()
        {
            foreach (var category in ItemDatabase.GetAllCategories())
            {
                foreach (var item in category.Items)
                {
                    if (item.Crafting.IsCraftable)
                    {
                        List<ItemInfo> list;

                        if (m_CraftableItemsDictionary.TryGetValue(item.Crafting.CraftLevel, out list))
                        {
                            list.Add(item);
                        }
                        else
                        {
                            list = new List<ItemInfo>() { item };
                            m_CraftableItemsDictionary.Add(item.Crafting.CraftLevel, list);
                        }
                    }
                }
            }
        }

        private void InitializeCraftingSlots()
        {
            int remainingSlots = m_MaxTemplateInstanceCount;

            foreach (var category in ItemDatabase.GetAllCategories())
            {
                if (remainingSlots == 0)
                    break;

                foreach (var item in category.Items)
                {
                    if (remainingSlots == 0)
                        break;

                    if (item.Crafting.IsCraftable)
                    {
                        m_CachedSlots.Add(Instantiate(m_Template.gameObject, m_TemplateSpawnRect).GetComponent<CraftingSlotUI>());

                        int currentIndex = m_MaxTemplateInstanceCount - remainingSlots;
                        m_CachedSlots[currentIndex].onClick += StartCrafting;
                        m_CachedSlots[currentIndex].DisplayItem(null);

                        remainingSlots--;
                    }
                }
            }
        }

        private void InitializeCraftingLevels() => m_CraftingLevels = GetComponentsInChildren<SelectableUI>(true);

        private void OnPanelToggled(bool show)
        {
            if (show)
            {
                Player.Inventory.onInventoryChanged += UpdateCraftRequirments;
                UpdateCraftRequirments(null, ItemSlotChangeType.ItemChanged);
                UpdateCraftingLevel(m_CurrentCraftingLevel);
            }
            else
            {
                Player.Inventory.onInventoryChanged -= UpdateCraftRequirments;
                m_CraftingManager.CancelCrafting();
            }
        }

        private void UpdateCraftRequirments(IItemSlot slot, ItemSlotChangeType slotChangeType)
        {
            if (slotChangeType == ItemSlotChangeType.PropertyChanged)
                return;

            for (int i = 0; i < m_CachedSlots.Count; i++)
            {
                if (m_CachedSlots[i].gameObject.activeSelf)
                    m_CachedSlots[i].UpdateRequirementsUI(PlayerInventory);
            }
        }

        private void StartCrafting(ItemInfo itemInfo) => m_CraftingManager.Craft(itemInfo);
    }
}