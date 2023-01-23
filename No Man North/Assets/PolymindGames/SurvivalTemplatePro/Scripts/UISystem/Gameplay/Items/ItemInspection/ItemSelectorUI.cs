using SurvivalTemplatePro.InputSystem;
using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public class ItemSelectorUI : MonoBehaviour
    {
        [SerializeField]
        private RectTransform m_SelectionFrame;

        [Space]

        [SerializeField]
        private SlotEvent m_SelectedSlotChangedCallback;

        private ItemSlotUI m_RaycastedSlot;
        private GameObject m_RaycastedObject;

        private ItemSlotUI m_SelectedSlot;

        private float m_NextTimeCanSelect;
        private bool m_IsDragging;


        #region Input (Called from Unity Events)

        public void DragStart(DragEventParams dragParams)
        {
            m_IsDragging = true;

            if (m_SelectedSlot != null && !m_SelectedSlot.HasItem)
                SelectSlot(null);
        }

        public void OnDragEnd(DragEventParams dragParams) 
        {
            m_IsDragging = false;
            m_NextTimeCanSelect = Time.time + 0.3f;
        }

        public void HideFrame() 
        {
            if (m_SelectionFrame != null)
            {
                if (m_SelectionFrame.gameObject.activeSelf)
                    m_SelectionFrame.gameObject.SetActive(false);

                m_SelectionFrame.SetParent(transform);
            }
        }

        public void OnLeftClick()
        {
            if (Time.time < m_NextTimeCanSelect || m_IsDragging)
                return;

            if (m_RaycastedSlot == null && m_RaycastedObject != null)
                return;

            SelectSlot(m_RaycastedSlot);
        }

        public void OnPointerMoved(PointerRaycastEventParams pointerParams)
        {
            m_RaycastedSlot = pointerParams.SlotUI;
            m_RaycastedObject = pointerParams.RaycastObject;
        }

        #endregion

        private void SelectSlot(ItemSlotUI slotUI) 
        {
            if ((m_SelectedSlot == null && slotUI == null) || (slotUI != null && slotUI.GetComponent<DisableSlotSelection>() != null))
                return;

            if (m_SelectedSlot != null && m_SelectedSlot.ItemSlot != null)
                m_SelectedSlot.ItemSlot.onChanged -= OnSlotChanged;

            m_SelectedSlot = slotUI;
            m_SelectedSlotChangedCallback?.Invoke(m_SelectedSlot);

            if (m_SelectedSlot != null && m_SelectedSlot.ItemSlot != null)
                m_SelectedSlot.ItemSlot.onChanged += OnSlotChanged;

            UpdateSelectionFrame();
        }

        private void OnSlotChanged(IItemSlot slot, ItemSlotChangeType changeType)
        {
            m_SelectedSlotChangedCallback?.Invoke(m_SelectedSlot);
        }

        private void UpdateSelectionFrame()
        {
            if (m_SelectionFrame != null)
            {
                if (m_SelectedSlot != null && m_SelectedSlot.HasItem && m_SelectedSlot.GetComponent<RaycastMask>() == null)
                {
                    if (!m_SelectionFrame.gameObject.activeSelf)
                        m_SelectionFrame.gameObject.SetActive(true);

                    m_SelectionFrame.SetParent(m_SelectedSlot.transform);
                    m_SelectionFrame.anchoredPosition = Vector2.zero;
                    m_SelectionFrame.localRotation = Quaternion.identity;

                    m_SelectionFrame.sizeDelta = m_SelectedSlot.GetComponent<RectTransform>().sizeDelta;
                }
                else
                {
                    if (m_SelectionFrame.gameObject.activeSelf)
                        m_SelectionFrame.gameObject.SetActive(false);
                }
            }
        }

        private void Awake()
        {
            UpdateSelectionFrame();
        }
    }
}