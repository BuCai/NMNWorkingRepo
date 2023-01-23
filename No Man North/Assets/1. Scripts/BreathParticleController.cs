using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro {
    //Enables and disables the breath particles
    //Enabled if player temp level is chill or under, disabled if above
    public class BreathParticleController : MonoBehaviour {
        [SerializeField] private GameObject obj;
        [SerializeField] private TemperatureManager playerTempManager;

        private void Awake() {
            playerTempManager.temperatureLevelChanged.AddListener(TLChanged);
        }

        private void TLChanged(TemperatureLevel lvl) {
            if (lvl <= TemperatureLevel.Chill) {
                obj.SetActive(true);
            } else {
                obj.SetActive(false);
            }
        }
    }
}
