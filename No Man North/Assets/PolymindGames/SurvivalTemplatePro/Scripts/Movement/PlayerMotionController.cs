using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.MovementSystem
{
    [AddComponentMenu("Movement/Motion Controller")]
    public class PlayerMotionController : CharacterBehaviour, IMotionController, ISaveableComponent
    {
        public MotionStateType ActiveStateType => m_ActiveState != null ? m_ActiveState.StateType : m_DefaultState.StateType;
        public MotionStateType PrevStateType => m_PrevState != null ? m_PrevState.StateType : m_DefaultState.StateType;

        public ICharacterMotionState ActiveState => m_ActiveState;
        public ICharacterMotionState PrevState => m_PrevState;

        public float VelocityMod { get; set; } = 1f;
        public float StepCycle => m_StepCycle;

        public event UnityAction onStepCycleEnded;
        public event UnityAction onStateChanged;

        [SerializeField]
        private PlayerMotionInput m_InputHandler;

        [SerializeField]
        private CharacterControllerMotor m_CharacterMotor;

        [Space]

        [SerializeField]
        private CharacterMotionState m_DefaultState;

        [Tooltip("How fast will the transtion between different step lengths happen (used for footsteps).")]
        [SerializeField, Range(0.1f, 10f)]
        private float m_StepLerpSpeed = 1f;

        private ICharacterMotionState m_ActiveState;
        private ICharacterMotionState m_PrevState;
        private ICharacterMotor m_CMotor;

        private readonly List<ICharacterMotionState> m_States = new List<ICharacterMotionState>();
        private readonly Dictionary<MotionStateType, List<Object>> m_StateLockers = new Dictionary<MotionStateType, List<Object>>();
        private readonly Dictionary<MotionStateType, StateTypeChangedCallback> m_StateEnterEvents = new Dictionary<MotionStateType, StateTypeChangedCallback>();
        private readonly Dictionary<MotionStateType, StateTypeChangedCallback> m_StateExitEvents = new Dictionary<MotionStateType, StateTypeChangedCallback>();
        private StateTypeChangedCallback m_TempDelegateHolder;

        private float m_DistMovedSinceLastCycleEnded;
        private float m_CurrentStepLength;
        private float m_StepCycle;


        #region State Change Events
        public void AddStateEnterListener(MotionStateType stateType, StateTypeChangedCallback callback)
        {
            if (m_StateEnterEvents.TryGetValue(stateType, out m_TempDelegateHolder))
            {
                m_TempDelegateHolder += callback;
                m_StateEnterEvents[stateType] = m_TempDelegateHolder;
            }
            else
            {
                m_TempDelegateHolder += callback;
                m_StateEnterEvents.Add(stateType, m_TempDelegateHolder);
            }
        }

        public void AddStateExitListener(MotionStateType stateType, StateTypeChangedCallback callback)
        {
            if (m_StateExitEvents.TryGetValue(stateType, out m_TempDelegateHolder))
            {
                m_TempDelegateHolder += callback;
                m_StateExitEvents[stateType] = m_TempDelegateHolder;
            }
            else
            {
                m_TempDelegateHolder += callback;
                m_StateExitEvents.Add(stateType, m_TempDelegateHolder);
            }
        }

        public void RemoveStateEnterListener(MotionStateType stateType, StateTypeChangedCallback callback)
        {
            if (m_StateEnterEvents.TryGetValue(stateType, out m_TempDelegateHolder))
            {
                m_TempDelegateHolder -= callback;
                m_StateEnterEvents[stateType] = m_TempDelegateHolder;
            }
        }

        public void RemoveStateExitListener(MotionStateType stateType, StateTypeChangedCallback callback)
        {
            if (m_StateExitEvents.TryGetValue(stateType, out m_TempDelegateHolder))
            {
                m_TempDelegateHolder -= callback;
                m_StateExitEvents[stateType] = m_TempDelegateHolder;
            }
        }
        #endregion

        #region State Accessing
        public ICharacterMotionState GetStateOfMotionType(MotionStateType stateType)
        {
            for (int i = 0; i < m_States.Count; i++)
            {
                if (m_States[i].StateType == stateType)
                    return m_States[i];
            }    

            return null;
        }

        public T GetStateOfType<T>() where T : ICharacterMotionState
        {
            for (int i = 0; i < m_States.Count; i++)
            {
                if (m_States[i].GetType() == typeof(T))
                    return (T)m_States[i];
            }

            return default;
        }
        #endregion

        #region State Changing
        public bool TrySetState(ICharacterMotionState state) 
        {
            if (state == null || m_ActiveState == state || !state.enabled || !state.IsStateValid())
                return false;

            // Handles state previous state exit.
            if (m_ActiveState != null)
            {
                m_ActiveState.OnStateExit();

                if (m_StateExitEvents.TryGetValue(m_ActiveState.StateType, out var stateExitEvent))
                    stateExitEvent();
            }

            m_PrevState = m_ActiveState;

            // Handles next state enter.
            m_ActiveState = state;
            m_ActiveState.OnStateEnter();

            if (m_StateEnterEvents.TryGetValue(state.StateType, out var stateEnterEvent))
                stateEnterEvent();

            onStateChanged?.Invoke();

            return true;
        }

        public bool TrySetState(MotionStateType stateType)
        {
            var state = GetStateOfMotionType(stateType);
            return TrySetState(state);
        }

        public void ResetController()
        {
            m_PrevState = m_ActiveState;

            // Handles state previous state exit.
            if (m_ActiveState != null)
                m_ActiveState.OnStateExit();

            // Handles next state enter.
            m_ActiveState = m_DefaultState;
            m_ActiveState.OnStateEnter();

            m_InputHandler.ResetAllInputs();

            onStateChanged?.Invoke();
        }

        private void ForceSetState(ICharacterMotionState state)
        {
            // Handles state previous state exit.
            if (m_ActiveState != null)
            {
                m_ActiveState.OnStateExit();

                if (m_StateExitEvents.TryGetValue(m_ActiveState.StateType, out var stateExitEvent))
                    stateExitEvent();
            }

            // Handles next state enter.
            m_ActiveState = state;
            m_ActiveState.OnStateEnter();

            if (m_StateEnterEvents.TryGetValue(state.StateType, out var stateEnterEvent))
                stateEnterEvent();

            onStateChanged?.Invoke();
        }
        #endregion

        #region Initialization
        public override void OnInitialized()
        {
            GetComponentsInChildren(m_States);
            GetModule(out m_CMotor);

            foreach (var state in m_States)
                state.OnStateInitialized(this, m_InputHandler, m_CharacterMotor);

            m_CMotor.SetMotionInput(GetMotionInput);
        }
        #endregion

        #region Update Loop
        private void GetMotionInput(ref Vector3 velocity, out bool useGravity, out bool snapToGround)
        {
            if (m_ActiveState == null)
                TrySetState(m_DefaultState);

            m_InputHandler.TickInput();

            float deltaTime = Time.deltaTime;

            useGravity = m_ActiveState.ApplyGravity;
            snapToGround = m_ActiveState.SnapToGround;
            velocity = m_ActiveState.UpdateVelocity(velocity, deltaTime);

            // Update the step cycle, mainly used for footsteps
            UpdateStepCycle(deltaTime);

            m_ActiveState.UpdateLogic();
        }
        #endregion

        #region State Locking
        public void AddStateLocker(Object locker, MotionStateType stateType)
        {
            List<Object> list;

            // Gets existing locker list for the given state type if available
            if (m_StateLockers.TryGetValue(stateType, out list))
            {
                int prevCount = list.Count;

                list.Add(locker);

                if (prevCount == 0 && list.Count != prevCount)
                    DisableAllStatesOfType(stateType);
            }
            // Creates a new locker list for the given state type
            else
            {
                list = new List<Object> { locker };
                m_StateLockers.Add(stateType, list);

                DisableAllStatesOfType(stateType);
            }
        }

        public void RemoveStateLocker(Object locker, MotionStateType stateType)
        {
            // Gets existing locker list for the given state type if available
            if (m_StateLockers.TryGetValue(stateType, out var list))
            {
                list.Remove(locker);

                if (list.Count == 0)
                    EnableAllStatesOfType(stateType);
            }
        }

        public bool IsStateLocked(MotionStateType stateType)
        {
            if (m_StateLockers.TryGetValue(stateType, out var list))
            {
                if (list.Count > 0)
                    return true;
            }

            return false;
        }

        private void EnableAllStatesOfType(MotionStateType stateType) 
        {
            for (int i = 0; i < m_States.Count; i++)
            {
                if (m_States[i].StateType == stateType)
                    m_States[i].enabled = true;
            }
        }

        private void DisableAllStatesOfType(MotionStateType stateType)
        {
            for (int i = 0; i < m_States.Count; i++)
            {
                if (m_States[i].StateType == stateType)
                    m_States[i].enabled = false;
            }
        }
        #endregion

        #region Step Cycle
        private void UpdateStepCycle(float deltaTime)
        {
            if (!m_CharacterMotor.IsGrounded)
                return;

            // Advance step
            m_DistMovedSinceLastCycleEnded += m_CharacterMotor.Velocity.magnitude * deltaTime;

            float targetStepLength = Mathf.Max(m_ActiveState.StepCycleLength, 1f);

            m_CurrentStepLength = Mathf.MoveTowards(m_CurrentStepLength, targetStepLength, deltaTime * m_StepLerpSpeed);

            // If the step cycle is complete, reset it, and send a notification.
            if (m_DistMovedSinceLastCycleEnded > m_CurrentStepLength)
            {
                m_DistMovedSinceLastCycleEnded -= m_CurrentStepLength;
                onStepCycleEnded?.Invoke();
            }

            m_StepCycle = m_DistMovedSinceLastCycleEnded / m_CurrentStepLength;
        }
        #endregion

        #region Save & Load
        public void LoadMembers(object[] members)
        {
            var motionType = (MotionStateType)members[0];

            var state = GetStateOfMotionType(motionType);
            ForceSetState(state);
        }

        public object[] SaveMembers()
        {
            return new object[] { ActiveStateType };
        }
        #endregion
    }
}