using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric {

    public enum GameState {
        Gameplay,
        Paused
    }

    public enum PlayerState {
        Start,
        Third,
        First,
        RV
    }

    public enum PlayerSubState {
        Normal,
        InInvintory
    }

    public class GameStateManager {
        private static GameStateManager _instance;
        public static GameStateManager Instance {
            get {
                if (_instance == null) {
                    _instance = new GameStateManager();
                }
                return _instance;
            }
        }

        private GameStateManager() {

        }

        #region Variables

        public GameState CurrentGameState { get; private set; }
        public PlayerState CurrentPlayerState { get; private set; }

        public PlayerSubState currentPlayerSubState { get; private set; }

        public delegate void GameStateChangeHandler(GameState newGameState);
        public event GameStateChangeHandler OnGameStateChanged;

        public delegate void PlayerStateChangeHandler(PlayerState newPlayerState);
        public event PlayerStateChangeHandler OnPlayerStateChanged;

        public delegate void PlayerSubStateChangeHandler(PlayerSubState newPlayerSubState);
        public event PlayerSubStateChangeHandler OnPlayerSubStateChanged;

        #endregion

        #region Methods

        public void SetGameState(GameState newGameState) {
            if (CurrentGameState == newGameState) {
                return;
            }
            Debug.Log("Game state changed to " + newGameState);
            CurrentGameState = newGameState;
            OnGameStateChanged?.Invoke(newGameState);
        }

        public void SetPlayerState(PlayerState newPlayerState) {
            if (CurrentPlayerState == newPlayerState) {
                return;
            }
            Debug.Log("Player state changed to " + newPlayerState);
            CurrentPlayerState = newPlayerState;
            OnPlayerStateChanged?.Invoke(newPlayerState);
        }

        public void SetPlayerSubState(PlayerSubState newPlayerSubState) {
            if (currentPlayerSubState == newPlayerSubState) {
                return;
            }
            Debug.Log("Player substate changed to " + newPlayerSubState);
            currentPlayerSubState = newPlayerSubState;
            OnPlayerSubStateChanged?.Invoke(newPlayerSubState);
        }

        #endregion
    }
}