using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using EasyCharacterMovement;

namespace MLC.NoManNorth.Eric
{
    public class NoManNorthFPSCharacterController : FirstPersonCharacter
    {
        #region Variables
        [SerializeField] private CharacterMovement cm;
        [SerializeField] private Rigidbody rb;
        #endregion

        #region Unity Methods

        override protected void Awake()
        {
            base.Awake();
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
            this.enabled = (newGameState == GameState.Gameplay);

            //cm.enabled = (newGameState == GameState.Gameplay);



            if (newGameState == GameState.Gameplay)
            {
                cm.enabled = true;
                //rb.isKinematic = false;
                //cm.AddForce(0f, ForceMode.VelocityChange);
            }

            if (newGameState == GameState.Paused)
            {
                
                //rb.isKinematic = true;
                cm.enabled = false;
            }
        }

        #endregion
    }
}