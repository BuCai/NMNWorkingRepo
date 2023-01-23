using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro {
    //Handles the rv rigidbody state when pausing/unpausing the game
    public class NWHCarPauser : MonoBehaviour {
        #region Variables

        [SerializeField] private Rigidbody carRigidbody;

        private bool rbIsKinematicBeforePause = true;
        private Vector3 angularVelocityBeforePause;
        private Vector3 velocityBeforePause;
        private Vector3 positionBeforePause;
        private Quaternion rotationBeforePause;

        #endregion

        #region Unity Methods

        private void Awake() {
            STPGameStateManager.Instance.gameStateChanged.AddListener(OnGameStateChanged);
        }

        private void OnDestroy() {
            STPGameStateManager.Instance.gameStateChanged.RemoveListener(OnGameStateChanged);
        }

        #endregion

        #region Methods

        private void OnGameStateChanged(GameState newGameState) {
            this.enabled = (newGameState == GameState.Gameplay);

            if (newGameState == GameState.Gameplay) {
                //carRigidbody.isKinematic = rbIsKinematicBeforePause;
                //carRigidbody.velocity = velocityBeforePause;
                //carRigidbody.angularVelocity = angularVelocityBeforePause;
                StartCoroutine(Unpause());
            }
            if (newGameState == GameState.Paused) {
                rbIsKinematicBeforePause = carRigidbody.isKinematic;
                angularVelocityBeforePause = carRigidbody.angularVelocity;
                velocityBeforePause = carRigidbody.velocity;
                positionBeforePause = carRigidbody.position;
                rotationBeforePause = carRigidbody.rotation;
                //carRigidbody.isKinematic = true;
            }

        }

        private IEnumerator Unpause() {
            yield return new WaitForFixedUpdate();
            yield return new WaitForFixedUpdate();
            carRigidbody.position = positionBeforePause;
            carRigidbody.rotation = rotationBeforePause;
            carRigidbody.velocity = velocityBeforePause;
            carRigidbody.angularVelocity = angularVelocityBeforePause;
        }

        #endregion
    }
}