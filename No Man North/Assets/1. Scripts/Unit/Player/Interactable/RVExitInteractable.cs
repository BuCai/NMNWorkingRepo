using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NWH.VehiclePhysics2;
using System.Threading.Tasks;

namespace SurvivalTemplatePro {
    public class RVExitInteractable : Interactable {
        public Transform exitPoint;
        public VehicleController VehicleController;
        [SerializeField] private bool useTransition = false;
        [SerializeField] private bool animate = false;
        [SerializeField] private Animator animator;
        [SerializeField] private string parameterName;

        public override void OnInteract(ICharacter character) {
            if (character.TryGetModule(out IVehicleHandler vehicleHandler)) {
                base.OnInteract(character);
                Action(character, vehicleHandler);
            }
        }

        private async void Action(ICharacter character, IVehicleHandler vehicleHandler) {
            if (useTransition) {
                UISystem.FadeScreenUI.Instance.Fade(true, 0f, 2f);
                if (animate) {
                    animator.SetBool(parameterName, true);
                }
                await Task.Delay(500);
            }
            vehicleHandler.SetExitPoint(exitPoint);
            vehicleHandler.Stop(true);
            character.gameObject.GetComponentInChildren<STPCameraSwitcher>().SwitchCamState(STPCameraSwitcher.CamState.Third);
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
