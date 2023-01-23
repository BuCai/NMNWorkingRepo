using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro {
    //Overrides the environment temperature when the player is in the trigger
    //Make sure to set the tag of the gameobject to "TempZone"
    [RequireComponent(typeof(Collider))]
    public class TemperatureZone : MonoBehaviour {
        public virtual float ZoneTemperature { get; protected set; }
        private void Awake() {
            GetComponent<Collider>().isTrigger = true;
        }
    }
}

