using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro
{
    [CustomEditor(typeof(MoveToSpawnPoint))]
    public class MoveToSpawnPointEditor : Editor
    {
        private MoveToSpawnPoint m_Target;


        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            if (Application.isPlaying)
                return;

            STPEditorGUI.Separator();

            if (GUILayout.Button("Move to random spawn point"))
                m_Target.MoveToRandomPoint();
        }

        private void OnEnable()
        {
            m_Target = serializedObject.targetObject as MoveToSpawnPoint;
        }
    }
}