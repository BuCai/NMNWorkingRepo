using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SurvivalTemplatePro;

//Script for the interior thermometer, uses data from the tempzone, adjusts the scale on the z axis
public class InteriorThermometer : MonoBehaviour {
    [SerializeField] private Transform objTransform;

    [SerializeField] private float minTemp = 0;
    [SerializeField] private float maxTemp = 45;
    [SerializeField] private float minTempScale;
    [SerializeField] private float maxTempScale;

    [SerializeField] private TemperatureZone tempZone;

    //Time it takes for a temperature change to fully settle
    [SerializeField] private float tempChangeTime = 10f;


    private float curTemp;
    private float curTempDelta = 0;

    private void Update() {
        curTemp = Mathf.SmoothDamp(curTemp, tempZone.ZoneTemperature, ref curTempDelta, tempChangeTime);
        float t = Mathf.InverseLerp(minTemp, maxTemp, curTemp);
        objTransform.localScale = new Vector3(objTransform.localScale.x, objTransform.localScale.y, Mathf.Lerp(minTempScale, maxTempScale, t));
    }
}
