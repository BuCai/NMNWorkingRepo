using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using EasyCharacterMovement;
using EasyCharacterMovement.Examples.Cinemachine.ThirdPersonExample;

namespace MLC.NoManNorth.Eric {
    public class NoManNorthThirdPersonCharacterController : CMThirdPersonCharacter {
        #region Variables
        public static NoManNorthThirdPersonCharacterController Instance { get; private set; }

        [Header("No Man North Setters")]
        [SerializeField] private CharacterMovement cm;
        [SerializeField] private Rigidbody rb;

        [SerializeField] private float sprintCost;

        [SerializeField] private EventChannelFloat OnFrostValueChange;

        [field: SerializeField] public GameObject dropLocation { get; private set; }
        [field: SerializeField] public GameObject heldItemRoot { get; private set; }

        private Vector3 velocityBeforePause;
        private Vector3 angularVelocityBeforePause;

        private float baseMaxWalkSpeed;
        [SerializeField] private float minMaxWalkSpeed;

        #endregion

        #region Unity Methods

        override protected void OnAwake() {
            base.OnAwake();

            if (Instance != null && Instance != this) {
                Destroy(this);
            } else {
                Instance = this;
            }

            baseMaxWalkSpeed = maxWalkSpeed;


            // OnFrostValueChange.OnEvent += OnFrostValueChange_OnEvent;
            // GameStateManager.Instance.OnGameStateChanged += GameStateManager_OnGameStateChanged;
            // GameStateManager.Instance.OnPlayerSubStateChanged += Instance_OnPlayerSubStateChanged; ;
            // InvintoryPlayer.Instance.OnChangeWeight += Instance_OnChangeWeight;
        }


        protected void OnDestroy() {
            OnFrostValueChange.OnEvent += OnFrostValueChange_OnEvent;
            GameStateManager.Instance.OnGameStateChanged -= GameStateManager_OnGameStateChanged;

            InvintoryPlayer.Instance.OnChangeWeight -= Instance_OnChangeWeight;
        }

        public override void Sprint() {
            if (PlayerStatManager.Instance.stamina.current > 10) {
                base.Sprint();
                return;
            }
        }

        public bool canRestoreStamina() {
            if (IsSprinting()) return false;
            if (!IsGrounded()) return false;

            return true;
        }

        protected override void Update() {
            base.Update();

            if (IsSprinting()) {
                PlayerStatManager.Instance.stamina.changeStat(Time.deltaTime * -sprintCost);

                if (PlayerStatManager.Instance.stamina.current < 1) {
                    StopSprinting();
                }
            }
        }
        #endregion

        #region Methods
        private void GameStateManager_OnGameStateChanged(GameState newGameState) {
            this.enabled = (newGameState == GameState.Gameplay);

            //cm.enabled = (newGameState == GameState.Gameplay);



            if (newGameState == GameState.Gameplay) {
                cm.enabled = true;
                //rb.isKinematic = false;
                cm.AddForce(velocityBeforePause, ForceMode.VelocityChange);
            }

            if (newGameState == GameState.Paused) {
                angularVelocityBeforePause = rb.angularVelocity;

                velocityBeforePause = rb.velocity;
                //rb.isKinematic = true;
                cm.enabled = false;
            }

        }

        private void Instance_OnPlayerSubStateChanged(PlayerSubState newPlayerSubState) {
            if (newPlayerSubState == PlayerSubState.InInvintory) {
                maxWalkSpeed = 0;
                rotationRate = 0;
                canEverJump = false;
            } else {
                defaultMovementMode = MovementMode.Walking;
                rotationRate = 540;
                canEverJump = true;
                calculateMaxWalkSpeed();

            }
        }


        private void Instance_OnChangeWeight(float obj) {
            currentPlayerWeight = obj;
            calculateMaxWalkSpeed();
            HandleInput();
        }

        private void OnFrostValueChange_OnEvent(float percentageOfFrostSpeed) {
            currentFrostValuePercentage = percentageOfFrostSpeed;



            calculateMaxWalkSpeed();
        }
        private float currentFrostValuePercentage;
        private float currentPlayerWeight;

        private void calculateMaxWalkSpeed() {
            if (GameStateManager.Instance.currentPlayerSubState == PlayerSubState.InInvintory) {
                maxWalkSpeed = 0;
                return;
            }

            if (currentPlayerWeight > InvintoryPlayer.Instance.getCarryWeightLimit()) {
                maxWalkSpeed = minMaxWalkSpeed;
                return;
            }


            maxWalkSpeed = currentFrostValuePercentage * baseMaxWalkSpeed;

            if (maxWalkSpeed < minMaxWalkSpeed) {
                maxWalkSpeed = minMaxWalkSpeed;
            }
        }

        #endregion
    }
}