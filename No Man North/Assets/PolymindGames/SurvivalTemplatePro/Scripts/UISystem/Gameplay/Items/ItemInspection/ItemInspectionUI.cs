using SurvivalTemplatePro.InputSystem;
using System;
using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class ItemInspectionUI : PlayerUIBehaviour
    {
        [SerializeField]
        private CanvasGroup m_CanvasGroup;

        [SerializeField]
        private RectTransform m_RectTransform;

        [Space]

        [SerializeField]
        private Text m_NameText;

        [SerializeField]
        private Text m_DescriptionText;

        [SerializeField]
        private Image m_ItemIcon;

        [SerializeField]
        private GameObject m_StackObject;

        [SerializeField]
        private Text m_StackText;

        [SerializeField]
        private Text m_WeightText;

        [SerializeField]
        private string m_WeightSuffix = "KG";

        private bool m_IsActive;
        private ItemSlotUI m_SlotUI;
        private IInventoryInspectManager m_InventoryInspection;


        public override void OnAttachment()
        {
            GetModule(out m_InventoryInspection);

            m_CanvasGroup.alpha = 0f;
            m_InventoryInspection.onInspectEnded += OnInventoryInspectionEnded;
        }

        public override void OnDetachment()
        {
            m_InventoryInspection.onInspectEnded -= OnInventoryInspectionEnded;
        }

        private void OnInventoryInspectionEnded()
        {
            m_CanvasGroup.alpha = 0f;
            m_IsActive = false;
        }

        public void OnPointerMoved(PointerRaycastEventParams pointerParams)
        {
            m_SlotUI = pointerParams.SlotUI;
            m_IsActive = m_SlotUI != null && m_SlotUI.HasItem;

            UpdateItemInfo(m_SlotUI);
            UpdatePosition(pointerParams.RaycastPosition);
        }

        public void UpdateItemInfo(ItemSlotUI slot)
        {
            m_SlotUI = slot;

            if (m_SlotUI == null || m_SlotUI.Item == null)
                return;

            var itemInfo = slot.Item.Info;

            m_NameText.text = itemInfo.Name;
            m_ItemIcon.sprite = itemInfo.Icon;

            m_StackObject.SetActive(slot.Item.CurrentStackSize > 1);
            m_StackText.text = slot.Item.CurrentStackSize > 1 ? ("x" + slot.Item.CurrentStackSize) : string.Empty;

            m_WeightText.text = $"{Math.Round(itemInfo.Weight * slot.Item.CurrentStackSize, 2)} {m_WeightSuffix}";

            m_DescriptionText.text = itemInfo.Description;
            SetHeightOfText(m_DescriptionText, m_DescriptionText.text, true);
        }

        private float SetHeightOfText(Text text, string myString, bool autoResizeRect)
        {
            // This is the height that the text would fit at the current font height setting (see the inspector)
            TextGenerator textGen = new TextGenerator();
            TextGenerationSettings generationSettings = text.GetGenerationSettings(text.rectTransform.rect.size);

            float height = textGen.GetPreferredHeight(myString, generationSettings);

            if (autoResizeRect)
            {
                var rt = text.rectTransform;

                // Resize the rect to the size of your text
                rt.sizeDelta = new Vector2(rt.rect.width, height);
            }

            return height;
        }

        private void FixedUpdate()
        {
            if (!IsInitialized || m_InventoryInspection.InspectState == InventoryInspectState.None)
                return;

            m_CanvasGroup.alpha = Mathf.MoveTowards(m_CanvasGroup.alpha, (m_IsActive && m_SlotUI != null ? 1f : 0f), Time.fixedDeltaTime * 5f);
        }

        private void UpdatePosition(Vector2 pointerPosition, bool forceUpdate = false)
        {
            if (m_RectTransform != null)
            {
                if (RectTransformUtility.ScreenPointToLocalPointInRectangle(m_RectTransform.parent as RectTransform, pointerPosition, null, out Vector2 position))
                    m_RectTransform.anchoredPosition = position;
            }
        }
    }
}