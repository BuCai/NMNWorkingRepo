using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class MouseLocker : MonoBehaviour
    {
        #region Variables

        #endregion

        #region Unity Methods

        private void Awake()
        {
            GameStateManager.Instance.OnGameStateChanged += GameStateManager_OnGameStateChanged;
        }

        private void OnDestroy()
        {
            GameStateManager.Instance.OnGameStateChanged -= GameStateManager_OnGameStateChanged;
        }

        #endregion

        #region Methods

        private void GameStateManager_OnGameStateChanged(GameState newGameState)
        {
            
            if (newGameState == GameState.Gameplay)
            {
                Cursor.visible = true;
                Cursor.lockState = CursorLockMode.Locked;
            }
           
            Cursor.visible = (newGameState == GameState.Gameplay);
        }

        #endregion
    }
}