using UnityEngine;
using UnityEngine.EventSystems;

namespace SurvivalTemplatePro.UISystem
{
    public class CharacterPreviewRotationHandlerUI : PlayerUIBehaviour
    {
        [SerializeField]
        private PointeEventsReceiverUI m_PointerEventsReceiver;

        [Space]

        [SerializeField]
        private Camera m_Camera;

        [SerializeField]
        private Transform m_Root;

        [Space]

        [SerializeField, Range(0.01f, 10f)]
        private float m_YRotationSpeed = 0.3f;

        [SerializeField]
        private bool m_InvertYDirection = true;

        [Space]

        [SerializeField, Range(0.01f, 10f)]
        private float m_XRotationSpeed = 0.3f;

        [SerializeField]
        private bool m_InvertXDirection = true;

        [SerializeField, Range(0f, 180f)]
        private float m_MaxXRotation = 15f;

        [Space]

        [SerializeField, Range(0f, 3f)]
        private float m_CameraMoveSpeed = 0.01f;

        [SerializeField, Range(0f, 3f)]
        private float m_MaxCameraDistance;

        [SerializeField, Range(0f, 3f)]
        private float m_MinCameraDistance;

        private Vector3 m_RootEulerAngles;
        private float m_OriginalCameraOffset;
        private float m_CameraOffset;


        private void Start()
        {
            if (m_PointerEventsReceiver != null)
            {
                m_PointerEventsReceiver.onDrag += OnDrag;
                m_PointerEventsReceiver.onScroll += OnScroll;
            }

            m_OriginalCameraOffset = m_Camera.orthographicSize;
        }

        private void OnDestroy()
        {
            if (m_PointerEventsReceiver != null)
            {
                m_PointerEventsReceiver.onDrag -= OnDrag;
                m_PointerEventsReceiver.onScroll -= OnScroll;
            }
        }

        private void OnDrag(PointerEventData data)
        {
            m_RootEulerAngles.y += (data.delta.x * m_YRotationSpeed * (m_InvertYDirection ? -1f : 1f));
            m_RootEulerAngles.x += (data.delta.y * m_XRotationSpeed * (m_InvertXDirection ? -1f : 1f));
            m_RootEulerAngles.x = Mathf.Clamp(m_RootEulerAngles.x, -m_MaxXRotation, m_MaxXRotation);

            m_Root.localRotation = Quaternion.Euler(m_RootEulerAngles);
        }

        private void OnScroll(PointerEventData eventData)
        {
            m_CameraOffset += eventData.scrollDelta.y * m_CameraMoveSpeed;
            m_CameraOffset = Mathf.Clamp(m_CameraOffset, -m_MinCameraDistance, m_MaxCameraDistance);
            m_Camera.orthographicSize = m_CameraOffset + m_OriginalCameraOffset;
        }
    }
}