using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

//Functionally should serve the same purpose Pre-STP GameStateManager serves, reworked and updated to work with STP
namespace SurvivalTemplatePro {
    //NOTE: Sleeping is a special game state where the player is paused but everything else is running
    //TODO: Write explanation and uses for each state
    public enum GameState {
        Gameplay,
        Sleeping,
        Cutscene,
        Paused,
        MainMenu
    }

    public class STPGameStateManager : MonoBehaviour {
        public static STPGameStateManager Instance {
            get {
                if (m_Instance == null)
                    m_Instance = FindObjectOfType<STPGameStateManager>();

                return m_Instance;
            }
        }

        private static STPGameStateManager m_Instance;

        private void Awake() {
            if (Instance != null && Instance != this) {
                Destroy(this);
                return;
            }
        }

        private GameState curGameState = GameState.Gameplay; //Do not change default value
        public GameState gameState {
            get { return curGameState; }
            set {
                curGameState = value;
                if (isPaused) {
                    Physics.autoSimulation = false;
                } else {
                    Physics.autoSimulation = true;
                }
                gameStateChanged.Invoke(value);
            }
        }

        public void SetGameState(GameState state) {
            gameState = state;
        }

        public bool isPaused { get => curGameState == GameState.Paused || curGameState == GameState.MainMenu; }

        [HideInInspector] public UnityEvent<GameState> gameStateChanged = new UnityEvent<GameState>();
    }
}
