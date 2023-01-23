using UnityEditor;
using UnityEngine;
using Toolbox.Editor;

namespace SurvivalTemplatePro.WieldableSystem
{
    [CanEditMultipleObjects]
    [CustomEditor(typeof(Wieldable), true)]
    public class WieldableEditor : ToolboxEditor
    {
        protected Wieldable m_Wieldable;

        public override void DrawCustomInspector()
        {
            base.DrawCustomInspector();

            if (Application.isPlaying || !Application.isEditor)
                return;

            GUILayout.BeginVertical();

            DrawEventHandlerButton();
            DrawWieldableItemReferenceButton();

            GUILayout.EndVertical();

            STPEditorGUI.Separator();

            GUILayout.BeginHorizontal();

            if (GUILayout.Button("Show Model"))
                m_Wieldable.SetVisibility(true);

            if (GUILayout.Button("Hide Model"))
                m_Wieldable.SetVisibility(false);

            GUILayout.EndHorizontal();
        }

        private void DrawEventHandlerButton() 
        {
            if (m_Wieldable.GetComponent<STPEventHandler>() != null)
                return;

            STPEditorGUI.Separator();
            GUI.color = new Color(0.8f, 0.8f, 0.8f, 1f);

            GUILayout.Label("Add an ''Event Handler'' component (if neccesary)", EditorStyles.helpBox);
            if (GUILayout.Button("Add ''Event Handler''"))
            {
                m_Wieldable.gameObject.AddComponent<STPEventHandler>();
                EditorUtility.SetDirty(m_Wieldable);
            }

            GUI.color = Color.white;
        }

        private void DrawWieldableItemReferenceButton()
        {
            if (m_Wieldable.GetComponent<STPWieldableItemReference>() != null)
                return;

            STPEditorGUI.Separator();
            GUI.color = new Color(0.8f, 0.8f, 0.8f, 1f);

            GUILayout.Label("Add a ''Wieldable Item Reference'' component (used only by inventory based wieldables).", EditorStyles.helpBox);
            if (GUILayout.Button("Add ''Wieldable Item Reference''"))
            {
                m_Wieldable.gameObject.AddComponent<STPWieldableItemReference>();
                EditorUtility.SetDirty(m_Wieldable);
            }

            GUI.color = Color.white;
        }

        protected virtual void OnEnable() => m_Wieldable = target as Wieldable;
    }
}
