using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    [CustomEditor(typeof(ObjectInspectControllerUI))]
    public class ObjectInspectorControllerUIEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();

            STPEditorGUI.Separator();

            EditorGUILayout.BeginHorizontal();

            if (GUILayout.Button("Show All Inspectable Panels"))
            {
                ShowAllChildPanels(true);
                return;
            }

            if (GUILayout.Button("Hide All Inspectable Panels"))
                ShowAllChildPanels(false);

            EditorGUILayout.EndHorizontal();
        }

        private void ShowAllChildPanels(bool show)
        {
            var obj = (target as Component).gameObject;

            if (obj == null)
                return;

            var panels = obj.GetComponentsInChildren<PanelUI>();

            foreach (var panel in panels)
            {
                panel.CanvasGroup.alpha = show ? 1f : 0f;
                panel.CanvasGroup.blocksRaycasts = show;
            }
        }
    }
}