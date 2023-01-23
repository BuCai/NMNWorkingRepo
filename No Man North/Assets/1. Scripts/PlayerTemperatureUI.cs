using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

namespace SurvivalTemplatePro.UISystem {

    //Temporary script to handle the placeholder temperature text, will be re-done with the proper ui
    public class PlayerTemperatureUI : MonoBehaviour {
        [SerializeField] private TextMeshProUGUI phTempText;
        private TemperatureManager playerTempManager;


        private TemperatureLevel tempLevel = TemperatureLevel.Mild;

        public void Start() {
            if (phTempText == null) {
                Debug.LogError("Temperature text not assigned");
            }
            playerTempManager = GameObject.FindGameObjectWithTag("Player").GetComponentInChildren<TemperatureManager>();
            playerTempManager.temperatureLevelChanged.AddListener(UpdateTemperatureLevel);
        }

        private void UpdateTemperatureLevel(TemperatureLevel level) {
            tempLevel = level;
        }

        public void Update() {
            phTempText.text = tempLevel.ToString() + " (" + playerTempManager.PlayerTemperature.ToString() + ")";
        }
    }
}
