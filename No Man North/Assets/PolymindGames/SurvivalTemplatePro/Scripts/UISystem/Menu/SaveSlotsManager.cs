using SurvivalTemplatePro.SaveSystem;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem {
    public class SaveSlotsManager : PlayerUIBehaviour {
        public enum Mode { Closed, SaveSlots, LoadSlots }

        [SerializeField]
        private PanelUI m_Panel;

        [Space]

        [SerializeField]
        private Text m_Header;

        [SerializeField]
        private string m_SaveGameHeader = "SAVE GAME";

        [SerializeField]
        private string m_LoadGameHeader = "LOAD GAME";

        [Space]

        [SerializeField]
        private bool m_SpawnSlotsOnAwake;

        [SerializeField]
        private SaveSlotUI m_SaveSlotTemplate;

        [SerializeField]
        private RectTransform m_SlotsRoot;

        [SerializeField, Range(0, 10)]
        private int m_SaveSlotCount = 3;

        [Space]

        [SerializeField]
        private UnityEvent m_GameSaveEvent;

        [SerializeField]
        private UnityEvent m_GameLoadEvent;

        private Mode m_CurrentMode;
        private SaveSlotUI[] m_SaveSlots;


        public void RefreshSaveSlots() {
            List<GameData> gameSaves = SaveLoadManager.LoadAllSaves();

            foreach (SaveSlotUI slot in m_SaveSlots)
                slot.ShowNoSave();

            for (int i = 0; i < gameSaves.Count; i++) {
                GameData gameSave = gameSaves[i];

                if (m_SaveSlots.Length > gameSave.SaveId)
                    m_SaveSlots[gameSave.SaveId].ShowSave(gameSave.Screenshot, "Game Save " + (gameSave.SaveId + 1).ToString(), gameSave.DateTime.ToShortDateString() + " - " + gameSave.DateTime.ToShortTimeString(), gameSave.SceneData.Name);
            }
        }

        public void ClearAllSlots() {
            for (int i = 0; i < 10; i++)
                SaveLoadManager.DeleteSaveFile(i);

            RefreshSaveSlots();
        }

        public void SetMode(int mode) {
            var targetMod = (Mode)Mathf.Clamp(mode, 0, 2);
            SetMode(targetMod);
        }

        private void SetMode(Mode mode) {
            m_CurrentMode = mode;

            switch (mode) {
                case Mode.Closed:
                    m_Header.text = string.Empty;
                    AddButtonListeners();
                    m_Panel.Show(false);

                    break;
                case Mode.SaveSlots:
                    RefreshSaveSlots();
                    m_Header.text = m_SaveGameHeader;
                    AddButtonListeners();
                    m_Panel.Show(true);

                    break;
                case Mode.LoadSlots:
                    RefreshSaveSlots();
                    m_Header.text = m_LoadGameHeader;
                    AddButtonListeners();
                    m_Panel.Show(true);

                    break;
            }
        }

        private void AddButtonListeners() {
            for (int i = 0; i < m_SaveSlots.Length; i++) {
                SaveSlotUI slot = m_SaveSlots[i];
                slot.Button.onClick.RemoveAllListeners();

                int slotIndex = i;
                slot.Button.onClick.AddListener(() => OnSlotClicked(slotIndex));
            }
        }

        private void OnSlotClicked(int slotIndex) {
            if (m_CurrentMode == Mode.SaveSlots) {
                LevelManager.onGameSaved += OnGameSaved;
                LevelManager.Instance.SaveCurrentGame(slotIndex);
                m_GameSaveEvent.Invoke();
            } else if (m_CurrentMode == Mode.LoadSlots) {
                if (SaveLoadManager.SaveFileExists(slotIndex)) {
                    LevelManager.Instance.LoadSave(slotIndex);
                    m_GameLoadEvent.Invoke();
                }
            }
        }

        private void OnGameSaved() {
            LevelManager.onGameSaved -= OnGameSaved;

            var customActionManager = Player.GetModule<ICustomActionManager>();
            customActionManager.TryCancelAction();

            RefreshSaveSlots();
        }

        private void Awake() {
            if (m_SpawnSlotsOnAwake) {
                m_SaveSlots = new SaveSlotUI[m_SaveSlotCount];

                for (int i = 0; i < m_SaveSlotCount; i++)
                    m_SaveSlots[i] = Instantiate(m_SaveSlotTemplate.gameObject, m_SlotsRoot.position, m_SlotsRoot.rotation, m_SlotsRoot).GetComponent<SaveSlotUI>();
            } else {
                m_SaveSlots = GetComponentsInChildren<SaveSlotUI>();
            }

            SetMode(Mode.Closed);
        }
    }
}