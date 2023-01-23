using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using SurvivalTemplatePro;
using SurvivalTemplatePro.UISystem;

[RequireComponent(typeof(CanvasGroup))]
public class LoadingScreenUI : MonoBehaviour {
    //Script that attaches the loading screen alpha to the fade screen alpha
    //Change getFadeAlpha method to change alpha source

    bool isLoading = false;
    private CanvasGroup loadingCanvasGroup;

    public Image loadingBar;

    private void Awake() {
        loadingCanvasGroup = GetComponent<CanvasGroup>();
        LevelManager.onGameLoadStart += LoadStart;
        LevelManager.onGameLoaded += LoadEnd;
    }

    private void OnDestroy() {
        LevelManager.onGameLoadStart -= LoadStart;
        LevelManager.onGameLoaded -= LoadEnd;
    }

    public void LoadStart() {
        isLoading = true;
    }

    bool loadEnd = false;
    public void LoadEnd() {
        loadEnd = true;
    }

    private void Update() {
        if (!isLoading) {
            return;
        }
        if (loadingBar != null) {
            loadingBar.fillAmount = LevelManager.Instance.LoadingProgress;
        }
        loadingCanvasGroup.alpha = getFadeAlpha();
        if (loadEnd && loadingCanvasGroup.alpha == 0) {
            isLoading = false;
            loadEnd = false;
        }
    }

    private CanvasGroup fadeCanvasGroup;
    private float getFadeAlpha() {
        if (fadeCanvasGroup == null) {
            fadeCanvasGroup = FindObjectOfType<FadeScreenUI>().gameObject.GetComponent<CanvasGroup>();
            if (fadeCanvasGroup == null) {
                return 0;
            }
        }
        return fadeCanvasGroup.alpha;
    }
}
