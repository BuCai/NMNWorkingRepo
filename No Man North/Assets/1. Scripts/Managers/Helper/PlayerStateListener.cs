using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace MLC.NoManNorth.Eric
{
    public class PlayerStateListener : MonoBehaviour
    {
        #region Variables

        [SerializeField] private PlayerState StateToLisenFor;

        [SerializeField] private UnityEvent OnLisenedTo;
        [SerializeField] private UnityEvent OnNotLisenedTo;

        #endregion

        #region Unity Methods
        void Awake()
        {
            GameStateManager.Instance.OnPlayerStateChanged += GameStateManager_OnPlayerStateChanged;
        }

        protected void OnDestroy()
        {
            GameStateManager.Instance.OnPlayerStateChanged -= GameStateManager_OnPlayerStateChanged;
        }
        #endregion

        #region Methods

        private void GameStateManager_OnPlayerStateChanged(PlayerState newPlayerState)
        {
            if (StateToLisenFor == newPlayerState)
            {
                OnLisenedTo.Invoke();
            }
            else
            {
                OnNotLisenedTo.Invoke();
            }
        }

            #endregion
        }
}