using System.Collections.Generic;
using SurvivalTemplatePro.CompanionSystem;
using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem {
    public class CompanionWheelUI : PlayerUIBehaviour, IItemWheelUI {
        public ItemWheelState ItemWheelState => m_ActionWheelState;
        public bool IsVisible => m_Panel.IsVisible;

        [SerializeField] private string m_ContainerName;

        [SerializeField] private Animator m_Animator;

        [SerializeField] private PanelUI m_Panel;

        [SerializeField] private CanvasGroup m_CanvasGroup;

        [Title("Wheel Feel")]
        [SerializeField, Range(0.1f, 25f)]
        private float m_Sensitivity = 3f;

        [SerializeField, Range(0.1f, 25f)] private float m_Range = 3f;

        [Title("Item Info")][SerializeField] private Text m_DescriptionText;

        [SerializeField] private GameObject m_DescriptionPanel;

        [SerializeField] private Text m_ItemNameText;

        [Title("Misc")][SerializeField] private RectTransform m_DirectionArrow;

        [Space][SerializeField] private Vector2 m_OffsetWhenSelecting;

        private int m_LastSelectedSlot = -1;
        private int m_HighlightedSlot = -1;

        private Vector2 m_CursorPos;
        private Vector2 m_DirectionOfSelection;

        private ItemWheelState m_ActionWheelState = ItemWheelState.None;
        private IWieldableSelectionHandler m_SelectionHandler;
        private IPauseHandler m_PauseHandler;

        private ActionWheelSlotUI[] m_WheelSlots;

        private readonly Dictionary<ActionWheelSlotUI, IActionSlot> m_SlotDictionary =
            new Dictionary<ActionWheelSlotUI, IActionSlot>();


        public void SetItemWheelState(ItemWheelState wheelState) {
            if (m_ActionWheelState != wheelState) {
                m_ActionWheelState = wheelState;

                switch (m_ActionWheelState) {
                    case ItemWheelState.SelectItems: {
                            m_Animator.Play("Hide", 0, 1f);
                            m_CanvasGroup.blocksRaycasts = false;
                            m_CanvasGroup.interactable = false;

                            m_DescriptionPanel.SetActive(true);
                            GetComponent<RectTransform>().anchoredPosition = m_OffsetWhenSelecting;

                            break;
                        }
                    case ItemWheelState.InsertItems: break;
                }
            }
        }

        public void SetItemWheelState(int wheelState) => SetItemWheelState((ItemWheelState)wheelState);

        public override void OnAttachment() {
            m_SlotDictionary.Clear();

            GetModule(out m_PauseHandler);
            GetModule(out m_SelectionHandler);

            m_WheelSlots = GetComponentsInChildren<ActionWheelSlotUI>();
            GetComponent<RectTransform>().anchoredPosition = m_OffsetWhenSelecting;
            IActionContainer container = PlayerActions.GetContainerWithName(m_ContainerName);

            if (m_WheelSlots != null && m_WheelSlots.Length != 0 && container != null && container.Count != 0) {
                Debug.LogError("Wheel slots or container null");
                for (int i = 0; i < container.Count; i++) {
                    m_SlotDictionary.Add(m_WheelSlots[i], container[i]);
                    m_WheelSlots[i].LinkToSlot(container[i]);
                }
            }
        }

        public void StartInspection() {
            if (m_PauseHandler.PauseActive)
                return;

            m_Panel.Show(true);

            m_LastSelectedSlot = m_SelectionHandler.SelectedIndex;
            m_HighlightedSlot = m_SelectionHandler.SelectedIndex;

            // Set the highlight to the selected (or last selected) slot
            HandleSlotHighlighting(m_HighlightedSlot);

            m_PauseHandler.RegisterLocker(this, new PlayerPauseParams(false, true, true, true));
        }

        public void EndInspection() {
            m_Panel.Show(false);
            SelectSlot(m_HighlightedSlot);

            m_PauseHandler.UnregisterLocker(this);
        }

        public void UpdateSelection(Vector2 input) {
            if (!IsVisible || m_ActionWheelState == ItemWheelState.InsertItems)
                return;

            int highlightedSlot = GetHighlightedSlot(input);

            if (highlightedSlot != m_HighlightedSlot)
                HandleSlotHighlighting(highlightedSlot);
        }

        private int GetHighlightedSlot(Vector2 directionOfSelection) {
            directionOfSelection *= m_Range;

            if (directionOfSelection != Vector2.zero)
                m_DirectionOfSelection = Vector2.Lerp(m_DirectionOfSelection, directionOfSelection,
                    Time.deltaTime * m_Sensitivity);

            m_CursorPos = m_DirectionOfSelection;

            float angle = -Vector2.SignedAngle(Vector2.up, m_CursorPos);

            if (angle < 0)
                angle = 360f - Mathf.Abs(angle);

            if (m_DirectionArrow != null)
                m_DirectionArrow.rotation = Quaternion.Euler(0f, 0f, -angle);

            angle = 360f - angle;

            float angleBetweenSlots = 360f / m_WheelSlots.Length;

            angle -= angleBetweenSlots / 2;

            if (angle > 360f)
                angle -= 360f;

            if (!(angle + angleBetweenSlots / 2 > 360 - angleBetweenSlots / 2))
                return Mathf.Clamp(Mathf.RoundToInt((angle + angleBetweenSlots / 2) / angleBetweenSlots), 0,
                    m_WheelSlots.Length - 1);
            return 0;
        }

        private void HandleSlotHighlighting(int targetSlotIndex) {
            m_WheelSlots[targetSlotIndex].SetSlotHighlights(ActionWheelSlotUI.SelectionGraphicState.Highlighted);
            m_WheelSlots[targetSlotIndex].Select();

            // Disable the previous slot only if it's not the selected one
            if (m_LastSelectedSlot != m_HighlightedSlot)
                m_WheelSlots[m_HighlightedSlot].Deselect();

            m_WheelSlots[m_HighlightedSlot].SetSlotHighlights(ActionWheelSlotUI.SelectionGraphicState.Normal);

            m_HighlightedSlot = targetSlotIndex;
            ShowSlotInfo(m_WheelSlots[targetSlotIndex]);
        }

        private void SelectSlot(int highlightedSlot) {
            m_SelectionHandler.SelectAtIndex(highlightedSlot);
            // Activate ability
            m_SlotDictionary.TryGetValue(m_WheelSlots[highlightedSlot], out IActionSlot slot);
            slot?.Action?.Activate();

            // Remove highlight from previous slot
            if (highlightedSlot != m_LastSelectedSlot) {
                m_WheelSlots[m_LastSelectedSlot].Deselect();
                m_WheelSlots[m_LastSelectedSlot].SetSlotHighlights(ActionWheelSlotUI.SelectionGraphicState.Normal);
            }
        }

        private void ShowSlotInfo(ActionWheelSlotUI slot) {
            if (m_SlotDictionary.TryGetValue(slot, out IActionSlot actionSlot)) {
                if (actionSlot is { HasAction: true }) {
                    m_ItemNameText.text = actionSlot.Action.Name;
                    // m_DescriptionText.text = actionSlot.Action.Info.Description;
                    m_DescriptionText.text = actionSlot.Action.Description;
                } else {
                    m_ItemNameText.text = "";
                    m_DescriptionText.text = "";
                }
            }
        }
    }
}