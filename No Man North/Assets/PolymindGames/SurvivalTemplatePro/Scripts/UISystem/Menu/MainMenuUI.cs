using UnityEngine;
using UnityEngine.UI;
using System.Collections;

namespace SurvivalTemplatePro.UISystem {
    public class MainMenuUI : Singleton<MainMenuUI> {


        private bool isLoading;

        public void Quit() {
            Application.Quit();
        }
        private void Awake() {
            STPGameStateManager.Instance.SetGameState(GameState.MainMenu);
        }

        public void LoadGame() {
            if (!isLoading)
                StartCoroutine(C_LoadGame());
        }

        private IEnumerator C_LoadGame() {
            isLoading = true;
            FadeScreenUI.Instance.Fade(true, 0.5f);
            yield return new WaitForSeconds(0.55f);
            LevelManager.Instance.LoadGame();
        }

        public void LoadLevel(string sceneName) {
            if (!isLoading)
                StartCoroutine(C_LoadLevel(sceneName));
        }

        private IEnumerator C_LoadLevel(string sceneName) {
            isLoading = true;
            FadeScreenUI.Instance.Fade(true, 0.5f);
            yield return new WaitForSeconds(0.55f);
            LevelManager.Instance.LoadScene(sceneName, UnityEngine.SceneManagement.LoadSceneMode.Single);
        }
    }
}