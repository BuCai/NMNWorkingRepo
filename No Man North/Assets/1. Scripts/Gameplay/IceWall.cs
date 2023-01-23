using Micosmo.SensorToolkit;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class IceWall : MonoBehaviour 
    {
        #region Variables
        [SerializeField] private EventChannelInt OnMinChange;
        [SerializeField] private GameObject TargetLocation;

        [SerializeField] private float moveSpeed;

        [SerializeField] private float damageFrostPerSecondMainArea;
        [SerializeField] private float damageFrostPerSecondWarningArea;

        [SerializeField] private RangeSensor sensorMainArea;
        [SerializeField] private RangeSensor sensorWarningArea;


        private List<WorldColdLisener> affectedUnitsMainFrostArea = new List<WorldColdLisener>();
        private List<WorldColdLisener> affectedUnitsWarningArea = new List<WorldColdLisener>();

        #endregion

        #region Unity Methods

        private void Awake()
        {
            GameStateManager.Instance.OnGameStateChanged += GameStateManager_OnGameStateChanged;
            GameStateManager.Instance.OnPlayerStateChanged += Instance_OnPlayerStateChanged;

            if(OnMinChange!=null) OnMinChange.OnEvent += OnMinChange_OnEvent;

    
            if (TargetLocation != null)
            {
                TargetLocation.transform.parent = null;
            }
            

            sensorMainArea.OnDetected.AddListener(OnEnterMainArea);
            sensorMainArea.OnLostDetection.AddListener(OnExitMainArea);

            sensorWarningArea.OnDetected.AddListener(OnEnterWarningArea);
            sensorWarningArea.OnLostDetection.AddListener(OnExitWarningArea);
        }

        private void OnDestroy()
        {
            GameStateManager.Instance.OnGameStateChanged -= GameStateManager_OnGameStateChanged;
            GameStateManager.Instance.OnPlayerStateChanged -= Instance_OnPlayerStateChanged;
            if (OnMinChange != null) OnMinChange.OnEvent -= OnMinChange_OnEvent;

            sensorMainArea.OnDetected.RemoveListener(OnEnterMainArea);
            sensorMainArea.OnLostDetection.RemoveListener(OnExitMainArea);

            sensorWarningArea.OnDetected.RemoveListener(OnEnterWarningArea);
            sensorWarningArea.OnLostDetection.RemoveListener(OnExitWarningArea);
        }

        private void Update()
        {
                      

            if(TargetLocation != null)
            {
                transform.position = Vector3.Lerp(transform.position, TargetLocation.transform.position, Time.deltaTime);
            }

            if (affectedUnitsMainFrostArea.Count > 0)
            {
                foreach (WorldColdLisener cs in affectedUnitsMainFrostArea)
                {
                    cs?.inFrostWall((-damageFrostPerSecondMainArea)*Time.deltaTime);
                }
            }

            if (affectedUnitsWarningArea.Count > 0)
            {
                foreach (WorldColdLisener cs in affectedUnitsWarningArea)
                {
                    if (affectedUnitsMainFrostArea.Contains(cs)) return;
                    
                    cs?.inFrostWall((-damageFrostPerSecondWarningArea) * Time.deltaTime);
                }
            }
        }

        #endregion

        #region Methods

        private void OnEnterMainArea(GameObject foundGameObject, Sensor sendo)
        {
            if (GameStateManager.Instance.CurrentPlayerState == PlayerState.Third && foundGameObject == NoManNorthThirdPersonCharacterController.Instance.gameObject)
            {
                IntergrationsToSkyManager.Instance.playerEnteredFrostWall();
            }

            if (GameStateManager.Instance.CurrentPlayerState == PlayerState.RV && foundGameObject == PlayerRV.Instance.gameObject)
            {
                IntergrationsToSkyManager.Instance.playerEnteredFrostWall();
            }

            if (foundGameObject.TryGetComponent<WorldColdLisener>(out WorldColdLisener coldStat))
            {
                affectedUnitsMainFrostArea.Add(coldStat);
            }
        }

        private void OnExitMainArea(GameObject foundGameObject, Sensor sendo)
        {
            if (GameStateManager.Instance.CurrentPlayerState == PlayerState.Third && foundGameObject == NoManNorthThirdPersonCharacterController.Instance.gameObject)
            {
                IntergrationsToSkyManager.Instance.playerLeftFrostWall();
            }

            if (GameStateManager.Instance.CurrentPlayerState == PlayerState.RV && foundGameObject == PlayerRV.Instance.gameObject)
            {
                IntergrationsToSkyManager.Instance.playerLeftFrostWall();
            }

            if (foundGameObject.TryGetComponent<WorldColdLisener>(out WorldColdLisener coldStat))
            {
                if (affectedUnitsMainFrostArea.Contains(coldStat))
                {
                    affectedUnitsMainFrostArea.Remove(coldStat);
                }
            }
        }

        private void OnEnterWarningArea(GameObject foundGameObject, Sensor sendo)
        {
            if (GameStateManager.Instance.CurrentPlayerState == PlayerState.Third && foundGameObject == NoManNorthThirdPersonCharacterController.Instance.gameObject)
            {
                IntergrationsToSkyManager.Instance.playerEnteredWarningArea();
            }

            if (GameStateManager.Instance.CurrentPlayerState == PlayerState.RV && foundGameObject == PlayerRV.Instance.gameObject)
            {
                IntergrationsToSkyManager.Instance.playerEnteredWarningArea();
            }

            if (foundGameObject.TryGetComponent<WorldColdLisener>(out WorldColdLisener coldStat))
            {
                affectedUnitsWarningArea.Add(coldStat);
            }
        }

        private void OnExitWarningArea(GameObject foundGameObject, Sensor sendo)
        {
            if (GameStateManager.Instance.CurrentPlayerState == PlayerState.Third && foundGameObject == NoManNorthThirdPersonCharacterController.Instance.gameObject)
            {
                IntergrationsToSkyManager.Instance.playerLeftWarningArea();
            }

            if (GameStateManager.Instance.CurrentPlayerState == PlayerState.RV && foundGameObject == PlayerRV.Instance.gameObject)
            {
                IntergrationsToSkyManager.Instance.playerLeftWarningArea();
            }


            if (foundGameObject.TryGetComponent<WorldColdLisener>(out WorldColdLisener coldStat))
            {
                if (affectedUnitsWarningArea.Contains(coldStat))
                {
                    affectedUnitsWarningArea.Remove(coldStat);
                }
            }
        }


        private void GameStateManager_OnGameStateChanged(GameState newGameState)
        {
            this.enabled = (newGameState == GameState.Gameplay) ;
        }

        private void Instance_OnPlayerStateChanged(PlayerState newPlayerState)
        {
            if (newPlayerState == PlayerState.Third)
            {
                if (affectedUnitsMainFrostArea.Contains(NoManNorthThirdPersonCharacterController.Instance.gameObject.GetComponent< WorldColdLisener>()) )
                {
                    IntergrationsToSkyManager.Instance.playerEnteredFrostWall();
                    IntergrationsToSkyManager.Instance.playerLeftWarningArea();

                }
                else if(affectedUnitsWarningArea.Contains(NoManNorthThirdPersonCharacterController.Instance.gameObject.GetComponent<WorldColdLisener>()))
                {
                    IntergrationsToSkyManager.Instance.playerLeftFrostWall();
                    IntergrationsToSkyManager.Instance.playerEnteredWarningArea();
                }
                else
                {
                    IntergrationsToSkyManager.Instance.playerLeftFrostWall();
                    IntergrationsToSkyManager.Instance.playerLeftWarningArea();
                }
            }

            if (newPlayerState == PlayerState.RV || newPlayerState == PlayerState.First)
            {
                if (affectedUnitsMainFrostArea.Contains(PlayerRV.Instance.gameObject.GetComponent<WorldColdLisener>()))
                {
                    IntergrationsToSkyManager.Instance.playerEnteredFrostWall();
                    IntergrationsToSkyManager.Instance.playerLeftWarningArea();

                }
                else if (affectedUnitsWarningArea.Contains(PlayerRV.Instance.gameObject.GetComponent<WorldColdLisener>()))
                {
                    IntergrationsToSkyManager.Instance.playerLeftFrostWall();
                    IntergrationsToSkyManager.Instance.playerEnteredWarningArea();
                }
                else
                {
                    IntergrationsToSkyManager.Instance.playerLeftFrostWall();
                    IntergrationsToSkyManager.Instance.playerLeftWarningArea();
                }
            }
        }

        private void OnMinChange_OnEvent(int obj)
        {
            TargetLocation.transform.Translate(Vector3.forward * moveSpeed );
        }

        #endregion
    }
}