using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using SurvivalTemplatePro;

#if UNITY_EDITOR
using UnityEditor;
using Toolbox.Editor;
#endif

public enum SubquestState {
    Pending,
    Active,
    Completed
}

public class QuestManager : Singleton<QuestManager> {
    public Quest[] initialQuests; //First quest types to activate

    [HideInInspector] public UnityEvent questsUpdated;

    private void Awake() {
        LevelManager.onGameLoaded += OnGameLoaded;
    }
    private void OnDestroy() {
        LevelManager.onGameLoaded -= OnGameLoaded;
    }

    private void OnGameLoaded() {
        foreach (Quest quest in initialQuests) {
            ActivateQuest(quest);
        }
    }

    private List<Quest> activeQuests = new List<Quest>();

    public Quest[] GetActiveQuests() {
        return activeQuests.ToArray();
    }

    //Creates an instance of quest type and adds it to active quests
    public void ActivateQuest(Quest questType) {
        Quest quest = Instantiate(questType);
        activeQuests.Add(quest);
        quest.startSQC = StartSQC;
        quest.stopSQC = StopSQC;
        quest.Initialize();
    }

    //Returns true if quest was in the list of active quests and was removed successfully
    //Returns false otherwise
    public bool RemoveQuest(Quest quest) {
        return activeQuests.Remove(quest);
    }

    //Gives quests the ability to start subquest coroutines on certain subquest types
    private void StartSQC(SubQuest subQuest) {
        if (subQuest.state != SubquestState.Active || !subQuest.useCoroutine) {
            return;
        }
        StartCoroutine(subQuest.SQCoroutine());
    }
    private void StopSQC(SubQuest subQuest) {
        StopCoroutine(subQuest.SQCoroutine());
    }

    public void DisplayDebugInfo() {
        GUIStyle style = EditorStyles.centeredGreyMiniLabel;
        style.alignment = TextAnchor.MiddleLeft;

        EditorGUILayout.LabelField("Active Quests", EditorStyles.boldLabel);
        EditorGUILayout.Space();
        foreach (Quest quest in activeQuests) {
            EditorGUILayout.LabelField(quest.title, EditorStyles.boldLabel);
            foreach (SubQuest subQuest in quest.subQuests) {
                EditorGUILayout.LabelField("- " + subQuest.title + " (" + subQuest.state + ")", style);
            }
        }
    }

}

#if UNITY_EDITOR
[CustomEditor(typeof(QuestManager))]
public class QuestManagerEditor : ToolboxEditor {
    private QuestManager questManager;
    private void OnEnable() {
        questManager = serializedObject.targetObject as QuestManager;
    }

    public override void DrawCustomInspector() {
        base.DrawCustomInspector();
        EditorGUILayout.Space();
        questManager.DisplayDebugInfo();
        GUI.changed = true;
    }
}
#endif
