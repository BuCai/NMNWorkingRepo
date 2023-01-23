using System;
using UnityEngine;

namespace SurvivalTemplatePro.CameraSystem
{
    [Serializable]
	public class CameraBob
	{
		public float BobSpeed => m_BobSpeed;
		public Vector3 PositionAmplitude => m_PositionAmplitude;
		public Vector3 RotationAmplitude => m_RotationAmplitude;

		[SerializeField, Range(0.1f, 20f)]
		[Tooltip("How fast should the camera bob be.")]
		private float m_BobSpeed = 2f;

		[SerializeField]
		private Vector3 m_PositionAmplitude;

		[SerializeField]
		private Vector3 m_RotationAmplitude;
	}
}