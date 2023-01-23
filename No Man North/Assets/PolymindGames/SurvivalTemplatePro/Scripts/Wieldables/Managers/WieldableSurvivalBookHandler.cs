using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.WieldableSystem
{
    [RequireComponent(typeof(IWieldablesController))]
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/wieldable#wieldable-survival-book-handler-module")]
    public class WieldableSurvivalBookHandler : CharacterBehaviour, IWieldableSurvivalBookHandler, ISaveableComponent
    {
        public bool InspectionActive
        {
            get => m_InspectionActive;
            set
            {
                if (value != m_InspectionActive)
                {
                    m_InspectionActive = value;

                    if (m_InspectionActive)
                    {
                        onInspectionStarted?.Invoke();
                    }
                    else
                    {
                        onInspectionEnded?.Invoke();
                    }
                }
            }
        }

        public IWieldable AttachedWieldable => m_SurvivalBookWieldable;
        public Transform LeftPages { get; private set; }
        public Transform RightPages { get; private set; }

        public event UnityAction onInspectionStarted;
        public event UnityAction onInspectionEnded;

        [SerializeField]
        [Tooltip("Corresponding survival book wieldable prefab.")]
        private Wieldable m_SurvivalBookPrefab;

        [SerializeField]
        [Tooltip("The left pages object name of the book (used to parent the UI).")]
        private string m_LeftPagesObjectName;

        [SerializeField]
        [Tooltip("The right pages object name of the book (used to parent the UI).")]
        private string m_RightPagesObjectName;

        [Space]

        [SerializeField, Range(0f, 10f)]
        [Tooltip("How often can the survival book be enabled/disabled (in seconds).")]
        private float m_ToggleCooldown = 0.75f;

        [SerializeField, HideInInspector]
        private bool m_InspectionActive = false;

        private float m_NextTimeCanToggle = -1f;

        private IWieldablesController m_Controller;
        private IWieldableSelectionHandler m_SelectionHandler;
        private IPauseHandler m_PauseHandler;
        private IWieldable m_SurvivalBookWieldable;


        #region Save & Load
        public void LoadMembers(object[] members)
        {
            m_InspectionActive = (bool)members[0];
        }

        public object[] SaveMembers()
        {
            return new object[] { m_InspectionActive };
        }
        #endregion

        public override void OnInitialized()
        {
            GetModule(out m_PauseHandler);
            GetModule(out m_SelectionHandler);
            GetModule(out m_Controller);

            m_SurvivalBookWieldable = m_Controller.SpawnWieldable(m_SurvivalBookPrefab);

            LeftPages = m_SurvivalBookWieldable.transform.FindDeepChild(m_LeftPagesObjectName);
            RightPages = m_SurvivalBookWieldable.transform.FindDeepChild(m_RightPagesObjectName);

            if (m_InspectionActive)
                ToggleInspection();
        }

        public void ToggleInspection() 
        {
            if (Time.time < m_NextTimeCanToggle)
                return;

            if (!InspectionActive)
            {
                if (!m_PauseHandler.PauseActive && m_Controller.TryEquipWieldable(m_SurvivalBookWieldable, 1.6f))
                {
                    InspectionActive = true;
                    m_PauseHandler.RegisterLocker(this, new PlayerPauseParams(true, true, false, false));

                    m_Controller.onWieldableEquipped += OnWieldableEquipped;
                }
            }
            else if (m_PauseHandler.PauseActive)
            {
                m_SelectionHandler.SelectAtIndex(m_SelectionHandler.SelectedIndex);
                InspectionActive = false;

                m_PauseHandler.UnregisterLocker(this);

                m_Controller.onWieldableEquipped -= OnWieldableEquipped;
            }

            m_NextTimeCanToggle = Time.time + m_ToggleCooldown;
        }

        private void OnWieldableEquipped(IWieldable wieldable)
        {
            if (!InspectionActive || wieldable == m_SurvivalBookWieldable)
                return;

            ToggleInspection();
        }
    }
}