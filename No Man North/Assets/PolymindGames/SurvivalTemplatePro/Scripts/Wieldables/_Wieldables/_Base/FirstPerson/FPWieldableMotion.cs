using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Event Listeners/FP Motion")]
	[RequireComponent(typeof(MotionMixer))]
	public class FPWieldableMotion : STPWieldableEventsListener<FPWieldableMotion>, IMixedMotion
	{
		#region Internal
		[System.Serializable]
		protected class MotionStateEventSettings : STPEventListenerBehaviour
		{
			public FPWieldableMotionState State;


			protected override void OnActionTriggered(float value) => Instance.SetCustomState(State);
		}
		#endregion

		public Vector3 Position { get; private set; } = Vector3.zero;
		public Quaternion Rotation { get; private set; } = Quaternion.identity;

		[Title("Spring Settings")]

		[SerializeField, Range(0f, 100f)]
		private float m_SpringLerpSpeed = 40f;

		[SerializeField, Range(0f, 3.14f)]
		private float m_PositionBobOffset;

		[SerializeField, Range(0f, 3.14f)]
		private float m_RotationBobOffset = 0.5f;

		[Title("Motion Settings")]

		[SerializeField]
		private SwayMotionModule m_Sway;

		[SerializeField]
		private ForceMotionModule m_ViewOffset;

		[SerializeField]
		private RetractionMotionModule m_RetractionOffset;

		[SerializeField]
		private ForceMotionModule m_FallImpactForce;

		[SpaceArea(10f)]

		[SerializeField, LabelByChild("StateType"), ReorderableList]
		private StepMotionModule[] m_Steps;

		[SerializeField, LabelByChild("StateType"), ReorderableList]
		private FPWieldableMotionState[] m_States;

		[SerializeField, ReorderableList(elementLabel: "Motion State")]
		private MotionStateEventSettings[] m_MotionStateSettings;

		[SerializeField, Tooltip("Events that will reset this behavior.")]
		private STPActionEventsListener m_MotionStateResetSettings;

		private Spring m_PositionSpring;
		private Spring m_RotationSpring;

		private FPWieldableMotionState m_CurrentState;
		private FPWieldableMotionState m_CustomState;

		private Vector3 m_PositionDelta;
		private Vector3 m_RotationDelta;
		private Vector3 m_ViewPosOffset;
		private Vector3 m_ViewRotOffset;
		private Vector2 m_LookSwayInput;
		private Vector3 m_StrafeSwayInput;
		private float m_CurrentBobParam;
		private int m_LastFootDown;

		private IMotionMixer m_TransformMixHandler;
		private ILookHandler m_LookHandler;
		private IMotionController m_Motion;
		private ICharacterMotor m_Motor;
		private IInteractionHandler m_Interaction;

		private const float k_RotStrength = 0.2f;
		private const float k_PosStrength = 0.01f;
		private const float k_EnterForceOffsetThreshold = 5f;


		#region Public Methods
		public void SetCustomState(FPWieldableMotionState state) => m_CustomState = state;
		public void ClearCustomState() => m_CustomState = null;

		public void ResetPhysics() 
		{
			m_PositionSpring.Reset();
			m_RotationSpring.Reset();

			m_CurrentBobParam = 0f;

			m_CurrentState = null;
			m_CustomState = null;
		}
        #endregion

        #region Initialization
        protected override void Awake()
        {
			base.Awake();

			m_PositionSpring = new Spring(default, m_SpringLerpSpeed, 20);
			m_RotationSpring = new Spring(default, m_SpringLerpSpeed, 20);

            m_MotionStateResetSettings.onActionTriggered += ClearCustomState;

			m_TransformMixHandler = GetComponent<IMotionMixer>();
			m_TransformMixHandler.AddMixedMotion(this);
		}

        protected override void OnInitialized(ICharacter character)
        {
			character.GetModule(out m_Motion);
			character.GetModule(out m_Motor);
			character.GetModule(out m_LookHandler);
			character.GetModule(out m_Interaction);
			character.GetModule(out m_LookHandler);
		}

        protected override void OnWieldableEquipped()
        {
			base.OnWieldableEquipped();

			ResetPhysics();

			m_Motion.onStepCycleEnded += OnStepCycleEnded;
			m_Motor.onFallImpact += OnFallImpact;
		}

        protected override void OnWieldableHolstered(float holsterSpeed)
        {
			m_Motion.onStepCycleEnded -= OnStepCycleEnded;
			m_Motor.onFallImpact -= OnFallImpact;
		}

        protected override IEnumerable<STPEventListenerBehaviour> GetEvents()
		{
			var list = new List<STPEventListenerBehaviour>();
			list.AddRange(m_MotionStateSettings);
			list.Add(m_MotionStateResetSettings);
			return list;
		}
        #endregion

        #region Spring Update
		public void FixedUpdateTransform(float deltaTime)
		{
			if (Character == null)
				return;

			UpdateCurrentState();

			m_PositionDelta = Vector3.zero;
			m_RotationDelta = Vector3.zero;

			UpdateOffset(ref m_PositionDelta, ref m_RotationDelta);
			UpdateBob(deltaTime, ref m_PositionDelta, ref m_RotationDelta);
			UpdateNoise(ref m_PositionDelta, ref m_RotationDelta);

			UpdateSway(ref m_PositionDelta, ref m_RotationDelta);
			UpdateViewOffset(ref m_PositionDelta, ref m_RotationDelta);
			UpdateRetractionOffset(ref m_PositionDelta, ref m_RotationDelta);

			m_PositionSpring.AddForce(m_PositionDelta);
			m_RotationSpring.AddForce(m_RotationDelta);

			m_PositionSpring.FixedUpdate(deltaTime);
			m_RotationSpring.FixedUpdate(deltaTime);
		}

        public void UpdateTransform(float deltaTime)
		{
			m_PositionSpring.Update(deltaTime);
			m_RotationSpring.Update(deltaTime);

			Position = m_PositionSpring.Position;
			Rotation = m_RotationSpring.Rotation;
		}

		private void UpdateCurrentState()
		{
#if UNITY_EDITOR
			if (m_StateToVisualize != null)
			{
				SetState(m_StateToVisualize);
				return;
			}
#endif

			if (m_CustomState != null)
			{
				SetState(m_CustomState);
				return;
			}

			var state = GetStateOfType(m_Motion.ActiveStateType);
			SetState(state);
		}

		private FPWieldableMotionState GetStateOfType(MotionStateType stateType)
		{
			for (int i = 0; i < m_States.Length; i++)
			{
				if (m_States[i].StateType == stateType)
					return m_States[i];
			}

			return m_States[0];
		}

        private void SetState(FPWieldableMotionState state)
		{
			if (m_CurrentState != state)
			{
				Vector3 lastOffset = Vector3.zero;
				Vector3 currentOffset = Vector3.zero;

				// Apply exit force.
				if (m_CurrentState != null)
				{
					m_RotationSpring.AddForce(m_CurrentState.ExitForce * 10f);
					lastOffset = (m_CurrentState.Offset.PositionOffset + m_CurrentState.Offset.RotationOffset);
				}

				m_CurrentState = state;

				m_PositionSpring.Adjust(state.PositionSpring);
				m_RotationSpring.Adjust(state.RotationSpring);

				// Apply enter force.
				if (m_CurrentState != null)
				{
					currentOffset = (m_CurrentState.Offset.PositionOffset + m_CurrentState.Offset.RotationOffset);

					if (Vector3.Distance(lastOffset, currentOffset) > k_EnterForceOffsetThreshold)
						m_RotationSpring.AddForce(m_CurrentState.EnterForce * 10f);
				}
			}
		}

		private void UpdateBob(float deltaTime, ref Vector3 position, ref Vector3 rotation)
		{
			if (m_Motor.Velocity.sqrMagnitude < 0.1f)
				return;

			UpdateBobParam(deltaTime);

			Vector3 posBobAmplitude = Vector3.zero;
			Vector3 rotBobAmplitude = Vector3.zero;

			// Update position bob
			posBobAmplitude.x = m_CurrentState.Bob.PositionAmplitude.x * -0.01f;
			position.x += Mathf.Cos(m_CurrentBobParam + m_PositionBobOffset) * posBobAmplitude.x;

			posBobAmplitude.y = m_CurrentState.Bob.PositionAmplitude.y * 0.01f;
			position.y += Mathf.Cos(m_CurrentBobParam * 2 + m_PositionBobOffset) * posBobAmplitude.y;

			posBobAmplitude.z = m_CurrentState.Bob.PositionAmplitude.z * 0.01f;
			position.z += Mathf.Cos(m_CurrentBobParam + m_PositionBobOffset) * posBobAmplitude.z;

			// Update rotation bob
			rotBobAmplitude.x = m_CurrentState.Bob.RotationAmplitude.x * k_RotStrength;
			rotation.x += Mathf.Cos(m_CurrentBobParam * 2 + m_RotationBobOffset) * rotBobAmplitude.x;

			rotBobAmplitude.y = m_CurrentState.Bob.RotationAmplitude.y * k_RotStrength;
			rotation.y += Mathf.Cos(m_CurrentBobParam + m_RotationBobOffset) * rotBobAmplitude.y;

			rotBobAmplitude.z = m_CurrentState.Bob.RotationAmplitude.z * k_RotStrength;
			rotation.z += Mathf.Cos(m_CurrentBobParam + m_RotationBobOffset) * rotBobAmplitude.z;
		}

		private void UpdateBobParam(float deltaTime) 
		{
#if UNITY_EDITOR
			if (m_StateToVisualize != null)
			{
				m_CurrentBobParam += deltaTime * m_VisualizationSpeed * 2;

				if (!m_FirstStepTriggered && m_CurrentBobParam >= Mathf.PI)
				{
					m_FirstStepTriggered = true;
					ApplyStepForce();
				}

				if (m_CurrentBobParam >= Mathf.PI * 2)
				{
					m_CurrentBobParam -= Mathf.PI * 2;
					m_FirstStepTriggered = false;
					ApplyStepForce();
				}
			}
			else
			{
				m_CurrentBobParam = m_Motion.StepCycle * Mathf.PI;

				if (m_LastFootDown != 0)
					m_CurrentBobParam += Mathf.PI;
			}
#else
			m_CurrentBobParam = m_Motion.StepCycle * Mathf.PI;

			if (m_LastFootDown != 0)
				m_CurrentBobParam += Mathf.PI;
#endif
		}

		private void UpdateOffset(ref Vector3 position, ref Vector3 rotation)
		{
			position += m_CurrentState.Offset.PositionOffset * k_PosStrength;
			rotation += m_CurrentState.Offset.RotationOffset * (k_RotStrength * 10f);
		}

		private void UpdateViewOffset(ref Vector3 position, ref Vector3 rotation)
		{
			if (!m_Motor.IsGrounded || m_CustomState != null)
				return;

			float angle = m_LookHandler.LookAngle.x;

			Vector3 targetViewOffsetPos = Vector3.zero;
			Vector3 targetViewOffsetRot = Vector3.zero;

			if (Mathf.Abs(angle) > 30f)
			{
				float angleFactor = 1f - Mathf.Min((70f - Mathf.Abs(angle)), 70f) / 40f;
				targetViewOffsetPos = m_ViewOffset.PositionForce.Force * angleFactor / 100;
				targetViewOffsetRot = m_ViewOffset.RotationForce.Force * angleFactor;
			}

			m_ViewPosOffset = Vector3.Lerp(m_ViewPosOffset, targetViewOffsetPos * m_CurrentState.OutsideForcesStrength, 1f);
			m_ViewRotOffset = Vector3.Lerp(m_ViewRotOffset, targetViewOffsetRot * m_CurrentState.OutsideForcesStrength, 1f);

			position += m_ViewPosOffset;
			rotation += m_ViewRotOffset;
		}

		private void UpdateRetractionOffset(ref Vector3 position, ref Vector3 rotation)
		{
			if (m_Motor.IsGrounded && m_Interaction.HoverInfo != null && m_Interaction.HoveredObjectDistance < m_RetractionOffset.RetractionDistance)
            {
                position += m_RetractionOffset.PositionForce.Force * (k_PosStrength * m_CurrentState.OutsideForcesStrength);
                rotation += m_RetractionOffset.RotationForce.Force * m_CurrentState.OutsideForcesStrength;
            }
        }
			
		private void UpdateSway(ref Vector3 position, ref Vector3 rotation)
		{
			float forceMod = m_CurrentState.OutsideForcesStrength;

			// Calculate the look sway input.
			m_LookSwayInput = m_LookHandler.CurrentInput * 0.5f;
			m_LookSwayInput = new Vector2(-m_LookSwayInput.y, m_LookSwayInput.x);
			m_LookSwayInput = Vector2.ClampMagnitude(m_LookSwayInput, m_Sway.MaxLookSway);

			// Look position sway.
			position += new Vector3(
				m_LookSwayInput.x * m_Sway.LookPositionSway.x * k_PosStrength * forceMod,
				m_LookSwayInput.y * m_Sway.LookPositionSway.y * -k_PosStrength * forceMod,
				m_LookSwayInput.y * m_Sway.LookPositionSway.z * -k_PosStrength * forceMod);

			// Look rotation sway.
			rotation += new Vector3(
				m_LookSwayInput.y * m_Sway.LookRotationSway.x * forceMod,
				m_LookSwayInput.x * -m_Sway.LookRotationSway.y * forceMod,
				m_LookSwayInput.x * -m_Sway.LookRotationSway.z * forceMod);

			// Calculate the strafe sway input. 
			m_StrafeSwayInput = transform.InverseTransformVector(m_Motor.Velocity);

			if (Mathf.Abs(m_StrafeSwayInput.y) < 1.5f)
				m_StrafeSwayInput.y = 0f;

			m_StrafeSwayInput = Vector3.ClampMagnitude(m_StrafeSwayInput, m_Sway.MaxStrafeSway);

			// Strafe position sway.
			position += new Vector3(
				m_StrafeSwayInput.x * m_Sway.StrafePositionSway.x,
				-Mathf.Abs(m_StrafeSwayInput.x * m_Sway.StrafePositionSway.y),
				-m_StrafeSwayInput.z * m_Sway.StrafePositionSway.z) * (k_PosStrength * forceMod);

			// Strafe rotation sway.
			rotation += new Vector3(
				m_StrafeSwayInput.z * m_Sway.StrafeRotationSway.x,
				-m_StrafeSwayInput.x * m_Sway.StrafeRotationSway.y,
				m_StrafeSwayInput.x * m_Sway.StrafeRotationSway.z) * (k_RotStrength * forceMod);

			// Fall Sway.
			if (!m_Motor.IsGrounded)
			{
				Vector2 rotationFallSway = m_Sway.FallSway * m_Motor.Velocity.y;
				rotationFallSway = Vector2.ClampMagnitude(rotationFallSway, m_Sway.MaxFallSway);

				m_RotationSpring.AddForce(rotationFallSway * m_CurrentState.OutsideForcesStrength);
			}
		}

		private void UpdateNoise(ref Vector3 position, ref Vector3 rotation)
		{
			if (!m_CurrentState.Noise.Enabled)
				return;

			float jitter = Random.Range(0, m_CurrentState.Noise.MaxJitter);
			float speed = Time.time * m_CurrentState.Noise.NoiseSpeed;

			position.x += (Mathf.PerlinNoise(jitter, speed) - 0.5f) * m_CurrentState.Noise.PositionAmplitude.x * k_PosStrength;
			position.y += (Mathf.PerlinNoise(jitter + 1f, speed) - 0.5f) * m_CurrentState.Noise.PositionAmplitude.y * k_PosStrength;
			position.z += (Mathf.PerlinNoise(jitter + 2f, speed) - 0.5f) * m_CurrentState.Noise.PositionAmplitude.z * k_PosStrength;

			rotation.x += (Mathf.PerlinNoise(jitter, speed) - 0.5f) * m_CurrentState.Noise.RotationAmplitude.x * 3f;
			rotation.y += (Mathf.PerlinNoise(jitter + 1f, speed) - 0.5f) * m_CurrentState.Noise.RotationAmplitude.y * 3f;
			rotation.z += (Mathf.PerlinNoise(jitter + 2f, speed) - 0.5f) * m_CurrentState.Noise.RotationAmplitude.z * 3f;
		}

		private void OnFallImpact(float impactSpeed)
		{
			m_PositionSpring.AddDistributedForce(m_TransformMixHandler.TargetTransform.InverseTransformVector(m_FallImpactForce.PositionForce.Force) * (impactSpeed * k_PosStrength), m_FallImpactForce.PositionForce.Distribution);
			m_RotationSpring.AddDistributedForce(m_FallImpactForce.RotationForce.Force * impactSpeed, m_FallImpactForce.RotationForce.Distribution);
		}

		private void OnStepCycleEnded()
		{
			ApplyStepForce();
			m_LastFootDown = m_LastFootDown == 0 ? 1 : 0;
		}

		private void ApplyStepForce()
		{
			if (m_CurrentState == null || m_Motor.Velocity.sqrMagnitude < 0.5f || m_CustomState != null)
				return;

			StepMotionModule stepForce = null;

			stepForce = GetStepOfType(m_Motion.ActiveStateType);

#if UNITY_EDITOR
			if (m_StateToVisualize != null)
				stepForce = GetStepOfType(m_StateToVisualize.StateType);
#endif

			if (stepForce != null)
            {
				m_PositionSpring.AddForce(stepForce.PositionForce.Force * (0.2f * m_CurrentState.OutsideForcesStrength), stepForce.PositionForce.Distribution);
                m_RotationSpring.AddForce(stepForce.RotationForce.Force * m_CurrentState.OutsideForcesStrength, stepForce.RotationForce.Distribution);
            }
        }

		private StepMotionModule GetStepOfType(MotionStateType stateType)
		{
            for (int i = 0; i < m_Steps.Length; i++)
            {
				if (m_Steps[i].StateType == stateType)
					return m_Steps[i];
			}

			return null;
		}
		#endregion

		#region Editor
#if UNITY_EDITOR
		// State visualization
		private FPWieldableMotionState m_StateToVisualize;
		private float m_VisualizationSpeed;
		private bool m_FirstStepTriggered;


		public void VisualizeState(FPWieldableMotionState motionState, float speed = 3f)
		{
			m_StateToVisualize = motionState;

			m_VisualizationSpeed = speed;
			m_CurrentBobParam = 0f;
		}

		private void OnValidate()
		{
			if (Application.isPlaying)
			{
				if (m_CurrentState != null && Character != null)
				{
					m_PositionSpring.Adjust(m_CurrentState.PositionSpring);
					m_RotationSpring.Adjust(m_CurrentState.RotationSpring);
				}
			}

			if (m_States != null && m_States.Length == 0)
				m_States = new FPWieldableMotionState[] { new FPWieldableMotionState() };

			UnityEditor.EditorUtility.SetDirty(this);
		}
#endif
        #endregion
    }
}