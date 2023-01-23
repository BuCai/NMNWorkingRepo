using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

[RequireComponent(typeof(VerticalLayoutGroup))]
public class QuestDisplayerUI : MonoBehaviour {

    [SerializeField] private GameObject questTemplatePrefab;
    [SerializeField] private GameObject subQuestTemplatePrefab;

    [SerializeField] private Color pendingSQColor = Color.gray;

    private void Awake() {
        if (QuestManager.Instance != null) {
            QuestManager.Instance.questsUpdated.AddListener(QuestUpdated);
            QuestUpdated();
        }
    }
    public void QuestUpdated() {
        Clear();
        foreach (Quest quest in QuestManager.Instance.GetActiveQuests()) {
            GameObject questObj = Instantiate(questTemplatePrefab, transform);
            questObj.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = quest.title;
            foreach (SubQuest subQuest in quest.subQuests) {
                GameObject subQuestObj = Instantiate(subQuestTemplatePrefab, questObj.transform);
                TextMeshProUGUI subQuestText = subQuestObj.GetComponent<TextMeshProUGUI>();
                subQuestText.text = "• " + subQuest.title;
                if (subQuest.state == SubquestState.Pending) {
                    subQuestText.color = pendingSQColor;
                } else if (subQuest.state == SubquestState.Completed) {
                    subQuestText.fontStyle = FontStyles.Strikethrough;
                }
            }
        }
        LayoutRebuilder.ForceRebuildLayoutImmediate((RectTransform)transform);
    }

    private void Clear() {
        foreach (Transform child in transform) {
            Destroy(child.gameObject);
        }
    }
}
