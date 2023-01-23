using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro
{
    [CustomPropertyDrawer(typeof(ItemPropertyReference))]
    public class ItemPropertyReferenceDrawer : PopupIdElementsDrawer
    {
        private string[] m_AllItems;
        private string[] m_AllItemsFullPath;

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

            string errorMessage = databaseCount == 0 ? "No item databases found in the resources folder" : "Multiple item databases found in the resources folder, make sure there's only one.";
            EditorGUI.HelpBox(position, errorMessage, MessageType.Error);
        }

        protected override string[] GetElementNames()
        {
            if (m_AllItems == null)
                m_AllItems = ItemDatabase.GetPropertyNames();

            return m_AllItems;
        }

        protected override string[] GetElementNamesFullPath()
        {
            if (m_AllItemsFullPath == null)
                m_AllItemsFullPath = ItemDatabase.GetPropertyNames();

            return m_AllItemsFullPath;
        }

        protected override int IdOfElement(int index) => ItemDatabase.GetPropertyAtIndex(index).Id;
        protected override int IndexOfElement(int id) => ItemDatabase.GetIndexOfProperty(id);
    }
}