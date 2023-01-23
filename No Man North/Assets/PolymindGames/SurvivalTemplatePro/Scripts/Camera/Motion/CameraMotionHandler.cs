using SurvivalTemplatePro.BodySystem;
using UnityEngine;
using Random = UnityEngine.Random;

namespace SurvivalTemplatePro.CameraSystem
{
    /// <summary>
    /// Handles the additive motion of a camera.
    /// </summary>
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/camera#camera-motion-handler-module")]
    public class CameraMotionHandler : CharacterBehaviour, ICameraMotionHandler, IMixedMotion
    {
        public Vector3 Position { get; private set; } = Vector3.zero;
        public Quaternion Rotation { get; private set; } = Quaternion.identity;

        [SerializeField]
        [Tooltip("The transform that will be rotated using a spring.")]
        private MotionMixer m_MotionMixer;

        [SpaceArea]

        [SerializeField, Range(0f, 200f)]
        [Tooltip("How smooth should the motion spring movement be.")]
        private float m_SpringLerpSpeed;

        [SerializeField]
        [Tooltip("The default spring force settings (Stiffness and Damping), when external forces are being applied.")]
        private Spring.Settings m_ForceSpringSettings = Spring.Settings.Default;

        [SpaceArea]

        [SerializeField]
        [Tooltip("Sway forces (applied when moving the camera).")]
        private SwayMotionModule m_Sway;

        [SerializeField]
        [Tooltip("Fall impact forces.")]
        private FallImpactMotionModule m_FallImpact;

        [SpaceArea]

        [SerializeField, LabelByChild("StateType"), ReorderableList(ListStyle.Round)]
        private CameraMotionState[] m_States;

        // Springs
        private Spring m_PositionSpring;
        private Spring m_RotationSpring;
        private Spring m_CustomForceSpring;

        // States
        private CameraMotionState m_CurrentState;
        private CameraMotionState m_CustomState;
        private Vector3 m_PositionDelta;
        private Vector3 m_RotationDelta;
        private Vector3 m_PositionBobDelta;
        private Vector3 m_RotationBobDelta;

        private Vector2 m_LookSwayInput;
        private Vector3 m_StrafeSwayInput;

        // Headbob
        private HumanoidFoot m_LastFootDown;
        private Vector3 m_PositionBobAmplitude;
        private Vector3 m_RotationBobAmplitude;
        private Vector3 m_CustomPositionBobAmplitude;
        private Vector3 m_CustomRotationBobAmplitude;
        private float m_CustomHeadbobSpeed;
        private CameraBob m_CustomHeadbob;

        private ILookHandler m_LookHandler;
        private IMotionController m_Motion;
        private ICharacterMotor m_Motor;


        #region Public Methods
        public void AddRotationForce(SpringForce force) => m_CustomForceSpring.AddForce(force);
        public void AddRotationForce(Vector3 recoilForce, int distribution = 1) => m_CustomForceSpring.AddForce(recoilForce, distribution);

        public void SetCustomForceSpringSettings(Spring.Settings settings) => m_CustomForceSpring.Adjust(settings);
        public void ClearCustomForceSpringSettings() => m_CustomForceSpring.Adjust(m_ForceSpringSettings);

        public void SetCustomHeadbob(CameraBob headbob)
        {
            m_CustomHeadbob = headbob;

            if (headbob != null)
                m_CustomHeadbobSpeed = m_CustomHeadbob.BobSpeed;
        }

        public void SetCustomState(CameraMotionState state) => m_CustomState = state;
        public void ClearCustomState() => m_CustomState = null;
        #endregion

        #region Initialization
        public override void OnInitialized()
        {
            GetModule(out m_Motion);
            GetModule(out m_Motor);
            GetModule(out m_LookHandler);

            // Initalize the springs
            m_PositionSpring = new Spring(default, m_SpringLerpSpeed);
            m_RotationSpring = new Spring(default, m_SpringLerpSpeed);
            m_CustomForceSpring = new Spring(m_ForceSpringSettings, m_SpringLerpSpeed);

            m_Motion.onStepCycleEnded += OnStepCycleEnd;
            m_Motor.onFallImpact += DoFallImpact;
            m_Motor.onTeleport += ResetPosition;

            m_MotionMixer.AddMixedMotion(this);
        }
        #endregion

        #region Spring Update
        public void FixedUpdateTransform(float deltaTime)
        {
            if (!IsInitialized)
                return;

            UpdateCurrentState();

            m_PositionDelta = Vector3.zero;
            m_RotationDelta = Vector3.zero;

            if (m_CurrentState != null)
            {
                UpdateNoise(ref m_PositionDelta, ref m_RotationDelta);
                UpdateSway(ref m_PositionDelta, ref m_RotationDelta);

                m_PositionSpring.AddForce(m_PositionDelta);
                m_RotationSpring.AddForce(m_RotationDelta);
            }

            m_PositionSpring.FixedUpdate(deltaTime);
            m_RotationSpring.FixedUpdate(deltaTime);
            m_CustomForceSpring.FixedUpdate(deltaTime);
        }

