using SurvivalTemplatePro.MovementSystem;
using System;
using UnityEngine;

namespace SurvivalTemplatePro
{
	[Serializable]
	public class SwayMotionModule
	{
		[Range(0f, 100f)]
		public float MaxLookSway = 4f;

		public Vector3 LookPositionSway;
		public Vector3 LookRotationSway;

		[Space]

		[Range(0f, 100f)]
		public float MaxStrafeSway = 5f;

		public Vector3 StrafePositionSway;
		public Vector3 StrafeRotationSway;

		[Space]

		[Range(0f, 100f)]
		public float MaxFallSway = 8f;

		public Vector2 FallSway;
	}

	[Serializable]
	public class FallImpactMotionModule
	{
		public Vector2 FallImpactRange;
		public SpringForce PositionForce;
		public SpringForce RotationForce;
	}

	[Serializable]
	public class ForceMotionModule
	{
		public SpringForce PositionForce;
		public SpringForce RotationForce;

		public StepMotionModule GetClone(MotionStateType type)
		{
			var clone = MemberwiseClone() as ForceMotionModule;
			var newClone = new StepMotionModule() { StateType = type, PositionForce = clone.PositionForce, RotationForce = clone.RotationForce };
			
			return newClone;
		}
	}

	[Serializable]
	public class StepMotionModule
	{
		public MotionStateType StateType;
		public SpringForce PositionForce;
		public SpringForce RotationForce;
	}

	[Serializable]
	public class RetractionMotionModule
	{
		public SpringForce PositionForce;
		public SpringForce RotationForce;

		[Space(3f)]

		[Range(0.1f, 5f)]
		public float RetractionDistance = 0.55f;
	}

	[Serializable]
	public class NoiseMotionModule
	{
		public bool Enabled;

		[Space(3f)]

		[Range(0f, 1f)]
		public float MaxJitter = 0f;

		[Range(0f, 5f)]
		public float NoiseSpeed = 1f;

		public Vector3 PositionAmplitude;
		public Vector3 RotationAmplitude;
	}
}
