using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Enviro;

//RV Script to update the dynamic dials on the dashboard with data from the vehicle
public class RVDashboard : MonoBehaviour {
    //Unit: KMH
    [SerializeField] private DynamicDial speedometer;
    //Unit: RPM
    [SerializeField] private DynamicDial tachometer;
    //Unit: Percent
    [SerializeField] private DynamicDial fuelGauge;
    //Unit: Degree
    [SerializeField] private DynamicDial compass;
    //Unit: Celcius
    [SerializeField] private DynamicDial temperature;
    //Unit: Degrees
    [SerializeField] private DynamicDial steeringWheel;

    public float compassRotationOffset = 0;
    //Ratio of steering wheel angle to vehicle steering axis
    public float steeringWheelMultiplier = 10f;

    private void Awake() {
        if (speedometer == null || tachometer == null || fuelGauge == null || compass == null || temperature == null || steeringWheel == null) {
            Debug.LogError("Rv dashboard dials aren't assigned");
        }
    }

    public void UpdateDials(float speed, float rpm, float fuel, float steer) {
        speedometer.SetValue(speed);
        tachometer.SetValue(rpm);
        fuelGauge.SetValue(fuel);
        //Change this if the parent rv object changes
        compass.SetValue(transform.parent.eulerAngles.y + compassRotationOffset);
        temperature.SetValue(EnviroManager.instance.Environment.Settings.temperature);
        steeringWheel.SetValue(steer * steeringWheelMultiplier);
    }
}
