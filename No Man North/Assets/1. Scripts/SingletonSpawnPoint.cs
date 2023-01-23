using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro {
    public class SingletonSpawnPoint : SpawnPoint {
        //This was created in order to have a way to place the spawnpoint outside of the managers scene
        //Obviously, it does not work with multiple spawnpoints chosen in random
        //If there are multiple of these placed in active scenes, only the first one will be the singleton and the rest will self-destruct

        public static SingletonSpawnPoint Instance {
            get {
                if (m_Instance == null)
                    m_Instance = FindObjectOfType<SingletonSpawnPoint>();

                return m_Instance;
            }
            set {
                m_Instance = value;
            }
        }
        public static SingletonSpawnPoint m_Instance;

        private void Awake() {
            if (Instance == null) {
                Instance = this;
            } else if (Instance != this) {
                Destroy(gameObject);
            }
        }

    }
}
