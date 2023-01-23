using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NWH.VehiclePhysics2;
using System.Threading.Tasks;

namespace SurvivalTemplatePro {

    //Handles the player getting in and out of the back of the rv
    //TODO: Update to STP
    public class RVBackInteractable : Interactable {

        [SerializeField] private Transform targetTransform;
        [SerializeField] private STPCameraSwitcher.CamState stateToSwitch;
        [SerializeField] private bool useTransition = false;
        [SerializeField] private bool animate = false;
        [SerializeField] private bool exit = false;
        [SerializeField] private Animator animator;
        [SerializeField] private string parameterName;
        public VehicleController VehicleController;

        public override void OnInteract(ICharacter character) {
            base.OnInteract(character);
            Action(character);
        }

        private async void Action(ICharacter character) {
            if (useTransition) {
                UISystem.FadeScreenUI.Instance.Fade(true, 0f, 2f);
                if (animate) {
                    animator.SetBool(parameterName, true);
                }
                await Task.Delay(500);
            }
            if (character.TryGetModule(out IVehicleHandler vehicleHandler)) {
                if (vehicleHandler.IsDriving)
                    vehicleHandler.Stop(exit);
                if (exit)
                    vehicleHandler.CompanionsExitVan();
            }
            character.GetModule(out ICharacterMotor motor);
            motor.Teleport(targetTransform.position, targetTransform.rotation);
            character.gameObject.GetComponentInChildren<STPCameraSwitcher>().SwitchCamState(stateToSwitch);
            if (useTransition) {
                UISystem.FadeScreenUI.Instance.Fade(false, 0f, 2f);
                if (animate) {
                    animator.SetBool(parameterName, false);
                }
            }
        }

        private void Awake() {
            if (VehicleController == null) {
                Debug.LogError("Vehicle controller not assigned");
            }
            if (animate && (animator == null || parameterName == "")) {
                Debug.LogError("Animation parameters null");
            }
        }

        //Uninteractable past 15kmh
        private void FixedUpdate() {
            if (VehicleController == null) {
                return;
            }
            if (VehicleController.Speed * 3.6f > 15f) {
                InteractionEnabled = false;
            } else {
                InteractionEnabled = true;
            }
        }
    }
}
