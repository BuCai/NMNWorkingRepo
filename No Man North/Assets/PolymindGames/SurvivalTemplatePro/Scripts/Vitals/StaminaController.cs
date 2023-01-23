using SurvivalTemplatePro.MovementSystem;
using SurvivalTemplatePro.WieldableSystem;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro {
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/health#stamina-controller-module")]
    public class StaminaController : CharacterBehaviour, IStaminaController {
        #region Internal
        [System.Serializable]
        private class StaminaState {
            public MotionStateType StateType;

            [Range(-1f, 1f)]
            public float EnterChange;

            [Range(-1f, 1f)]
            public float ExitChange;

            [Range(-1f, 1f)]
            public float ChangeRatePerSec;
        }
        #endregion

        public float Stamina {
            get => m_Stamina;
            set {
                if (m_Stamina != value) {
                    m_Stamina = value;
                    onStaminaChanged?.Invoke(m_Stamina);
                }
            }
        }

        public event UnityAction<float> onStaminaChanged;

        [SerializeField]
        private StaminaState m_DefaultState;

        [SerializeField, Range(0f, 5f)]
        [Tooltip("How much time the stamina regeneration will be paused after it gets lowered.")]
        private float m_RegenerationPause = 3f;

        [SpaceArea]

        [SerializeField]
        [LabelByChild("StateType"), ReorderableList(ListStyle.Round, Foldable = true)]
        private StaminaState[] m_StaminaStates;

        private IMotionController m_Motion;
        private IStaminaDepleter m_Depleter;
        private IWieldablesController m_Wieldables;

        private float m_Stamina;
        private float m_NextAllowedRegenTime;
        private StaminaState m_CurrentState;


        public override void OnInitialized() {
            m_Stamina = 1f;
            m_CurrentState = m_DefaultState;

            if (TryGetModule(out m_Motion))
                m_Motion.onStateChanged += OnStateChanged;

            if (TryGetModule(out m_Wieldables))
                m_Wieldables.onWieldableEquipped += OnWieldableChanged;
        }

        private void Update() {
            if (!IsInitialized)
                return;

            // Decrease stamina.
            if (m_CurrentState.ChangeRatePerSec < 0f)
                AdjustStamina(m_CurrentState.ChangeRatePerSec * Time.deltaTime);

            // Regenerate stamina.
            else if (Time.time > m_NextAllowedRegenTime)
                AdjustStamina(m_CurrentState.ChangeRatePerSec * Time.deltaTime);
        }

        private void OnDestroy() {
            if (m_Motion != null)
                m_Motion.onStateChanged -= OnStateChanged;

            if (m_Wieldables != null)
                m_Wieldables.onWieldableEquipped -= OnWieldableChanged;
        }

        private void OnStateChanged() {
            AdjustStamina(m_CurrentState.ExitChange);

            m_CurrentState = GetCurrentState(m_Motion.ActiveStateType);

            AdjustStamina(m_CurrentState.EnterChange);
        }

        private StaminaState GetCurrentState(MotionStateType stateType) {
            for (int i = 0; i < m_StaminaStates.Length; i++) {
                if (m_StaminaStates[i].StateType == stateType)
                    return m_StaminaStates[i];
            }

            return m_DefaultState;
        }

        private void OnWieldableChanged(IWieldable wieldable) {
            if (m_Depleter != null)
                m_Depleter.onDepleteStamina -= OnDepleteStamina;

            m_Depleter = wieldable as IStaminaDepleter;

            if (m_Depleter != null)
                m_Depleter.onDepleteStamina += OnDepleteStamina;
        }

        private void OnDepleteStamina(float amount) => AdjustStamina(-amount);

        private void AdjustStamina(float adjustment) {
            Stamina = Mathf.Clamp01(Stamina + adjustment);

            if (adjustment < 0f)
                m_NextAllowedRegenTime = Time.time + m_RegenerationPause;
        }
    }
}