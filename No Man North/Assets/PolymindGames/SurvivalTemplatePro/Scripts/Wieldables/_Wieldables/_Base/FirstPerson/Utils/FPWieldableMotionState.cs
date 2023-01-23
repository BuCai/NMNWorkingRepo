using System;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem {
    [Serializable]
    public class FPWieldableMotionState {
        #region Internal
        [Serializable]
        public class OffsetModule {
            public Vector3 PositionOffset;
            public Vector3 RotationOffset;
        }

        [Serializable]
        public class BobModule {
            public Vector3 PositionAmplitude;
            public Vector3 RotationAmplitude;
        }
        #endregion

        public MotionStateType StateType = MotionStateType.Idle;

        [InfoBox("The strength of outside forces (e.g. Sway, Retraction, Fall Impact etc.) when the wieldable is in this state.")]
        [Range(0f, 10f)]
        public float OutsideForcesStrength = 1f;

        [Space]

        public Spring.Settings PositionSpring = Spring.Settings.Default;
        public Spring.Settings RotationSpring = Spring.Settings.Default;

        [Space]

        [Tooltip("Offset that will be applied to the wieldable when staying in this state.", order = 1)]
        public OffsetModule Offset;

        [Tooltip("Offset that will be applied to the wieldable when staying in this state.")]
        public BobModule Bob;

        [Tooltip("Random noise that will be applied when in this state.")]
        public NoiseMotionModule Noise;

        [Space]

        [Tooltip("Forces that will be applied when entering/exiting this state.")]
        public SpringForce EnterForce;

        [Tooltip("Forces that will be applied when entering/exiting this state.")]
        public SpringForce ExitForce;


        public FPWieldableMotionState GetClone(MotionStateType stateType) {
            var clone = MemberwiseClone() as FPWieldableMotionState;
            clone.StateType = stateType;

            return clone;
        }

        public override string ToString() => StateType.ToString();
    }
}