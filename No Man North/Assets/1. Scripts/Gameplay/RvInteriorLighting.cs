using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MLC.NoManNorth.Eric;
using SurvivalTemplatePro.WorldManagement;


//Enables/Disables interior lighting based on game time
public class RvInteriorLighting : MonoBehaviour {
    [SerializeField] private GameObject lightsObj;
    [SerializeField] private int hourToDisable = 7;
    [SerializeField] private int hourToEnable = 19;
    [SerializeField] private EventChannelInt OnHourChange;


    private void Awake() {
        if (lightsObj == null) {
            Debug.LogError("Interior lights holder object not assigned");
        } else if (OnHourChange == null) {
            Debug.LogError("OnHourChange EventChannel not assigned");
        } else {
            OnHourChange.OnEvent += HourUpdated;
        }
    }

    public void HourUpdated(int hour) {
        if (hour >= hourToEnable || hour < hourToDisable) {
            lightsObj.SetActive(true);
        } else {
            lightsObj.SetActive(false);
        }
    }
}
