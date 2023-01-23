using System;
using UnityEngine;

namespace SurvivalTemplatePro
{
    public class Spring
    {
		#region Internal
		[Serializable]
		public struct Settings
		{
			public static Settings Default { get { return new Settings() { Stiffness = Vector3.one * 90f, Damping = Vector3.one * 10f }; } }

			public Vector3 Stiffness;
			public Vector3 Damping;
		}
        #endregion

        public Vector3 Position => m_Position;
        public Quaternion Rotation => Quaternion.Euler(m_Position);

        private Vector3 m_Stiffness;
		private Vector3 m_Damping;

		private Vector3 m_TargetPosition;
		private Vector3 m_Position;
		private Vector3 m_Velocity;

		private readonly float m_LerpSpeed = 10f;
        private readonly Vector3[] m_DistributedForces;


        public Spring(Settings data = default, float lerpSpeed = 25f, int maxDistributedFrames = 30)
        {
            this.m_Stiffness = data.Stiffness;
            this.m_Damping = data.Damping;
            this.m_LerpSpeed = lerpSpeed;

            this.m_DistributedForces = new Vector3[Mathf.Clamp(maxDistributedFrames, 1, 100)];
        }

        public void Reset()
		{
			m_TargetPosition = Vector3.zero;
			m_Velocity = Vector3.zero;

			UpdateSpring(Time.fixedDeltaTime);

            for (int i = 0; i < m_DistributedForces.Length; i++)
                m_DistributedForces[i] = Vector3.zero;
        }

		public void Adjust(Vector3 stiffness, Vector3 damping)
		{
			m_Stiffness = stiffness;
			m_Damping = damping;
		}

		public void Adjust(Settings data)
		{
			m_Stiffness = data.Stiffness;
			m_Damping = data.Damping;
		}

		public void FixedUpdate(float deltaTime)
		{
            //	// Handle distributed forces.
            if (m_DistributedForces[0] != Vector3.zero)
            {
                AddForce(m_DistributedForces[0]);

                for (int i = 0; i < m_DistributedForces.Length; i++)
                {
                    m_DistributedForces[i] = i < m_DistributedForces.Length - 1 ? m_DistributedForces[i + 1] : Vector3.zero;
                    if (m_DistributedForces[i] == Vector3.zero)
                        break;
                }
            }

            UpdateSpring(deltaTime);
			UpdatePosition(deltaTime);
		}

		public void Update(float deltaTime)
		{
			if (m_LerpSpeed > 0f)
				m_Position = Vector3.Lerp(m_Position, m_TargetPosition, deltaTime * m_LerpSpeed);
			else
				m_Position = m_TargetPosition;
		}

		public void AddForce(SpringForce force)
		{
			if (force.Distribution > 1)
				AddDistributedForce(force.Force, force.Distribution);
			else
				AddForce(force.Force);
		}

		public void AddForce(Vector3 forceVector)
		{
			m_Velocity += forceVector;

			UpdatePosition(Time.fixedDeltaTime);
		}

		public void AddForce(Vector3 forceVector, int distribution)
		{
			if (distribution > 1)
				AddDistributedForce(forceVector, distribution);
			else
				AddForce(forceVector);
		}

		public void AddDistributedForce(Vector3 force, int distribution)
		{
			distribution = Mathf.Clamp(distribution, 1, 20);

			AddForce(force / distribution);

			for (int i = 0; i < Mathf.RoundToInt(distribution) - 1; i++)
				m_DistributedForces[i] += force / distribution;
		}

		private void UpdateSpring(float deltaTime)
		{
			m_Velocity += Vector3.Scale((Vector3.zero - m_TargetPosition), m_Stiffness * deltaTime);
			m_Velocity = Vector3.Scale(m_Velocity, Vector3.one - m_Damping * deltaTime);
		}

		private void UpdatePosition(float deltaTime)
		{
			m_TargetPosition += m_Velocity * deltaTime;
			m_TargetPosition = m_TargetPosition.GetNaNSafeVector();
		}		
    }
}