using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VolumetricFogAndMist2;
using SurvivalTemplatePro;

[RequireComponent(typeof(VolumetricFog))]
public class FogCharacterControllerAssigner : MonoBehaviour {

    bool gameLoaded = false;

    private void Awake() {
        LevelManager.onGameLoaded += OnGameLoaded;
    }
    private void OnGameLoaded() {
        gameLoaded = true;
    }
    private void Update() {
        if (!gameLoaded)
            return;

        GameObject player = GameObject.FindGameObjectWithTag("Player");
        if (player == null)
            return;

        VolumetricFog fog = GetComponent<VolumetricFog>();
        fog.fadeController = player.transform;
        Destroy(this);
    }
}
