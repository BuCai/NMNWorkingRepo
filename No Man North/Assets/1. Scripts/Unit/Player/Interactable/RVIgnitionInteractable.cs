using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NWH.VehiclePhysics2;
using SurvivalTemplatePro.UISystem;

namespace SurvivalTemplatePro {

    public class RVIgnitionInteractable : Interactable {

        public VehicleController VehicleController;
        [HideInInspector] public bool engineFunctional = true;
        [HideInInspector] public bool awningOff = true;
        [HideInInspector] private bool canStart => engineFunctional && awningOff;

        public void setAwning(bool on) {
            awningOff = !on;
        }

        public override void OnInteract(ICharacter character) {
            if (character.TryGetModule(out IVehicleHandler vehicleHandler)) {
                base.OnInteract(character);
                if (canStart) {
                    vehicleHandler.ToggleEngine();
                } else {
                    if (!engineFunctional) {
                        MessageDisplayerUI.PushMessage("Engine is not functional", Color.red);
                        //TODO: Engine can't start effect (?)
                    } else if (!awningOff) {
                        MessageDisplayerUI.PushMessage("Remove the awning to drive!", Color.red);
                    }
                }
            }
        }

        private void Awake() {
            if (VehicleController == null) {
                Debug.LogError("Vehicle controller not assigned");
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
