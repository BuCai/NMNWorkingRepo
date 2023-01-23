using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro.InventorySystem
{
    [CustomPropertyDrawer(typeof(ItemGenerator))]
    public class ItemGeneratorDrawer : PropertyDrawer
    {
		public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
		{
			var method = property.FindPropertyRelative("Method");
			var category = property.FindPropertyRelative("Category");
			var item = property.FindPropertyRelative("SpecificItem");
			var minCount = property.FindPropertyRelative("MinCount");
			var maxCount = property.FindPropertyRelative("MaxCount");

			position.x -= 4f;
			float spacing = 4f;

			EditorGUI.indentLevel -= 1;

			// Method
			position.height = 16f;
			position.y += spacing;
			position.x += 16f;
			position.width -= 16f;
			EditorGUI.PropertyField(position, method);

			ItemGenerationMethod methodParsed = (ItemGenerationMethod)method.enumValueIndex;

			if (methodParsed == ItemGenerationMethod.RandomFromCategory)
			{
				// Category
				position.y = position.yMax + spacing;
				EditorGUI.PropertyField(position, category);
			}
			else if (methodParsed == ItemGenerationMethod.Specific)
			{
				// Item
				position.y = position.yMax + spacing;
				EditorGUI.PropertyField(position, item);
			}

			// Min Count
			position.y = position.yMax + spacing;
			EditorGUI.PropertyField(position, minCount);

			// Max Count
			position.y = position.yMax + spacing;
			EditorGUI.PropertyField(position, maxCount);

			EditorGUI.indentLevel += 1;
		}

		public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
		{
			ItemGenerationMethod method = (ItemGenerationMethod)property.FindPropertyRelative("Method").enumValueIndex;

			float defaultHeight = 10f;
			float height = 40;
			float spacing = 4f;

			if (method == ItemGenerationMethod.Random)
				height += (defaultHeight + spacing) * 2;
			else
				height += (defaultHeight + spacing) * 3;

			return height;
		}
	}
}