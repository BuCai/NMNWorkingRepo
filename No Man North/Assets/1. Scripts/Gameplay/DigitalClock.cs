using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SurvivalTemplatePro.WorldManagement;
using TMPro;

public class DigitalClock : MonoBehaviour {
    [SerializeField] private TextMeshPro text;

    //FIX FOR TMP GLITCH
    private void Awake() {
        text.enabled = false;
    }
    private void Start() {
        text.enabled = true;
    }

    private void Update() {
        GameTime time = WorldManager.Instance.GetGameTime();
        text.text = string.Format("{0:00}:{1:00}", time.Hours, time.Minutes);
    }
}