        public void UpdateTransform(float deltaTime)
        {
            if (!IsInitialized)
                return;

            m_PositionBobDelta = Vector3.zero;
            m_RotationBobDelta = Vector3.zero;

            if (m_CurrentState != null)
            {
                UpdateHeadbobs(m_CurrentState.Headbob, deltaTime);
                UpdateCustomHeadbob(m_CustomHeadbob, deltaTime);
            }

            m_PositionSpring.Update(deltaTime);
            m_RotationSpring.Update(deltaTime);
            m_CustomForceSpring.Update(deltaTime);

            Position = m_PositionBobDelta + m_PositionSpring.Position;
            Rotation = Quaternion.Euler(m_RotationBobDelta) * m_RotationSpring.Rotation * m_CustomForceSpring.Rotation;
        }

        private void UpdateCurrentState()
        {
            if (m_CustomState != null)
            {
                SetState(m_CustomState);
                return;
            }

            var activeStateType = m_Motion.ActiveStateType;
            SetState(GetStateOfType(activeStateType));
        }

        private CameraMotionState GetStateOfType(MotionStateType stateType)
        {
            for (int i = 0; i < m_States.Length; i++)
            {
                if (m_States[i].StateType == stateType)
                    return m_States[i];
            }

            return m_States[0];
        }

        private void SetState(CameraMotionState state)
        {
            if (m_CurrentState == state)
                return;

            // Exit force
            if (m_CurrentState != null)
                m_RotationSpring.AddForce(m_CurrentState.ExitForce * 10f);

            m_CurrentState = state;

            if (m_CurrentState != null)
            {
                m_PositionSpring.Adjust(m_CurrentState.PositionSpring);
                m_RotationSpring.Adjust(m_CurrentState.RotationSpring);

                // Enter force
                m_RotationSpring.AddForce(m_CurrentState.EnterForce * 10f);
            }
        }

        private void UpdateHeadbobs(CameraBob cameraBob, float deltaTime)
        {
            float bobTime = m_Motion.StepCycle * Mathf.PI;

            if (m_LastFootDown == HumanoidFoot.Right)
                bobTime = Mathf.PI - bobTime;

            // Transition smoothly between different bob amplitudes.
            m_PositionBobAmplitude = Vector3.Lerp(m_PositionBobAmplitude, cameraBob == null ? Vector3.zero : cameraBob.PositionAmplitude, deltaTime * 2f);
            m_RotationBobAmplitude = Vector3.Lerp(m_RotationBobAmplitude, cameraBob == null ? Vector3.zero : cameraBob.RotationAmplitude, deltaTime * 2f);

            // Use the cosine function to smooth out the beginning and ending of the bob animation.
            var positionBob = new Vector3(Mathf.Cos(bobTime), Mathf.Cos(bobTime * 2), Mathf.Cos(bobTime));
            var rotationBob = new Vector3(Mathf.Cos(bobTime * 2), Mathf.Cos(bobTime), Mathf.Cos(bobTime));

            // Multiply the current amplitude and cosine values to get the final bob vectors.
            positionBob = Vector3.Scale(positionBob, m_PositionBobAmplitude);
            rotationBob = Vector3.Scale(rotationBob, m_RotationBobAmplitude);

            // Finally, move and rotate the camera using the bob values
            m_PositionBobDelta = positionBob;
            m_RotationBobDelta = rotationBob;
        }

        private void UpdateCustomHeadbob(CameraBob cameraBob, float deltaTime)
        {
            float bobTime = Time.time * m_CustomHeadbobSpeed;

            // Transition smoothly between different bob amplitudes
            m_CustomPositionBobAmplitude = Vector3.Lerp(m_CustomPositionBobAmplitude, cameraBob == null ? Vector3.zero : cameraBob.PositionAmplitude, deltaTime * 2f);
            m_CustomRotationBobAmplitude = Vector3.Lerp(m_CustomRotationBobAmplitude, cameraBob == null ? Vector3.zero : cameraBob.RotationAmplitude, deltaTime * 2f);

            // Use the cosine function to smooth out the beginning and ending of the bob animation
            var positionBob = new Vector3(Mathf.Cos(bobTime), Mathf.Cos(bobTime * 2), Mathf.Cos(bobTime));
            var rotationBob = new Vector3(Mathf.Cos(bobTime * 2), Mathf.Cos(bobTime), Mathf.Cos(bobTime));

            // Multiply the current amplitude and cosine values to get the final bob vectors
            positionBob = Vector3.Scale(positionBob, m_CustomPositionBobAmplitude);
            rotationBob = Vector3.Scale(rotationBob, m_CustomRotationBobAmplitude);

            // Finally, move and rotate the camera using the bob values
            m_PositionBobDelta += positionBob;
            m_RotationBobDelta += rotationBob;
        }

