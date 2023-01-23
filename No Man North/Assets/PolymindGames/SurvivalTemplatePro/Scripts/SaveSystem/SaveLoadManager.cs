using System.Collections.Generic;
using System.IO;
using UnityEngine;
using SurvivalTemplatePro.OdinSerializer;
using System.Threading.Tasks;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace SurvivalTemplatePro.SaveSystem
{
#if UNITY_EDITOR
    [InitializeOnLoad]
	#endif
	public static class SaveLoadManager
	{
		public static bool IsSaving => m_IsSaving;

		const string SAVE_FILE_NAME = "Save";
		const string SAVE_FILE_EXTENSION = "sav";

        private static bool m_IsSaving;
        private static string m_SaveFilePath;
        private static GameData m_DataToSave;


		#if UNITY_EDITOR
		static SaveLoadManager()
		{
			EditorApplication.projectChanged += AssignPrefabs;
			PrefabDatabase.Enabled += AssignPrefabs;
		}

        private static void AssignPrefabs()
		{
			if (PrefabDatabase.Default == null)
				return;
		
			var allPrefabs = AssetDatabase.FindAssets("t:GameObject");
			List<SaveableObject> saveablesInProject = new List<SaveableObject>();

			var currentPrefabs = PrefabDatabase.Default.Prefabs;
     
			if (currentPrefabs == null)
			{
				PrefabDatabase.Default.Prefabs = new SaveableObject[0];
				currentPrefabs = PrefabDatabase.Default.Prefabs;
			}	

			foreach (var guid in allPrefabs)
			{
				var gameObject = AssetDatabase.LoadAssetAtPath<GameObject>(AssetDatabase.GUIDToAssetPath(guid));
				var savable = gameObject.GetComponent<SaveableObject>();

				if (savable != null)
				{
					savable.PrefabID = guid;
					saveablesInProject.Add(savable);
				}
			}
				
			PrefabDatabase.Default.Prefabs = saveablesInProject.ToArray();
		}
		#endif

		public static bool SaveFileExists(int saveId)
		{
			return File.Exists(GetSaveFilePath(saveId));
		}

		public static void SaveToFile(GameData game)
		{
            if (m_IsSaving)
                return;

			var savePath = GetSavePath();

			if (!Directory.Exists(GetSavePath()))
				Directory.CreateDirectory(savePath);

            m_IsSaving = true;
            m_SaveFilePath = GetSaveFilePath(game.SaveId);
            m_DataToSave = game;
	
            SaveToFileAsync();
        }

		public static GameData LoadFromSaveFile(int saveId)
		{
			string saveFilePath = GetSaveFilePath(saveId);

			if (!File.Exists(saveFilePath))
				return null;

			byte[] bytes = File.ReadAllBytes(saveFilePath);
			GameData gameData = OdinSerializer.SerializationUtility.DeserializeValue<GameData>(bytes, DataFormat.Binary);

			return gameData;
		}

		public static List<GameData> LoadAllSaves()
		{
			List<GameData> saves = new List<GameData>();

			for (int i = 0; i < 10; i++)
			{
				string saveFilePath = GetSaveFilePath(i);

				if (File.Exists(saveFilePath))
				{
					byte[] bytes = File.ReadAllBytes(saveFilePath);
					GameData gameData = OdinSerializer.SerializationUtility.DeserializeValue<GameData>(bytes, DataFormat.Binary);

					saves.Add(gameData);
				}
			}

			return saves;
		}

		public static void DeleteSaveFile(int saveId)
		{
			if (!File.Exists(GetSaveFilePath(saveId)))
				return;

			File.Delete(GetSaveFilePath(saveId));
		}

		public static SaveableObject GetPrefabWithID(string prefabGuid)
		{
			SaveableObject[] prefabs = PrefabDatabase.Default.Prefabs;

			for (int i = 0; i < prefabs.Length; i++)
			{
				if (prefabs[i].PrefabID == prefabGuid)
					return prefabs[i];
			}

			return null;
		}

		public static void CreateLogFile(string message)
		{
			var file = File.Create(GetSavePath() + "/" + message + ".messagefile");
			file.Close();
		}

		private static void SaveToFileAsync()
        {
            try
            {
                Task.Run(SaveToFile);
            }
            catch(System.Exception e)
            {
                Debug.LogError(e);
            }
        }

        private static void SaveToFile()
        {
            Stream stream = File.Open(m_SaveFilePath, FileMode.Create);
            SerializationContext context = new SerializationContext();
            BinaryDataWriter writer = new BinaryDataWriter(stream, context);

			OdinSerializer.SerializationUtility.SerializeValue(m_DataToSave, writer);

            stream.Close();

            m_IsSaving = false;
		}

        private static string GetSavePath()
		{
			return Application.persistentDataPath + "/Saves";
		}

		private static string GetSaveFilePath(int saveId)
		{
			return GetSavePath() + "/" + SAVE_FILE_NAME + " " + saveId + "." + SAVE_FILE_EXTENSION;
		}
    }
}