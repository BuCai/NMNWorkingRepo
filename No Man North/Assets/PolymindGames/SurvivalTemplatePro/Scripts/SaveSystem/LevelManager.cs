using SurvivalTemplatePro.InputSystem;
using SurvivalTemplatePro.SaveSystem;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using WorldStreamer2;
using IEnumerator = System.Collections.IEnumerator;

namespace SurvivalTemplatePro {
    public class LevelManager : Singleton<LevelManager> {
        public SceneField managersScene;
        public int minStreamedTileCount = 25; //Minimum amount of streamed tiles before loading is considered finished
        [Range(0f, 1f)] public float scnToStreamProgressRatio = 0.5f; //Progress bar ratio of scene load time to tile stream time
        public GameData CurrentGame => m_CurrentGame;
        public float LoadingProgress => m_LoadingProgress;
        public bool IsLoading {
            get => m_IsLoading;
            set {
                if (value != m_IsLoading) {
                    m_IsLoading = value;

                    if (m_IsLoading) {
                        onGameLoadStart?.Invoke();
                    } else {
                        STPGameStateManager.Instance.SetGameState(GameState.Gameplay);
                        onGameLoaded?.Invoke();
                    }
                }
            }
        }
        public bool IsSaving {
            get => m_IsSaving;
            set {
                if (value != m_IsSaving) {
                    m_IsSaving = value;

                    if (m_IsSaving)
                        onGameSaveStart?.Invoke();
                    else
                        onGameSaved?.Invoke();
                }
            }
        }

        public static event Action onGameSaveStart;
        public static event Action onGameSaved;
        public static event Action onGameLoadStart;
        public static event Action onGameLoaded;

        [SerializeField, Clamp(0, 100000)]
        private int m_DefaultSaveId = 0;

        private bool m_IsSaving;
        private bool m_IsLoading;
        private float m_LoadingProgress;

        private GameData m_CurrentGame;
        private readonly List<SaveableObject> m_CurrentSceneSaveables = new List<SaveableObject>();


        protected override void OnAwake() {
            DontDestroyOnLoad(this);
            SceneManager.activeSceneChanged += OnActiveSceneChanged;
        }

        private IEnumerator Start() {
            m_CurrentGame = new GameData(m_DefaultSaveId, new SceneData() { Name = SceneManager.GetActiveScene().name });

            onGameLoaded?.Invoke();

            yield break;
        }

        private void OnActiveSceneChanged(Scene arg0, Scene arg1) => InputBlockManager.ClearAllBlockers();

        public void LoadGame() => StartCoroutine(LoadSceneCoroutine(managersScene.SceneName, LoadSceneMode.Single));
        public void LoadScene(string sceneName, LoadSceneMode lsm) => StartCoroutine(LoadSceneCoroutine(sceneName, lsm));
        public void LoadSave(int saveId) => StartCoroutine(LoadSaveCoroutine(saveId));
        public bool GameExists(int id) => SaveLoadManager.SaveFileExists(id);
        public void RemoveGame(int saveId) => SaveLoadManager.DeleteSaveFile(saveId);

        private IEnumerator LoadSceneCoroutine(string sceneName, LoadSceneMode lsm) {
            IsLoading = true;

            // Load the scene
            Debug.Log("Loading scene");
            AsyncOperation sceneLoadOperation = SceneManager.LoadSceneAsync(sceneName, lsm);
            while (!sceneLoadOperation.isDone) {
                m_LoadingProgress = sceneLoadOperation.progress * scnToStreamProgressRatio;
                yield return null;
            }
            Debug.Log("Scene loaded");
            yield return new WaitForSeconds(0.2f);

            GameObject streamerObj = GameObject.FindGameObjectWithTag(Streamer.STREAMERTAG);
            if (streamerObj == null) {
                IsLoading = false;
            } else {
                //Wait for world streamer to load
                Streamer streamer = streamerObj.GetComponent<Streamer>();
                streamer.spawnedPlayer = true;
                streamer.playerTag = "Spawnpoint"; //Since player is not spawned while loading, WorldStreamer spawns tiles around spawn point
                while (streamer.tilesLoaded < minStreamedTileCount) {
                    m_LoadingProgress = scnToStreamProgressRatio + (((float)streamer.tilesLoaded / minStreamedTileCount) * (1 - scnToStreamProgressRatio));
                    yield return null;
                }
                m_LoadingProgress = 1;
                IsLoading = false;
                streamer.playerTag = "Player";
            }
        }

