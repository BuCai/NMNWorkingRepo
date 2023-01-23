using Toolbox.Editor;
using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro.WorldManagement {
    [CustomEditor(typeof(WorldManager))]
    public class WorldManagerEditor : ToolboxEditor {
        private WorldManager m_WorldManager;


        public override void DrawCustomInspector() {
            base.DrawCustomInspector();

            STPEditorGUI.Separator();
            EditorGUILayout.Space();

            GUILayout.Label("Debugging", EditorStyles.boldLabel);

            if (Application.isPlaying) {
                if (GUILayout.Button("Cycle weather in current stage")) {
                    m_WorldManager.CycleWeather();
                }
                if (GUILayout.Button("Advance weather stage")) {
                    m_WorldManager.AdvanceWeatherStage();
                }
            } else {
                EditorGUILayout.HelpBox("Debug info will be shown at play-time!", MessageType.Info);
                return;
            }

            m_WorldManager.DisplayDebugInfo();

            GUI.changed = true;
        }

        private void OnEnable() {
            m_WorldManager = serializedObject.targetObject as WorldManagement.WorldManager;
        }
    }
}
