using System;
using UnityEngine;

namespace SurvivalTemplatePro.CameraSystem
{
    [Serializable]
    public class CameraMotionState
    {
        public MotionStateType StateType = MotionStateType.Idle;

        [InfoBox("The strength of outside forces (e.g. Sway, Fall Impact etc.) when the camera is in this state.")]
        [Range(0f, 10f)]
        public float OutsideForcesStrength = 1f;

        [Space]

        public Spring.Settings PositionSpring = Spring.Settings.Default;
        public Spring.Settings RotationSpring = Spring.Settings.Default;

        [Space]

        public CameraBob Headbob;
        public NoiseMotionModule Noise;

        [Space]

        public SpringForce EnterForce;
        public SpringForce ExitForce;
    }
}
