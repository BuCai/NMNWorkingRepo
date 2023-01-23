using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem {
    public class MapSelectionMenuUI : MonoBehaviour {
        #region Internal
        [System.Serializable]
        private class MapUI {
            public SceneField Scene;
            public string Name;
            public Sprite Sprite;
        }
        #endregion

        [SerializeField, Range(0f, 10f)]
        private float m_LoadDelay;

        [SpaceArea]

        [SerializeField]
        private GameObject m_MapSelectionTemplate;

        [SerializeField]
        private RectTransform m_SpawnRoot;

        [SpaceArea]

        [SerializeField, LabelByChild("Name"), ReorderableList]
        private MapUI[] m_Maps;

        private bool m_IsLoading;


        private void Awake() {
            SetupTemplates();
        }

        private void SetupTemplates() {
            foreach (var map in m_Maps) {
                var template = Instantiate(m_MapSelectionTemplate, m_SpawnRoot);

                // Set the template text to the map name
                var templateName = template.GetComponentInChildren<Text>();
                if (templateName != null)
                    templateName.text = map.Name;

                // Set the template sprite to the map sprite
                var templateSprite = template.transform.FindDeepChild("Sprite").GetComponent<Image>();
                if (templateSprite != null)
                    templateSprite.sprite = map.Sprite;

                // Set the template button to load the map
                var templateButton = template.GetComponent<Button>();
                if (templateButton != null)
                    templateButton.onClick.AddListener(() => LoadLevel(map.Scene));
                else
                    Debug.LogError("Template button not found");
            }
        }

        private void LoadLevel(string sceneName) {
            if (!m_IsLoading)
                StartCoroutine(C_LoadLevel(sceneName));
        }

        private IEnumerator C_LoadLevel(string sceneName) {
            m_IsLoading = true;
            FadeScreenUI.Instance.Fade(true, 0.2f);
            yield return new WaitForSeconds(m_LoadDelay);
            LevelManager.Instance.LoadScene(sceneName, UnityEngine.SceneManagement.LoadSceneMode.Single);
        }
    }
}