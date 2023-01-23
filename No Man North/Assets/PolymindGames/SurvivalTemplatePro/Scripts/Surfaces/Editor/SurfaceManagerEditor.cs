using UnityEngine;
using UnityEditor;
using Toolbox.Editor;

namespace SurvivalTemplatePro.Surfaces
{
    [CustomEditor(typeof(SurfaceManager))]
    public class SurfaceManagerEditor : ToolboxEditor
    {
        public override void DrawCustomInspector()
        {
            base.DrawCustomInspector();

            EditorGUILayout.Space();

            if (GUILayout.Button("Open Surface Editor", EditorStyles.miniButtonMid))
                SurfaceManagementWindow.Init();
        }
    }
}