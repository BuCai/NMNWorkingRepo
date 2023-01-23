using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro
{
    [CustomPropertyDrawer(typeof(BuildMaterialReference))]
    public class BuildMaterialReferenceDrawer : PopupIdElementsDrawer
    {
        private static string[] m_AllNames;

        private bool m_IsInitialized;


        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            int databaseCount = 1;

            if (!m_IsInitialized)
                databaseCount = ItemDatabase.GetInstanceCount();

            if (databaseCount == 1)
            {
                base.OnGUI(position, property, label);
                m_IsInitialized = true;
                return;
            }

            string errorMessage = databaseCount == 0 ? "No build materials databases found in the resources folder" : "Multiple build materials databases found in the resources folder, make sure there's only one.";
            EditorGUI.HelpBox(position, errorMessage, MessageType.Error);
        }

        protected override string[] GetElementNames()
        {
            if (m_AllNames == null)
                m_AllNames = BuildMaterialsDatabase.GetBuildingMaterialNames();

            return m_AllNames;
        }

        protected override string[] GetElementNamesFullPath()
        {
            if (m_AllNames == null)
                m_AllNames = BuildMaterialsDatabase.GetBuildingMaterialNames();

            return m_AllNames;
        }

        protected override int IdOfElement(int index) => BuildMaterialsDatabase.GetBuildingMaterialAtIndex(index).Id;
        protected override int IndexOfElement(int id) => BuildMaterialsDatabase.GetIndexOfBuildingMaterial(id);
    }
}