        //SAVE SYSTEM DISABLED
        //Save loading code is outdated, DO NOT USE.
        private IEnumerator LoadSaveCoroutine(int saveId) {
            GameData game = SaveLoadManager.LoadFromSaveFile(saveId);

            if (game == null || !DoesSceneExist(game.SceneData.Name))
                yield break;

            m_CurrentGame = game;

            IsLoading = true;
            m_LoadingProgress = 0f;

            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Locked;

            yield return new WaitForSeconds(0.3f);

            // Load the scene
            AsyncOperation sceneLoadOperation = SceneManager.LoadSceneAsync(m_CurrentGame.SceneData.Name, LoadSceneMode.Single);

            while (!sceneLoadOperation.isDone) {
                m_LoadingProgress = sceneLoadOperation.progress;
                yield return null;
            }

            yield return new WaitForSeconds(0.3f);

            // Spawn the player, UI, and others
            LoadSaveables(m_CurrentGame);

            IsLoading = false;
        }

        //SAVE SYSTEM DISABLED
        public void SaveCurrentGame(int saveId) {
            if (IsSaving)
                return;

            StartCoroutine(C_SaveCurrentGame(saveId));
        }

        private IEnumerator C_SaveCurrentGame(int saveId) {
            if (m_CurrentGame == null)
                yield break;

            IsSaving = true;

            m_CurrentGame.SaveId = saveId;
            m_CurrentGame.DateTime = DateTime.Now;
            m_CurrentGame.SetScreenshot(ScreenCapture.CaptureScreenshotAsTexture());

            m_CurrentGame.SceneData.Name = SceneManager.GetActiveScene().name;

            Dictionary<string, SaveableObject.Data> saveableObjects = m_CurrentGame.SceneData.Objects;
            saveableObjects.Clear();

            int saveCount = 0;

            for (int i = 0; i < m_CurrentSceneSaveables.Count; i++) {
                saveableObjects.Add(m_CurrentSceneSaveables[i].GetGuid().ToString(), m_CurrentSceneSaveables[i].Save());
                saveCount++;

                // Only save 10 objects per frame
                if (saveCount == 10) {
                    yield return null;
                    saveCount = 0;
                }
            }

            SaveLoadManager.SaveToFile(m_CurrentGame);

            yield return new WaitUntil(() => !SaveLoadManager.IsSaving);

            IsSaving = false;
        }

        private void LoadSaveables(GameData gameData) {
            Dictionary<string, SaveableObject.Data> saveables = gameData.SceneData.Objects;

            for (int i = m_CurrentSceneSaveables.Count - 1; i >= 0; i--) {
                if (saveables.TryGetValue(m_CurrentSceneSaveables[i].GetGuid().ToString(), out SaveableObject.Data objData))
                    m_CurrentSceneSaveables[i].Load(objData);
                else
                    Destroy(m_CurrentSceneSaveables[i].gameObject);
            }

            foreach (var objData in gameData.SceneData.Objects.Values) {
                if (!m_CurrentSceneSaveables.Exists((SaveableObject obj) => obj.GetGuid() == new Guid(objData.SceneID))) {
                    SaveableObject prefab = SaveLoadManager.GetPrefabWithID(objData.PrefabID);

                    if (prefab != null) {
                        SaveableObject loadedObj = Instantiate(prefab);
                        loadedObj.Load(objData);
                    }
                }
            }
        }

        public void RegisterSaveable(SaveableObject saveable) {
#if UNITY_EDITOR
            if (!Application.isPlaying && Application.isEditor)
                return;
#endif

            if (!m_CurrentSceneSaveables.Contains(saveable))
                m_CurrentSceneSaveables.Add(saveable);
            else
                Debug.LogWarning("Savable is already registered!", saveable);
        }

        public void UnregisterSaveable(SaveableObject saveable) {
#if UNITY_EDITOR
            if (!Application.isPlaying && Application.isEditor)
                return;
#endif

            if (m_CurrentSceneSaveables.Contains(saveable))
                m_CurrentSceneSaveables.Remove(saveable);
            else
                Debug.LogWarning("Savable is not registered, no need for un-registering!", saveable);
        }

        /// <summary>
        /// Returns true if the scene 'name' exists and is in your Build settings, false otherwise
        /// </summary>
        public static bool DoesSceneExist(string name) {
            if (string.IsNullOrEmpty(name))
                return false;

            for (int i = 0; i < SceneManager.sceneCountInBuildSettings; i++) {
                var scenePath = SceneUtility.GetScenePathByBuildIndex(i);
                var lastSlash = scenePath.LastIndexOf("/");
                var sceneName = scenePath.Substring(lastSlash + 1, scenePath.LastIndexOf(".") - lastSlash - 1);

                if (string.Compare(name, sceneName, true) == 0)
                    return true;
            }

            return false;
        }
    }
}