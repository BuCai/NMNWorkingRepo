using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace MLC.NoManNorth.Eric
{
    public class MouseLock : MonoBehaviour
    {
        #region Variables

        

        #endregion

        #region Unity Methods

        private void Awake()
        {
            GameStateManager.Instance.OnGameStateChanged += GameStateManager_OnGameStateChanged;
            GameStateManager.Instance.OnPlayerSubStateChanged += Instance_OnPlayerSubStateChanged; ;
        }

        private void OnDestroy()
        {
            GameStateManager.Instance.OnGameStateChanged -= GameStateManager_OnGameStateChanged;
        }

        #endregion

        #region Methods


        private void GameStateManager_OnGameStateChanged(GameState newGameState)
        {
            if (newGameState == GameState.Paused)
            {
                UpdateCursorLockState(false);
                return;
            }
            if (newGameState == GameState.Gameplay)
            {
                if (PlayerSubState.InInvintory == GameStateManager.Instance.currentPlayerSubState)
                {
                    UpdateCursorLockState(false);
                    return;
                }
            }

            UpdateCursorLockState(true);
        }

        private void Instance_OnPlayerSubStateChanged(PlayerSubState newPlayerSubState)
        {
            if (newPlayerSubState == PlayerSubState.InInvintory)
            {
                UpdateCursorLockState(false);
            }
            else
            {
                UpdateCursorLockState(true);
            }
        }


        protected virtual void UpdateCursorLockState(bool lockCursor)
        {

            if (lockCursor)
            {
                Cursor.lockState = CursorLockMode.Locked;
                Cursor.visible = false;
            }
            else
            {
                Cursor.lockState = CursorLockMode.None;
                Cursor.visible = true;
            }
            if (NoManNorthCharacterLooks.Instance != null)
            {
                NoManNorthCharacterLooks.Instance.LockCursor(lockCursor);
            }
            
        }

        #endregion
    }
}