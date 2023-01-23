using UnityEngine;

namespace SurvivalTemplatePro.MovementSystem
{
    public abstract class CharacterMotionState : MonoBehaviour, ICharacterMotionState
    {
        public abstract MotionStateType StateType { get; }
        public abstract float StepCycleLength { get; }
        public abstract bool ApplyGravity { get; }
        public abstract bool SnapToGround { get; }

        protected IMotionController Controller => m_MotionController;
        protected ICharacterMotionInputHandler Input => m_Input;
        protected ICharacterMotor Motor => m_Motor;

        private IMotionController m_MotionController;
        private ICharacterMotionInputHandler m_Input;
        private ICharacterMotor m_Motor;


        public virtual void OnStateInitialized(IMotionController motionController, ICharacterMotionInputHandler input, ICharacterMotor motor)
        {
            m_MotionController = motionController;
            m_Input = input;
            m_Motor = motor;
        }

        public virtual bool IsStateValid() => true;

        public virtual void OnStateEnter() { }
        public abstract void UpdateLogic();
        public abstract Vector3 UpdateVelocity(Vector3 currentVelocity, float deltaTime);
        public virtual void OnStateExit() { }
    }
}