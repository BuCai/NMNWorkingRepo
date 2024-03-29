﻿using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro
{
    [CustomPropertyDrawer(typeof(LayerSelectorAttribute))]
    public class LayerSelectorDrawer : PropertyDrawer
    {
        public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
        {
            if (property.propertyType != SerializedPropertyType.Integer)
                EditorGUI.HelpBox(position, "The Layer attribute works just on integers.", MessageType.Error);
            else
                property.intValue = EditorGUI.LayerField(position, label, property.intValue);
        }
    }
}