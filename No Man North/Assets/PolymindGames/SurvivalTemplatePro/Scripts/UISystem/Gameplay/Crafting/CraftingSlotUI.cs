using SurvivalTemplatePro.InventorySystem;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class CraftingSlotUI : SlotUI
    {
        public event UnityAction<ItemInfo> onClick;

        [SerializeField, Space]
        private Text m_ItemName;

        [SerializeField]
        private Text m_ItemDescription;

        [SerializeField]
        private Image m_ItemIcon;

        [Space]

        [SerializeField]
        private RequirementUI[] m_Requirements;

        [SerializeField]
        private Color m_HasEnoughColor = Color.white;

        [SerializeField]
        private Color m_NotEnoughColor = Color.red;

        private ItemInfo m_Item;


        public void DisplayItem(ItemInfo item)
        {
            m_Item = item;

            if (m_Item != null)
            {
                m_ItemName.text = m_Item.Name;
                m_ItemDescription.text = m_Item.Description;
                m_ItemIcon.sprite = m_Item.Icon;

                gameObject.SetActive(true);
            }
            else
            {
                gameObject.SetActive(false);
            }
        }

        public override void OnPointerUp(PointerEventData data)
        {
            base.OnPointerUp(data);

            onClick?.Invoke(m_Item);
        }

        public void UpdateRequirementsUI(IInventory inventory)
        {
            if (m_Item == null)
                return;

            var requirements = m_Item.Crafting.Blueprint;

            for (int i = 0;i < m_Requirements.Length;i++)
            {
                if(i > requirements.Length - 1)
                {
                    m_Requirements[i].gameObject.SetActive(false);
                    continue;
                }

                m_Requirements[i].gameObject.SetActive(true);

                CraftRequirement requirement = requirements[i];
                ItemInfo requiredItem = requirement.Item.GetItem();

                if (requiredItem != null)
                {
                    int itemCount = inventory.GetItemCount(requirement.Item);
                    bool hasEnoughMaterials = itemCount >= requirement.Amount;
                    m_Requirements[i].Display(requiredItem.Icon, "x" + requirement.Amount, hasEnoughMaterials ? m_HasEnoughColor : m_NotEnoughColor);
                }
            }
        }
    }
}
