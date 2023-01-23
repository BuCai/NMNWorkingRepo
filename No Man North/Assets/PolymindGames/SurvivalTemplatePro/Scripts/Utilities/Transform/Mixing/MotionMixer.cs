using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro
{
    public class MotionMixer : MonoBehaviour, IMotionMixer
    {
        #region Internal
        public enum UpdateType
        {
            UpdateAndFixedUpdate,
            LateUpdateAndFixedUpdate, 
            OnlyFixedUpdate
        }
        #endregion

        public Transform TargetTransform => m_TargetTransform;
        public Vector3 PivotPosition => m_TargetTransform.localPosition;
        public Quaternion PivotRotation => m_TargetTransform.localRotation;

        [SerializeField, InLineEditor]
        private Transform m_TargetTransform;

        [SerializeField]
        private UpdateType m_UpdateType = UpdateType.UpdateAndFixedUpdate;

        [Title("Pivot")]

        [SerializeField]
        private Vector3 m_PivotPosition;

#if UNITY_EDITOR
        [SerializeField]
        private Color m_PivotColor = new Color(0.1f, 1f, 0.1f, 0.5f);

        [SerializeField]
        private float m_PivotRadius = 0.08f;
#endif

        private readonly List<IMixedMotion> m_MixedMotions = new List<IMixedMotion>();


        public void AddMixedMotion(IMixedMotion mixedMotion)
        {
            if (mixedMotion != null && !m_MixedMotions.Contains(mixedMotion))
                m_MixedMotions.Add(mixedMotion);
        }

        public void RemoveMixedMotion(IMixedMotion mixedMotion)
        {
            if (mixedMotion != null)
                m_MixedMotions.Remove(mixedMotion);
        }

        private void FixedUpdate()
        {
            foreach (var mixedTransform in m_MixedMotions)
                mixedTransform.FixedUpdateTransform(Time.fixedDeltaTime);
        }

        private void Update()
        {
            if (m_UpdateType == UpdateType.UpdateAndFixedUpdate)
                UpdateTransform();
        }

        private void LateUpdate()
        {
            if (m_UpdateType == UpdateType.LateUpdateAndFixedUpdate)
                UpdateTransform();
        }

        private void UpdateTransform()
        {
            Vector3 position = m_PivotPosition;
            Quaternion rotation = Quaternion.identity;
            float deltaTime = Time.deltaTime;

            foreach (var mixedTransform in m_MixedMotions)
            {
                mixedTransform.UpdateTransform(deltaTime);
 
                position += rotation * mixedTransform.Position;
                rotation *= mixedTransform.Rotation;
            }

            position -= rotation * m_PivotPosition;

            m_TargetTransform.localPosition = position;
            m_TargetTransform.localRotation = rotation;
        }

#if UNITY_EDITOR
        private void Reset()
        {
            m_TargetTransform = transform;
        }

        private void OnDrawGizmos()
        {
            Color prevColor = UnityEditor.Handles.color;
            UnityEditor.Handles.color = m_PivotColor;
            UnityEditor.Handles.SphereHandleCap(0, transform.TransformPoint(m_PivotPosition), Quaternion.identity, m_PivotRadius, EventType.Repaint);
            UnityEditor.Handles.color = prevColor;
        }
#endif
    }
}