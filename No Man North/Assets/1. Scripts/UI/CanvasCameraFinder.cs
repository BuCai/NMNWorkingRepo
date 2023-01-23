using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using SurvivalTemplatePro;

//Quick script to assign the main camera to a screen space canvas and set plane distance
[RequireComponent(typeof(Canvas))]
public class CanvasCameraFinder : MonoBehaviour {

    [SerializeField] private float planeDistance = 1f;
    private bool settingsSet = false;
    private Canvas canvas;

    private void Awake() {
        canvas = GetComponent<Canvas>();
    }

    private void Update() {
        if (STPGameStateManager.Instance.gameState != GameState.Gameplay || Camera.main == null) {
            return;
        }
        if (canvas.worldCamera != Camera.main) {
            canvas.worldCamera = Camera.main;
        }
        if (!settingsSet) {
            canvas.planeDistance = planeDistance;
            settingsSet = true;
        }
    }

    public void SetCanvasCameraMode(bool on) {
        if (on) {
            canvas.renderMode = RenderMode.ScreenSpaceCamera;
        } else {
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        }
    }


}
