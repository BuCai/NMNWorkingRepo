using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NWH.VehiclePhysics2;


public class RVRigidbodyHandler : MonoBehaviour {
    private VehicleController vehicleController;
    private Rigidbody rb;

    private void Awake() {
        vehicleController = GetComponent<VehicleController>();
        rb = GetComponent<Rigidbody>();
        if (vehicleController == null || rb == null) {
            Debug.LogError("Rv rigidbody or vehicle controller not found");
            return;
        }
        vehicleController.onWake.AddListener(OnVehicleWake);
        vehicleController.onSleep.AddListener(OnVehicleSleep);
    }

    private void OnVehicleWake() {
        rb.isKinematic = false;
    }
    private void OnVehicleSleep() {
        rb.isKinematic = true;
    }
}
