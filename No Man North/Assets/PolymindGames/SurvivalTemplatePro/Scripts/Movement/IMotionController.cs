using SurvivalTemplatePro.MovementSystem;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    public interface IMotionController : ICharacterModule
    {
        MotionStateType ActiveStateType { get; }
        MotionStateType PrevStateType { get; }

        ICharacterMotionState ActiveState { get; }
        ICharacterMotionState PrevState { get; }

        float VelocityMod { get; set; }
        float StepCycle { get; }

        event UnityAction onStepCycleEnded;
        event UnityAction onStateChanged;


        void AddStateEnterListener(MotionStateType stateType, StateTypeChangedCallback callback);
        void AddStateExitListener(MotionStateType stateType, StateTypeChangedCallback callback);

        void RemoveStateEnterListener(MotionStateType stateType, StateTypeChangedCallback callback);
        void RemoveStateExitListener(MotionStateType stateType, StateTypeChangedCallback callback);

        void AddStateLocker(Object locker, MotionStateType stateType);
        void RemoveStateLocker(Object locker, MotionStateType stateType);

        void ResetController();

        /// <summary>
        /// Transition to the given state.
        /// </summary>
        bool TrySetState(ICharacterMotionState state);

        /// <summary>
        /// Transition to a state with the given state type.
        /// </summary>
        bool TrySetState(MotionStateType stateType);

        /// <summary>
        /// Checks if the given state type is locked.
        /// </summary>
        bool IsStateLocked(MotionStateType stateType);

        ICharacterMotionState GetStateOfMotionType(MotionStateType stateType);
        T GetStateOfType<T>() where T : ICharacterMotionState;
    }

    public delegate void StateTypeChangedCallback();
}