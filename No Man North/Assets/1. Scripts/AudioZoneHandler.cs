using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Enviro;

public class AudioZoneHandler : MonoBehaviour {

    private GameObject audioZoneObj;
    private AudioZone audioZone;

    private float startingAmbientVolume = 1f;
    private float startingWeatherVolume = 1f;
    private float startingThunderVolume = 1f;

    private void Start() {
        startingAmbientVolume = EnviroManager.instance.Audio.Settings.ambientMasterVolume;
        startingAmbientVolume = EnviroManager.instance.Audio.Settings.weatherMasterVolume;
        startingThunderVolume = EnviroManager.instance.Audio.Settings.thunderMasterVolume;
    }

    private void FixedUpdate() {
        Vector3 checkPosOffset = new Vector3(0, -0.75f, 0);
        Collider[] cols = Physics.OverlapSphere(transform.position + checkPosOffset, 0.05f, LayerMask.GetMask("AudioZone"), QueryTriggerInteraction.Collide);
        if (cols == null || cols.Length == 0) {
            if (audioZoneObj != null) {
                audioZoneObj = null;
                audioZoneObj = null;
                UpdateVolumes();
            }
            return;
        } else if (audioZoneObj != null && cols[0].gameObject == audioZoneObj) {
            return;
        }
        audioZoneObj = cols[0].gameObject;
        audioZone = cols[0].GetComponent<AudioZone>();
        UpdateVolumes();
    }

    private void UpdateVolumes() {
        if (audioZoneObj == null) {
            EnviroManager.instance.Audio.Settings.ambientMasterVolume = startingAmbientVolume;
            EnviroManager.instance.Audio.Settings.weatherMasterVolume = startingWeatherVolume;
            EnviroManager.instance.Audio.Settings.thunderMasterVolume = startingThunderVolume;
        } else {
            EnviroManager.instance.Audio.Settings.ambientMasterVolume = audioZone.ambientVolume;
            EnviroManager.instance.Audio.Settings.weatherMasterVolume = audioZone.weatherVolume;
            EnviroManager.instance.Audio.Settings.thunderMasterVolume = audioZone.thunderVolume;
        }
    }
}
