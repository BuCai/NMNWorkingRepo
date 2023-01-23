using Toolbox.Editor;
using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    [CustomEditor(typeof(InventoryPanelsManagerUI))]
    public class InventoryPanelsManagerUIEditor : ToolboxEditor
    {
        public override void DrawCustomInspector()
        {
            base.DrawCustomInspector();

            EditorGUILayout.Space();

            STPEditorGUI.Separator();

            EditorGUILayout.BeginHorizontal();

            if (GUILayout.Button("Show All the Inventory Panels"))
            {
                ShowAllChildPanels(true);
                return;
            }

            if (GUILayout.Button("Hide All the Inventory Panels"))
                ShowAllChildPanels(false);

            EditorGUILayout.EndHorizontal();
        }

        private void ShowAllChildPanels(bool show) 
        {
            var obj = (target as Component).gameObject;

            if (obj == null)
                return;

            var panels = (target as InventoryPanelsManagerUI).PanelActivators;

            foreach (var activator in panels)
            {
                activator.Panel.CanvasGroup.alpha = show ? 1f : 0f;
                activator.Panel.CanvasGroup.blocksRaycasts = show;
            }
        }
    }
}