using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class SaveSlotUI : MonoBehaviour
    {
        public Button Button => m_Button;

        [SerializeField]
        private Button m_Button;

        [Space]

        [SerializeField]
        private RawImage m_Screenshot;

        [Space]

        [SerializeField]
        private Text m_SaveName;

        [SerializeField]
        private Text m_SaveTime;

        [SerializeField]
        private Text m_MapName;

        [Space]

        [SerializeField]
        private GameObject m_NoSaveObject;


        public void ShowSave(Texture screenshot, string saveName, string saveTime, string mapName)
        {
            m_Screenshot.gameObject.SetActive(true);
            m_SaveName.gameObject.SetActive(true);
            m_SaveTime.gameObject.SetActive(true);
            m_MapName.gameObject.SetActive(true);

            m_Screenshot.texture = screenshot;
            m_SaveName.text = saveName;
            m_SaveTime.text = saveTime;
            m_MapName.text = mapName;

            m_NoSaveObject.SetActive(false);
        }

        public void ShowNoSave()
        {
            m_Screenshot.gameObject.SetActive(false);
            m_SaveName.gameObject.SetActive(false);
            m_SaveTime.gameObject.SetActive(false);
            m_MapName.gameObject.SetActive(false);

            m_NoSaveObject.SetActive(true);
        }
    }
}