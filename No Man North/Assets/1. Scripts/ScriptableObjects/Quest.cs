using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

[System.Serializable]
[CreateAssetMenu(fileName = "Quest", menuName = "Quests/New Quest", order = 1)]
public class Quest : ScriptableObject {
    public string title;
    public UnityEvent onComplete;

    //Determines initial active states of subquests
    public enum QuestType {
        Sequential, //Sequential: Subquests get activated one by one, each subquest activates next one on completion.
        Parallel    //Parallel: Subquests get activated all at once.
    }
    public QuestType questType;

    public SubQuest[] subQuests;

    public Action<SubQuest> startSQC;
    public Action<SubQuest> stopSQC;

    public void Initialize() {
        if (subQuests == null || subQuests.Length == 0) {
            Debug.LogError("Quest not configured properly");
            return;
        }
        for (int i = 0; i < subQuests.Length; i++) {
            //Instantiates subquest and replaces type version
            SubQuest subQuest = Instantiate(subQuests[i]);
            subQuests[i] = subQuest;

            if (i == 0) {
                subQuest.Initialize(true);
            } else {
                switch (questType) {
                    case QuestType.Sequential:
                        subQuest.Initialize(false);
                        subQuests[i - 1].onComplete.AddListener(subQuest.Activate);
                        break;
                    case QuestType.Parallel:
                        subQuest.Initialize(true); break;
                }
            }
            if (subQuest.useCoroutine && startSQC != null && stopSQC != null) {
                subQuest.onComplete.AddListener(() => stopSQC(subQuest));
                startSQC(subQuest);
            }
            subQuest.onActivate.AddListener(() => UpdateStatus(false));
            subQuest.onComplete.AddListener(() => UpdateStatus(true));
        }
        UpdateStatus(false);
    }

    public void UpdateStatus(bool checkComplete) {
        if (checkComplete) {
            bool complete = true;
            foreach (SubQuest subQuest in subQuests) {
                if (subQuest.state != SubquestState.Completed) {
                    complete = false;
                    break;
                }
            }
            if (complete) {
                onComplete.Invoke();
                QuestManager.Instance.RemoveQuest(this);
            }
        }
        QuestManager.Instance.questsUpdated.Invoke();
    }
}
