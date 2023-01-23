using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

namespace SurvivalTemplatePro.UISystem {
    public class PauseMenuUI : PlayerUIBehaviour {
        [SerializeField]
        private PanelUI m_Panel;

        [SerializeField]
        private SceneField m_MainMenuScene;

        [Title("Actions")]

        [SerializeField]
        private InputActionReference m_PauseInput;

        [Title("Events")]

        [SerializeField]
        private UnityEvent m_PauseCallback;

        [SerializeField]
        private UnityEvent m_ResumeCallback;

        private float m_PanelToggleTimer;
        private bool m_IsActive = false;

        private IPauseHandler m_PauseHandler;


        public override void OnAttachment() {
            GetModule(out m_PauseHandler);

            m_PauseInput.action.Enable();
            m_PauseInput.action.performed += TogglePauseMenu;
        }

        public override void OnDetachment() {
            m_PauseInput.action.Disable();
            m_PauseInput.action.performed -= TogglePauseMenu;
        }

        public void QuitToMenu() => LevelManager.Instance.LoadScene(m_MainMenuScene, UnityEngine.SceneManagement.LoadSceneMode.Single);
        public void QuitToDesktop() => Application.Quit();

        public void TogglePauseMenu() {
            if (Time.time > m_PanelToggleTimer && ((m_PauseHandler.PauseActive && m_IsActive) || (!m_PauseHandler.PauseActive && !m_IsActive))) {
                m_IsActive = !m_IsActive;
                m_PanelToggleTimer = Time.time + 0.3f;

                if (m_IsActive)
                    Pause();
                else
                    Unpause();
            }
        }

        private void Pause() {
            m_PauseHandler.RegisterLocker(this, new PlayerPauseParams(true, true, true, true));
            m_Panel.Show(true);
            m_PauseCallback?.Invoke();
        }

        private void Unpause() {
            m_PauseHandler.UnregisterLocker(this);
            m_Panel.Show(false);
            m_ResumeCallback?.Invoke();
        }

        private void TogglePauseMenu(InputAction.CallbackContext context) => TogglePauseMenu();
    }
}