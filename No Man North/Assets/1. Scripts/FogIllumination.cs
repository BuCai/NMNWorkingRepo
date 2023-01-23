using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VolumetricFogAndMist2;
using Enviro;

//Script to manually calculate fog brightness
//Script made quickly in a time crunch, refactor if needed

//NOTE: FOG PROFILE DISABLING DAY NIGHT CYCLE BROKEN IN THIS VERSION
//DO NOT ASSIGN SUN AND MOON LIGHTS ON THE VOLUMETRIC FOG MANAGER

public class FogIllumination : MonoBehaviour {

    public Light sun;
    public Light moon;
    public VolumetricFogProfile[] profiles;

    public AnimationCurve brightnessCurve;
    public float finalMultiplier = 1f;

    void Update() {
        if (profiles == null || profiles.Length == 0) {
            Debug.LogError("Profiles not assigned");
            return;
        }

        //Switch to average of rgb for equal color brightness distribution
        float diffuseBrightness = Mathf.Max(sun.intensity * sun.color.grayscale, moon.intensity * moon.color.grayscale);
        float ambientBrightness = RenderSettings.ambientIntensity * RenderSettings.ambientGroundColor.grayscale;
        float linearBrightness = (diffuseBrightness + ambientBrightness);
        float finalBrightness = brightnessCurve.Evaluate(linearBrightness) * finalMultiplier;

        foreach (VolumetricFogProfile profile in profiles) {
            profile.brightness = finalBrightness;
        }
    }
}
