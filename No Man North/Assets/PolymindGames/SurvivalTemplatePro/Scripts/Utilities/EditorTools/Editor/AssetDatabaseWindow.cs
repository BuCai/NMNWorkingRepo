using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace SurvivalTemplatePro
{
    public abstract class AssetDatabaseWindow<T> : EditorWindow where T : AssetDatabase<T>
    {
		protected bool IsInitialized { get; private set; } = false;
		protected T MainDatabase { get; private set; }

		private int m_DatabaseInstanceCount = 0;


        public virtual void OnGUI() 
        {
			if (m_DatabaseInstanceCount == 0)
				m_DatabaseInstanceCount = GetDatabaseInstanceCount();

			if (m_DatabaseInstanceCount == 1)
			{
				if (!IsInitialized)
				{
					MainDatabase = Resources.LoadAll<T>("")[0];
					InitializeDatabaseEditor(MainDatabase);
					IsInitialized = true;
				}

				if (MainDatabase != null && IsInitialized)
					DrawDatabaseEditor();

				return;
			}
			else if (m_DatabaseInstanceCount < 1)
			{
				GUILayout.FlexibleSpace();

				EditorGUILayout.HelpBox($"No {typeof(T).Name.ToUnityLikeNameFormat()} was found in the Resources folder!", MessageType.Error);
			}
			else if (m_DatabaseInstanceCount > 1)
			{
				GUILayout.FlexibleSpace();

				EditorGUILayout.HelpBox($"Multiple {typeof(T).Name.ToUnityLikeNameFormat()} found in the resources folder, only one can be active at the same time.", MessageType.Warning);

				GUILayout.BeginHorizontal();

				GUILayout.Label($"Main {typeof(T).Name.ToUnityLikeNameFormat()}: ");
				MainDatabase = EditorGUILayout.ObjectField(MainDatabase, typeof(T), false) as T;

				GUILayout.EndHorizontal();

				if (MainDatabase == null)
					GUI.enabled = false;

				if (GUILayout.Button("Merge the item databases", GUILayout.Height(30f)))
				{
					if (EditorUtility.DisplayDialog("Merge the item databases", "Are you sure you want the databases to be merged?", "Merge", "Cancel"))
					{
						List<T> databases = new List<T>();
						databases.AddRange(Resources.LoadAll<T>(""));
						databases.Remove(MainDatabase);

						MainDatabase.MergeDatabases(databases.ToArray());
						InitializeDatabaseEditor(MainDatabase);

						IsInitialized = true;

						m_DatabaseInstanceCount = GetDatabaseInstanceCount();
					}
				}

				GUI.enabled = true;
			}
		}

		protected virtual void OnEnable() => Undo.undoRedoPerformed += Repaint;
        protected virtual void OnDestroy() => Undo.undoRedoPerformed -= Repaint;

        protected abstract void InitializeDatabaseEditor(T database);
		protected abstract int GetDatabaseInstanceCount();
		protected abstract void DrawDatabaseEditor();
	}
}