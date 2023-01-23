using System.Collections;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class DeathUI : PlayerUIBehaviour
    {
        [SerializeField, Range(0f, 10f)]
        private float m_FadeDeathDelay = 2f;

        [SerializeField, Range(0f, 10f)]
        private float m_FadeSpawnDelay = 3f;

        [SerializeField, Range(0f, 50f)]
        private float m_ShowRespawnButtonDelay = 5f;

        [Space]

        [SerializeField]
        private Text m_RespawnTimeText;

        [SerializeField]
        private Button m_RespawnButton;

        [Space]

        [SerializeField]
        private AudioMixerSnapshot m_NotAliveSnapshot;

        [SerializeField]
        private AudioMixerSnapshot m_DefaultSnapshot;


        /// <summary>
        /// Respawn the player by restoring the health to the max amount
        /// </summary>
        public void RespawnPlayer() 
        {
            Player.HealthManager.RestoreHealth(Player.HealthManager.MaxHealth);
            FadeScreenUI.Instance.Fade(false, m_FadeSpawnDelay);

            // Audio
            m_DefaultSnapshot.TransitionTo(m_FadeSpawnDelay * 2f);

            m_RespawnButton.gameObject.SetActive(false);
            m_RespawnTimeText.enabled = false;
        }

        public override void OnAttachment()
        {
            m_RespawnButton.onClick.AddListener(RespawnPlayer);

            m_RespawnButton.gameObject.SetActive(false);
            m_RespawnTimeText.enabled = false;

            Player.HealthManager.onDeath += OnPlayerDeath;
        }

        public override void OnDetachment()
        {
            m_RespawnButton.onClick.RemoveListener(RespawnPlayer);

            Player.HealthManager.onDeath -= OnPlayerDeath;
        }

        private void OnPlayerDeath()
        {
            StartCoroutine(C_ShowRespawnPanel());
            FadeScreenUI.Instance.Fade(true, m_FadeDeathDelay);

            // Audio
            m_NotAliveSnapshot.TransitionTo(m_FadeDeathDelay * 2f);
        }

        private IEnumerator C_ShowRespawnPanel() 
        {
            m_RespawnButton.gameObject.SetActive(true);
            m_RespawnButton.interactable = false;
            m_RespawnTimeText.enabled = true;

            float currentTimeLeft = m_ShowRespawnButtonDelay;

            while (currentTimeLeft > 0.01f)
            {
                m_RespawnTimeText.text = currentTimeLeft.ToString("0.0");

                currentTimeLeft -= Time.deltaTime;

                yield return null;
            }

            m_RespawnTimeText.text = "Respawn";
            m_RespawnButton.interactable = true;
        }
    }
}