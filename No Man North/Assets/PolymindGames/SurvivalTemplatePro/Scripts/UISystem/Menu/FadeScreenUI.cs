using System.Collections;
using UnityEngine;
using UnityEngine.Audio;

namespace SurvivalTemplatePro.UISystem {
    [RequireComponent(typeof(CanvasGroup))]
    public class FadeScreenUI : Singleton<FadeScreenUI> {
        [SerializeField]
        private CanvasGroup m_CanvasGroup;

        [SerializeField, Range(0f, 25f)]
        private float m_FadeSpeed = 2f;

        [Space]

        [SerializeField]
        private AudioMixerSnapshot m_FadeSnapshot;

        [SerializeField]
        private AudioMixerSnapshot m_DefaultSnapshot;


        public void Fade(bool enable, float fadeDelay = 0f, float speedMod = 1f) {
            StopAllCoroutines();

            // Alpha
            StartCoroutine(C_LerpAlpha(enable, fadeDelay, speedMod));

            // Audio
            if (enable)
                m_FadeSnapshot.TransitionTo(1 / speedMod);
            else
                m_DefaultSnapshot.TransitionTo(1 / speedMod);
        }

        private IEnumerator C_LerpAlpha(bool enable, float fadeDelay, float speedMod = 1f) {
            float targetAlpha = enable ? 1f : 0f;
            m_CanvasGroup.blocksRaycasts = enable;

            if (fadeDelay > 0.01f)
                yield return new WaitForSeconds(fadeDelay);

            while (Mathf.Abs(m_CanvasGroup.alpha - targetAlpha) > 0.01f) {
                m_CanvasGroup.alpha = Mathf.MoveTowards(m_CanvasGroup.alpha, targetAlpha, m_FadeSpeed * speedMod * Time.deltaTime);

                yield return null;
            }

            m_CanvasGroup.alpha = targetAlpha;
        }

        protected override void OnAwake() {
            m_CanvasGroup.alpha = 1f;

            //LevelManager.onGameLoadStart += OnGameLoadStart;
            LevelManager.onGameLoaded += OnGameLoaded;
        }

        private void OnDestroy() {
            //LevelManager.onGameLoadStart -= OnGameLoadStart;
            LevelManager.onGameLoaded -= OnGameLoaded;
        }

        private void OnGameLoadStart() => Fade(true, 0f, 15f);
        private void OnGameLoaded() => Fade(false, 1f, 0.5f);
    }
}