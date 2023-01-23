using SurvivalTemplatePro.UISystem;
using UnityEngine;

namespace SurvivalTemplatePro {
    public abstract class GameMode : MonoBehaviour, ISaveableComponent {
        [SerializeField]
        protected GameObject m_SceneCamera;

        [Space]

        [SerializeField]
        protected Player m_PlayerPrefab;

        [SerializeField]
        protected PlayerUIBehavioursManager m_PlayerUIPrefab;

        protected ICharacter m_Player;
        protected PlayerUIBehavioursManager m_PlayerUI;


        protected virtual void Awake() {
            LevelManager.onGameLoaded += OnGameLoaded;
        }

        protected virtual void Start() {
            if (!LevelManager.Instance.IsLoading && STPGameStateManager.Instance.gameState != GameState.MainMenu)
                OnGameLoaded();
        }

        protected virtual void OnDestroy() => LevelManager.onGameLoaded -= OnGameLoaded;

        protected virtual void OnGameLoaded() {
            // Player set up.
            if (TryGetPlayer(out m_Player))
                SetupPlayer();

            // Player UI set up.
            if (TryGetPlayerUI(out m_PlayerUI))
                SetupUI();

            // Destroy the scene camera.
            m_SceneCamera.SetActive(false);
            Destroy(m_SceneCamera);
        }

        protected virtual void OnPlayerDeath() { }
        protected virtual void OnPlayerRespawn() { }

        protected virtual void SetupPlayer() {
            // Listen to player events.
            m_Player.HealthManager.onDeath += OnPlayerDeath;
            m_Player.HealthManager.onRespawn += OnPlayerRespawn;
        }

        protected virtual void SetupUI() {
            m_PlayerUI.AttachToPlayer(m_Player);
        }

        protected virtual bool TryGetPlayer(out ICharacter player) {
            player = Player.LocalPlayer;

            if (player == null) {
                if (m_PlayerPrefab != null) {
                    player = Instantiate(m_PlayerPrefab);
                    OnPlayerRespawn();
                } else
                    Debug.LogError("Player prefab null, assign it in the inspector.");
            }

            return player != null;
        }

        protected virtual bool TryGetPlayerUI(out PlayerUIBehavioursManager playerUI) {
            playerUI = Object.FindObjectOfType<PlayerUIBehavioursManager>();

            if (playerUI == null) {
                if (m_PlayerUIPrefab != null)
                    playerUI = Instantiate(m_PlayerUIPrefab);
                else
                    Debug.LogError("Player UI prefab null, assign it in the inspector.");
            }

            return playerUI != null;
        }

        protected virtual void SetPlayerPosition(SpawnPointData spawnData) {
            if (m_Player == null)
                return;

            // Set the player's position and rotation.
            if (m_Player.TryGetModule(out ICharacterMotor motor))
                motor.Teleport(spawnData.Position, spawnData.Rotation);
        }

        protected virtual SpawnPointData GetSpawnData() {
            SpawnPointData spawnPoint = SpawnPointData.Default;

            if (spawnPoint == SpawnPointData.Default) {
                // Search for random spawn point.
                var foundSpawnPoints = FindObjectsOfType<SpawnPoint>();

                if (foundSpawnPoints != null && foundSpawnPoints.Length > 0)
                    spawnPoint = foundSpawnPoints.SelectRandom().GetSpawnPoint();
                else
                    Debug.Log("No spawnpoints found");
            }

            if (spawnPoint == SpawnPointData.Default) {
                // Snaps the spawn point position to the ground.
                if (Physics.Raycast(transform.position + Vector3.up, Vector3.down, out RaycastHit hitInfo, 10f))
                    spawnPoint = new SpawnPointData(hitInfo.point + Vector3.up * 0.1f, transform.rotation);
                else
                    spawnPoint = new SpawnPointData(transform.position, transform.rotation);
            }

            return spawnPoint;
        }

        #region Save & Load
        public virtual object[] SaveMembers() {
            return null;
        }

        public virtual void LoadMembers(object[] members) {

        }
        #endregion
    }
}