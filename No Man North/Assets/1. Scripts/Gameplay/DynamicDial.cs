using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//Modular script to handle a rotation hand in a dial dynamically changing based on set values
//SetValue() must be called from an external script
public class DynamicDial : MonoBehaviour {
    //This will almost always be set to the gameobject the script is attached to, leaving it as a value for modularity purposes
    private GameObject pivotObj;

    //Values for the minimum and maximum rotation the hand can reach
    [SerializeField] private float minValue;
    [SerializeField] private float maxValue;

    //Whether to clamp the rotation between min and max
    [SerializeField] private bool clamp = true;

    //Minimum and maximum LOCAL rotation the hands can reach (Will be calculated as quaternions)
    [SerializeField] private Vector3 minRotation;
    [SerializeField] private Vector3 maxRotation;

    /*Whether to lerp as quaternions or not:
    -When this is disabled, rotations will be lerped numerically from one vector3 to the other  (Uses Vector3.lerp)
    -When this is enabled, rotations will lerp going by the shortest distance between the rotations (Uses Quaternion.Slerp)
    */
    [SerializeField] private bool quaternionLerp = false;

    [SerializeField] private float curValue;

    private void Awake() {
        pivotObj = gameObject;
        if (pivotObj == null) {
            Debug.LogError("Dial pivot not assigned");
        }
        if (minValue >= maxValue) {
            Debug.LogError("Maximum value needs to be bigger than minimum value");
        }
        SetValue(curValue);
    }

    //Re-Configure the values
    public void Configure(float minVal, float maxVal, bool _clamp, Vector3 minRot, Vector3 maxRot, bool _quaternionLerp) {
        if (minVal >= maxVal) {
            Debug.LogError("Maximum value needs to be bigger than minimum value, can't configure");
            return;
        }
        minValue = minVal;
        maxValue = maxVal;
        clamp = _clamp;
        minRotation = minRot;
        maxRotation = maxRot;
        quaternionLerp = _quaternionLerp;
    }

    //Update the value and the hands rotations accordingly
    public void SetValue(float value) {
        if (clamp) {
            curValue = Mathf.Clamp(value, minValue, maxValue);
            if (quaternionLerp) {
                pivotObj.transform.localRotation = Quaternion.Slerp(Quaternion.Euler(minRotation), Quaternion.Euler(maxRotation), (curValue - minValue) / (maxValue - minValue));
            } else {
                pivotObj.transform.localRotation = Quaternion.Euler(Vector3.Lerp(minRotation, maxRotation, (curValue - minValue) / (maxValue - minValue)));
            }
        } else {
            curValue = value;
            if (quaternionLerp) {
                pivotObj.transform.localRotation = Quaternion.SlerpUnclamped(Quaternion.Euler(minRotation), Quaternion.Euler(maxRotation), (curValue - minValue) / (maxValue - minValue));
            } else {
                pivotObj.transform.localRotation = Quaternion.Euler(Vector3.LerpUnclamped(minRotation, maxRotation, (curValue - minValue) / (maxValue - minValue)));
            }
        }
    }

    //DEBUG DEBUG DEBUG
    /*
    private void Update() {
        SetValue(curValue);
    }
    */
}
