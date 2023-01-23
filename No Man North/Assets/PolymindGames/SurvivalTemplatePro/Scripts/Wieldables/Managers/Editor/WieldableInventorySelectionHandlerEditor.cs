using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [CustomEditor(typeof(WieldableInventorySelectionHandler))]
    public class WieldableInventorySelectionHandlerEditor : CharacterBehaviourEditor
    {
        private WieldableInventorySelectionHandler m_Handler;


        public override void DrawCustomInspector()
        {
            base.DrawCustomInspector();

            GUI.enabled = !string.IsNullOrEmpty(m_Handler.WieldableLoadFolder);

            if (m_Handler.WieldableLoadFolder != null && GUILayout.Button("Load wieldables from selected folder"))
                LoadWieldablesAtPath(m_Handler.WieldableLoadFolder);

            GUI.enabled = true;
        }

        protected override void OnEnable()
        {
            base.OnEnable();

            m_Handler = target as WieldableInventorySelectionHandler;
        }

        private void LoadWieldablesAtPath(string path)
        {
            var assetGuids = AssetDatabase.FindAssets("t:prefab", new string[] { path });

            foreach (var assetGuid in assetGuids)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(assetGuid);

                if (assetPath.Contains(path))
                {
                    var asset = AssetDatabase.LoadAssetAtPath<GameObject>(assetPath);

                    if (asset != null)
                    {
                        m_Handler.AddCustomWieldable(asset.GetComponent<STPWieldableItemReference>());
                        EditorUtility.SetDirty(m_Handler);
                    }
                }
            }
        }
    }
}