using System.Collections;
using UnityEngine;

namespace SurvivalTemplatePro
{
    public class AnimatedObjectCover : MonoBehaviour
    {
        [SerializeField]
        [Tooltip("Crate cover transform (used for the open/close animation")]
        private Transform m_Cover;

        [Title("Animation")]

        [SerializeField]
        [Tooltip("How long should the open/close animations last.")]
        private float m_AnimationDuration = 1f;

        [SerializeField]
        [Tooltip("Animation easing type.")]
        private Easings.Function m_AnimationStyle = Easings.Function.QuadraticEaseInOut;

        [SerializeField]
        [Tooltip("The crate cover open local rotation.")]
        private Vector3 m_OpenRotationOffset;

        [SerializeField]
        [Tooltip("The crate cover open local position.")]
        private Vector3 m_OpenPositionOffset;

        private Easer m_CoverEaser;
        private Vector3 m_ClosedPosition;
        private Vector3 m_ClosedRotation;


        public virtual void DoOpenAnimation()
        {
            StopAllCoroutines();
            StartCoroutine(C_OpenCrate(true));
        }

        public virtual void DoCloseAnimation()
        {
            StopAllCoroutines();
            StartCoroutine(C_OpenCrate(false));
        }

        protected virtual void Awake()
        {
            // Initialize Crate Cover
            m_CoverEaser = new Easer(Easings.Function.QuadraticEaseInOut, m_AnimationDuration);

            m_ClosedPosition = m_Cover.localPosition;
            m_ClosedRotation = m_Cover.localEulerAngles;
        }

        private IEnumerator C_OpenCrate(bool open)
        {
            m_CoverEaser.Reset();
            m_CoverEaser.Duration = m_AnimationDuration;
            m_CoverEaser.Function = m_AnimationStyle;

            Quaternion startRotation = m_Cover.localRotation;
            Quaternion targetRotation = Quaternion.Euler(open ? m_OpenRotationOffset + m_ClosedRotation : m_ClosedRotation);

            Vector3 startPosition = m_Cover.localPosition;
            Vector3 targetPosition = open ? m_OpenPositionOffset + m_ClosedPosition : m_ClosedPosition;

            while (m_CoverEaser.InterpolatedValue < 1f)
            {
                m_CoverEaser.Update(Time.deltaTime);
                m_Cover.localRotation = Quaternion.Lerp(startRotation, targetRotation, m_CoverEaser.InterpolatedValue);
                m_Cover.localPosition = Vector3.Lerp(startPosition, targetPosition, m_CoverEaser.InterpolatedValue);

                yield return null;
            }
        }

#if UNITY_EDITOR
        protected virtual void OnValidate()
        {
            if (m_CoverEaser != null)
            {
                m_CoverEaser.Function = m_AnimationStyle;
                m_CoverEaser.Duration = m_AnimationDuration;
            }
        }
#endif
    }
}