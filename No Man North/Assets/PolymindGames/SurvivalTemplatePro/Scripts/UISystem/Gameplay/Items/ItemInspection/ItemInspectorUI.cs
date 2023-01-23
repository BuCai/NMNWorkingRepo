using SurvivalTemplatePro.InventorySystem;
using System;
using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class ItemInspectorUI : MonoBehaviour
    {
        [SerializeField]
        private PanelUI m_InspectorPanel;

        [Space]

        [SerializeField]
        private Text m_NameText;

        [SerializeField]
        private Text m_DescriptionText;

        [SerializeField]
        private Image m_ItemIcon;

        [SerializeField]
        private Text m_WeightText;

        [SerializeField]
        private string m_WeightSuffix = "KG";


        public void UpdateItemInspector(ItemSlotUI slotUI)
        {
            if (slotUI != null && slotUI.HasItem)
            {
                m_InspectorPanel.Show(true);
                UpdateItemInfo(slotUI.Item);
            }
            else
            {
                m_InspectorPanel.Show(false);
            }
        }

        private void UpdateItemInfo(IItem item) 
        {
            m_NameText.text = item.Name;
            m_ItemIcon.sprite = item.Info.Icon;

            m_WeightText.text = $"{Math.Round(item.Info.Weight * item.CurrentStackSize, 2)} {m_WeightSuffix}";

            m_DescriptionText.text = item.Info.Description;
        }
    }
}