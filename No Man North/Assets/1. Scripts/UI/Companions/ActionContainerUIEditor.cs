#if UNITY_EDITOR
using SurvivalTemplatePro.CompanionSystem;
using SurvivalTemplatePro.UISystem;
using Toolbox.Editor;
using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro {
    [CanEditMultipleObjects]
    [CustomEditor(typeof(ActionContainerUI))]
    public class ActionContainerUIEditor : ToolboxEditor {
        private SerializedProperty m_SlotTemplate;
        private SerializedProperty m_SlotsParent;


        public override void DrawCustomInspector() {
            serializedObject.Update();

            base.DrawCustomInspector();

            if (!Application.isPlaying) {
                EditorGUILayout.Space();

                if (!serializedObject.isEditingMultipleObjects && GUILayout.Button("Spawn Default Slots"))
                    (serializedObject.targetObject as ActionContainerUI).GenerateSlots();
            }

            if (!m_SlotTemplate.objectReferenceValue || !m_SlotsParent.objectReferenceValue)
                EditorGUILayout.HelpBox("Make sure a slot template and parent are assigned!", MessageType.Error);

            serializedObject.ApplyModifiedProperties();
        }

        private void OnEnable() {
            m_SlotTemplate = serializedObject.FindProperty("m_SlotTemplate");
            m_SlotsParent = serializedObject.FindProperty("m_SlotsParent");
        }
    }
}
#endif