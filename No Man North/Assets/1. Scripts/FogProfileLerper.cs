using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VolumetricFogAndMist2;
using SurvivalTemplatePro;

public class FogProfileLerper : MonoBehaviour {
    public float transitionStartDistance = 2000; //Distance from center of volume where transition starts
    public float transitionEndDistance = 1900; //Distance from center of volume where transition completes

    public VolumetricFogProfile distantProfile;
    public VolumetricFogProfile closeProfile;
    public VolumetricFog targetVolume;

    private VolumetricFogProfile lerpProfile;
    private bool gameLoaded;
    private Transform player;

    private void Awake() {
        LevelManager.onGameLoaded += OnGameLoaded;
    }
    private void OnDestroy() {
        LevelManager.onGameLoaded -= OnGameLoaded;
    }

    private void Start() {
        lerpProfile = Instantiate(distantProfile);
        targetVolume.profile = lerpProfile;
        if (transitionEndDistance > transitionStartDistance) {
            Debug.LogError("Transition start distance must be larger than transition end distance");
        }
    }

    private void OnGameLoaded() {
        gameLoaded = true;
    }

    private void Update() {
        if (!gameLoaded)
            return;
        if (player == null) {
            assignPlayer();
            if (player == null) {
                return;
            }
        }
        float dist = Vector2.Distance(new Vector2(player.transform.position.x, player.transform.position.z), new Vector2(targetVolume.transform.position.x, targetVolume.transform.position.z));
        float t = 1 - (Mathf.InverseLerp(transitionEndDistance, transitionStartDistance, dist));
        lerpProfile.Lerp(distantProfile, closeProfile, t);
        targetVolume.UpdateMaterialProperties();
    }

    private void assignPlayer() {
        player = GameObject.FindGameObjectWithTag("Player").transform;
    }
}
