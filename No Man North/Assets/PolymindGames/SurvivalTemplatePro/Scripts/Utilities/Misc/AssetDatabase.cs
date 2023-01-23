using UnityEngine;

namespace SurvivalTemplatePro
{
    public abstract class AssetDatabase<T> : ScriptableObject where T : ScriptableObject
    {
        public static bool AssetExists => Instance != null;

        public static T Instance
        {
            get
            {
                if (m_Instance == null)
                {
                    var allFiles = Resources.LoadAll<T>("");
                    if (allFiles != null && allFiles.Length > 0)
                        m_Instance = allFiles[0];
                }

                return m_Instance;
            }
        }

        private static T m_Instance;


        public static int GetInstanceCount() 
        {
            var allFiles = Resources.LoadAll<T>("");

            return allFiles != null ? allFiles.Length : 0;
        }

        protected virtual void OnEnable()
		{
            if (Instance == null)
                return;

            #if UNITY_EDITOR
            // No need to refresh the IDs when not in the editor
            RefreshIDs();
            #endif

            GenerateDictionaries();
		}

        protected virtual void OnDisable() { }

        protected virtual void GenerateDictionaries() { }

#if UNITY_EDITOR
        public virtual void MergeDatabases(T[] databases) { }

        protected virtual void OnValidate() 
        {
            if (Instance == null)
                return;

            RefreshIDs();
            GenerateDictionaries();
        }

        protected virtual void RefreshIDs() { }
#endif
    }
}