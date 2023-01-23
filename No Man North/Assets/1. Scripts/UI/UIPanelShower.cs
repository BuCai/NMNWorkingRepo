using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace MLC.NoManNorth.Eric
{
    public class UIPanelShower : MonoBehaviour
    {
        #region Variables


        [SerializeField] private InputActionAsset actions;
        private InputAction togglePause;
        private InputAction toggleInvintory;

        [SerializeField] private GameObject invintoryGameObject;
        [SerializeField] private GameObject pauseGameObject;

        [SerializeField] private EventChannelInvintoryContainer OnOpenContainer;


        #endregion

        #region Unity Methods

        private void Awake()
        {
            OnOpenContainer.OnEvent += OnOpenContainer_OnEvent;

            toggleInvintory = actions.FindAction("Toggle Invintory");
            if (toggleInvintory != null)
            {
                toggleInvintory.performed += OnToggleInvintory;
            }

            togglePause = actions.FindAction("Pause");
            if (togglePause != null)
            {
                togglePause.performed += OnTogglePause;
            }

        }

        private void OnDestroy()
        {
            OnOpenContainer.OnEvent -= OnOpenContainer_OnEvent;

            if (toggleInvintory != null)
            {
                toggleInvintory.performed -= OnToggleInvintory;
            }
            if (togglePause != null)
            {
                togglePause.performed -= OnTogglePause;
            }
        }

        private void OnEnable()
        {
            toggleInvintory?.Enable();
            togglePause?.Enable();
        }

        private void OnDisable()
        {
            toggleInvintory?.Disable();
            togglePause?.Disable();
        }

        #endregion

        #region Methods
        private void OnToggleInvintory(InputAction.CallbackContext obj)
        {
            if (GameStateManager.Instance.CurrentGameState == GameState.Paused) return;

            invintoryGameObject.SetActive(! invintoryGameObject.activeInHierarchy );
            
            //Open Invintory
            if (invintoryGameObject.activeInHierarchy)
            {
                GameStateManager.Instance.SetPlayerSubState(PlayerSubState.InInvintory);
                PlayerAnimationHelper.Instance.OpenInvintory();
                PlayerItemDisplayer.Instance.OpenInvintory();
                
            }//Close Invintory
            else
            {
                GameStateManager.Instance.SetPlayerSubState(PlayerSubState.Normal);
                UIInvintoryManger.Instance.CloseContainer();
                PlayerAnimationHelper.Instance.CloseInvintory();
                PlayerItemDisplayer.Instance.CloseInvintory();
            }

        }

        private void OnTogglePause(InputAction.CallbackContext obj)
        {
            pauseGameObject.SetActive(!pauseGameObject.activeInHierarchy);
            //Pause Game
            if (pauseGameObject.activeInHierarchy)
            {
                GameStateManager.Instance.SetGameState(GameState.Paused);
            }//Un Pause Game
            else
            {
                
                GameStateManager.Instance.SetGameState(GameState.Gameplay);
            }

        }

        private void OnOpenContainer_OnEvent(InvintoryContainer openingContainer)
        {
            UIInvintoryManger.Instance.OnOpenContainer_OnEvent(openingContainer);
            GameStateManager.Instance.SetPlayerSubState(PlayerSubState.InInvintory);
            invintoryGameObject.SetActive(true);

        }

        #endregion
    }
}