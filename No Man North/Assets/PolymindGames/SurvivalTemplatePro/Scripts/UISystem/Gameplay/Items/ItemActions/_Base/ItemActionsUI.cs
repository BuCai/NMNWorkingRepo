using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class ItemActionsUI : MonoBehaviour
    {
        [SerializeField]
        private Button m_ActionBtnTemplate;

        private ItemActionUI[] m_Actions;

        private ItemSlotUI m_ItemSlot;
        private Button[] m_ActionButtons;


        public void UpdateEnabledActions(ItemSlotUI slot)
        {
            if (slot == null || slot.Item == null)
                return;

            m_ItemSlot = slot;
            bool isSlotViable = m_ItemSlot != null && m_ItemSlot.HasItem;
            if (m_Actions == null || m_Actions.Length == 0) {
                return;   
            }
            for (int i = 0; i < m_Actions.Length; i++)
            {
                bool isViable = isSlotViable && m_Actions[i].IsViableForItem(m_ItemSlot);
                m_Actions[i].gameObject.SetActive(isViable);
            }
        }

        private void Awake()
        {
            m_Actions = GetComponentsInChildren<ItemActionUI>(true);
            m_ActionButtons = new Button[m_Actions.Length];

            for (int i = 0; i < m_Actions.Length; i++)
            {
                var actionRect = m_Actions[i].GetComponent<RectTransform>();
                var actionBtnRect = m_ActionBtnTemplate.GetComponent<RectTransform>();

                actionRect.anchorMin = actionBtnRect.anchorMin;
                actionRect.anchorMax = actionBtnRect.anchorMax;
                actionRect.anchoredPosition = actionBtnRect.anchoredPosition;
                actionRect.sizeDelta = actionBtnRect.sizeDelta;
                actionRect.pivot = actionBtnRect.pivot;
            }

            for (int i = 0; i < m_Actions.Length; i++)
            {
                var action = m_Actions[i];

                Button actionBtn = Instantiate(m_ActionBtnTemplate.gameObject, action.transform).GetComponent<Button>();
                actionBtn.GetComponentInChildren<Text>().text = action.ActionName;
                m_ActionButtons[i] = actionBtn;

                actionBtn.transform.FindDeepChild("Icon").GetComponent<Image>().sprite = m_Actions[i].ActionIcon;

                actionBtn.onClick.AddListener(() => action.StartAction(m_ItemSlot));
                action.gameObject.SetActive(false);
            }
        }
    }
}