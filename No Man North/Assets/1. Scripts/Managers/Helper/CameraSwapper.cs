using Cinemachine;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class CameraSwapper : MonoBehaviour
    {
        #region Variables

        [SerializeField] private CinemachineVirtualCamera thirdPersonCamera;
        [SerializeField] private CinemachineVirtualCamera firstPersonCamera;
        [SerializeField] private CinemachineVirtualCamera rvCamera;

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
            if (newPlayerState == PlayerState.Third)
            {
                thirdPersonCamera.Priority = 10;
                firstPersonCamera.Priority = 0;
                rvCamera.Priority = 0;
            }

            if (newPlayerState == PlayerState.First)
            {
                thirdPersonCamera.Priority = 0;
                firstPersonCamera.Priority = 10;
                rvCamera.Priority = 0;
            }

            if (newPlayerState == PlayerState.RV)
            {
                thirdPersonCamera.Priority = 0;
                firstPersonCamera.Priority = 0;
                rvCamera.Priority = 10;
            }

            if (newPlayerState == PlayerState.First)
            {
                thirdPersonCamera.Priority = 0;
                firstPersonCamera.Priority = 10;
                rvCamera.Priority = 0;
            }

        }

        #endregion
    }
}