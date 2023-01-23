using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro {
    public class SoloSurvivalGameMode : GameMode {
        [SerializeField] private InventoryStartupItemsInfo m_StartupItems;
        [SerializeField] private bool useSleepPos = false;
        private bool m_StartupItemsAdded;


        protected override void OnPlayerRespawn() {
            SetPlayerPosition(GetSpawnData());

            if (!m_StartupItemsAdded)
                m_StartupItems.AddItemsToInventory(m_Player.Inventory);
        }

        protected override SpawnPointData GetSpawnData() {
#if UNITY_EDITOR
            if (Application.isPlaying)
                return base.GetSpawnData();
#endif

            SpawnPointData spawnPoint = SpawnPointData.Default;

            // Set the spawn position to the sleeping place.
            if (useSleepPos && m_Player.TryGetModule(out ISleepHandler sleepHandler))
                spawnPoint = new SpawnPointData(sleepHandler.LastSleepPosition, sleepHandler.LastSleepRotation);

            if (spawnPoint.IsDefault()) {
                if (SingletonSpawnPoint.Instance != null) {
                    return SingletonSpawnPoint.Instance.GetSpawnPoint();
                } else {
                    return base.GetSpawnData();
                }
            }
            return spawnPoint;
        }

        #region Save & Load
        public override object[] SaveMembers() {
            return new object[] { m_StartupItemsAdded };
        }

        public override void LoadMembers(object[] members) {
            m_StartupItemsAdded = (bool)members[0];
        }
        #endregion
    }
}