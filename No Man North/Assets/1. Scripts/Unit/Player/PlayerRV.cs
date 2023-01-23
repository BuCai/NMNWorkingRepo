using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace MLC.NoManNorth.Eric
{
    public class PlayerRV : MonoBehaviour
    {
        #region Variables
        public static PlayerRV Instance { get; private set; }

        [SerializeField] private InputActionAsset actions;
        private InputAction togglePause;
        private InputAction ExitDriving;

        #endregion

        #region Unity Methods

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(this);
            }
            else
            {
                Instance = this;
            }

            ExitDriving = actions.FindAction("ExitVechicle");
            if (ExitDriving != null)
            {
                ExitDriving.performed += ExitDriving_performed;
            }


        }

        #endregion

        #region Methods

        private void ExitDriving_performed(InputAction.CallbackContext obj)
        {
            GameStateManager.Instance.SetPlayerState(PlayerState.First);
        }

        #endregion
    }
}