        private void UpdateSway(ref Vector3 position, ref Vector3 rotation)
        {
            // Looking Sway
            m_LookSwayInput = m_LookHandler.CurrentInput;
            m_LookSwayInput = Vector2.ClampMagnitude(m_LookSwayInput, m_Sway.MaxLookSway);

            position += new Vector3(
                m_LookSwayInput.x * m_Sway.LookPositionSway.x * 0.125f,
                m_LookSwayInput.y * m_Sway.LookPositionSway.z * -0.125f);

            rotation += new Vector3(
                m_LookSwayInput.x * m_Sway.LookRotationSway.x,
                m_LookSwayInput.y * -m_Sway.LookRotationSway.y,
                m_LookSwayInput.y * -m_Sway.LookRotationSway.z);

            // Strafing Sway
            m_StrafeSwayInput = transform.InverseTransformVector(m_Motor.SimulatedVelocity);

            if (Mathf.Abs(m_StrafeSwayInput.y) < 1.5f)
                m_StrafeSwayInput.y = 0f;

            position += new Vector3(
                m_StrafeSwayInput.x * m_Sway.StrafePositionSway.x,
                -Mathf.Abs(m_StrafeSwayInput.x * m_Sway.StrafePositionSway.y),
                -m_StrafeSwayInput.z * m_Sway.StrafePositionSway.z) * 0.125f;

            rotation += new Vector3(
                m_StrafeSwayInput.z * m_Sway.StrafeRotationSway.x,
                -m_StrafeSwayInput.x * m_Sway.StrafeRotationSway.y,
                m_StrafeSwayInput.x * m_Sway.StrafeRotationSway.z);

            // Falling Sway
            if (!m_Motor.IsGrounded)
            {
                Vector2 rotationFallSway = m_Sway.FallSway * m_StrafeSwayInput.y;
                m_RotationSpring.AddForce(rotationFallSway);
            }
        }

        private void UpdateNoise(ref Vector3 position, ref Vector3 rotation)
        {
            if (!m_CurrentState.Noise.Enabled)
                return;

            float jitter = Random.Range(0, m_CurrentState.Noise.MaxJitter);
            float speed = Time.time * m_CurrentState.Noise.NoiseSpeed;

            position.x += (Mathf.PerlinNoise(jitter, speed) - 0.5f) * m_CurrentState.Noise.PositionAmplitude.x;
            position.y += (Mathf.PerlinNoise(jitter + 1f, speed) - 0.5f) * m_CurrentState.Noise.PositionAmplitude.y;
            position.z += (Mathf.PerlinNoise(jitter + 2f, speed) - 0.5f) * m_CurrentState.Noise.PositionAmplitude.z;

            rotation.x += (Mathf.PerlinNoise(jitter, speed) - 0.5f) * m_CurrentState.Noise.RotationAmplitude.x * 3f;
            rotation.y += (Mathf.PerlinNoise(jitter + 1f, speed) - 0.5f) * m_CurrentState.Noise.RotationAmplitude.y * 3f;
            rotation.z += (Mathf.PerlinNoise(jitter + 2f, speed) - 0.5f) * m_CurrentState.Noise.RotationAmplitude.z * 3f;
        }

        private void DoFallImpact(float impactVelocity)
        {
            float impactVelocityAbs = Mathf.Abs(impactVelocity);

            if (impactVelocityAbs > m_FallImpact.FallImpactRange.x)
            {
                float multiplier = Mathf.Clamp01(impactVelocityAbs / m_FallImpact.FallImpactRange.y);

                m_PositionSpring.AddForce(m_FallImpact.PositionForce * multiplier);
                m_RotationSpring.AddForce(m_FallImpact.RotationForce * multiplier);
            }
        }

        private void OnStepCycleEnd() => m_LastFootDown = (m_LastFootDown == HumanoidFoot.Left ? HumanoidFoot.Right : HumanoidFoot.Left);

        private void ResetPosition()
        {
            m_PositionSpring.Reset();
            m_RotationSpring.Reset();
        }
        #endregion

        #region Editor
#if UNITY_EDITOR
        private void OnValidate()
        {
            if (Application.isPlaying && m_PositionSpring != null)
            {
                m_PositionSpring.Adjust(m_CurrentState.PositionSpring);
                m_RotationSpring.Adjust(m_CurrentState.RotationSpring);
                m_CustomForceSpring.Adjust(m_ForceSpringSettings);
            }

            if (m_States == null || m_States.Length == 0)
                m_States = new CameraMotionState[] { new CameraMotionState() };
        }
#endif
        #endregion
    }
}