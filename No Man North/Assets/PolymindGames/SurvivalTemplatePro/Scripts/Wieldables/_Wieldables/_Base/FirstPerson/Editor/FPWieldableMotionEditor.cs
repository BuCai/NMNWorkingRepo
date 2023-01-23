using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [CustomEditor(typeof(FPWieldableMotion))]
    public class FPWieldableMotionEditor : STPEventsListenerEditor
    {
        public override void DrawCustomInspector()
        {
            base.DrawCustomInspector();

            if (Application.isPlaying)
                GUI.enabled = false;

            GUI.color = new Color(0.85f, 0.85f, 0.85f, 1f);

            EditorGUILayout.HelpBox("When playing, expand the desired state and click the 'Visualize' button to edit the state's motion.", MessageType.Info);

            GUI.color = Color.white;

            if (Application.isPlaying)
                GUI.enabled = true;
        }
    }
}