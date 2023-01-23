using System.Collections;
using UnityEngine;

namespace SurvivalTemplatePro.CameraSystem
{
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/camera#camera-height-controller-behaviour")]
	public class CameraHeightController : CharacterBehaviour, ISaveableComponent
	{
		#region Internal
		[System.Serializable]
		public struct EasingOptions
		{
			public Easings.Function Function;

			public float Duration;
		}
		#endregion

		[SerializeField, Range(0.001f, 20f)]
		[Tooltip("How fast should the camera adjust to the current Y position. (up - down)")]
		private float m_YLerpSpeed = 7f;

		[SerializeField]
		[Tooltip("Crouch/Slide camera movement easing type.")]
		private EasingOptions m_HeightEasing;

		private float m_CurrentOffsetOnY;
		private float m_LastWorldSpaceYPos;
		private Vector3 m_InitialPosition;

		private Easer m_HeightEaser;
		private Coroutine m_HeightCoroutine;
		private ICharacterMotor m_Motor;
		private ILookHandler m_LookHandler;
		private bool m_IsChangingHeight;


        public override void OnInitialized()
        {
			m_InitialPosition = transform.localPosition;
			m_HeightEaser = new Easer(m_HeightEasing.Function, m_HeightEasing.Duration);
			m_LastWorldSpaceYPos = transform.position.y;

			GetModule(out m_Motor);
			m_Motor.onHeightChanged += OnHeightChanged;

			if (TryGetModule(out m_LookHandler))
				m_LookHandler.onPostViewUpdate += UpdatePosition;
		}

        private void OnHeightChanged(float height)
        {
			if (m_HeightCoroutine != null)
				StopCoroutine(m_HeightCoroutine);

			m_HeightCoroutine = StartCoroutine(C_SetHeight(height - m_Motor.DefaultHeight));
		}

		private void UpdatePosition()
		{
			if (!IsInitialized || !Character.HealthManager.IsAlive || m_IsChangingHeight)
				return;

			m_LastWorldSpaceYPos = Mathf.Lerp(m_LastWorldSpaceYPos, (Character.transform.position.y + m_InitialPosition.y + m_CurrentOffsetOnY), Time.deltaTime * (m_Motor.IsGrounded ? m_YLerpSpeed : 30f));
			transform.position = new Vector3(transform.position.x, m_LastWorldSpaceYPos, transform.position.z);
		}

		private IEnumerator C_SetHeight(float offset)
		{
			m_IsChangingHeight = true;

			var startOffset = m_CurrentOffsetOnY;
			m_HeightEaser.Reset();

			while (m_HeightEaser.InterpolatedValue < 1f && m_IsChangingHeight)
			{
				m_HeightEaser.Update(Time.deltaTime);
				m_CurrentOffsetOnY = Mathf.Lerp(startOffset, offset, m_HeightEaser.InterpolatedValue);

				transform.localPosition = m_InitialPosition + Vector3.up * m_CurrentOffsetOnY;

				yield return null;
			}

			m_LastWorldSpaceYPos = Character.transform.position.y + m_InitialPosition.y + m_CurrentOffsetOnY;
			m_IsChangingHeight = false;
		}

        #region Save & Load
        public void LoadMembers(object[] members)
        {
			m_CurrentOffsetOnY = (float)members[0];

			if (m_HeightCoroutine != null)
				StopCoroutine(m_HeightCoroutine);
			m_IsChangingHeight = false;
		}

        public object[] SaveMembers()
        {
			return new object[] { m_CurrentOffsetOnY };
		}
        #endregion
    }
}