using SurvivalTemplatePro.MovementSystem;
using System;
using UnityEngine;

namespace SurvivalTemplatePro.CameraSystem
{
    /// <summary>
    /// Handles the World & Overlay FOV of a camera.
    /// </summary>
    [HelpURL("")]
    public class CameraFOVHandler : CharacterBehaviour, ICameraFOVHandler
    {
        #region Internal
        [Serializable]
        protected class CameraFOVState
        {
            public MotionStateType StateType = MotionStateType.Idle;

            [Space]

            [Range(0.1f, 5f)]
            public float FOVMultiplier = 1f;

            [Range(0f, 30f)]
            public float FOVSetSpeed = 30f;


            public CameraFOVState(float fovMultiplier, float fovSetSpeed, MotionStateType stateType = MotionStateType.Idle)
            {
                this.FOVMultiplier = fovMultiplier;
                this.FOVSetSpeed = fovSetSpeed;
                this.StateType = stateType;
            }
        }
        #endregion

        public Camera UnityWorldCamera => m_WorldCamera;
        public Camera UnityOverlayCamera => m_OverlayCamera;
        public float BaseWorldFOV => m_BaseWorldFOV;
        public float BaseOverlayFOV => m_BaseOverlayFOV;

        [Title("World")]

        [SerializeField]
        private Camera m_WorldCamera;

        [SerializeField, Range(30f, 120f)]
        private float m_BaseWorldFOV = 90f;

        [SpaceArea]

        [SerializeField, LabelByChild("StateType"), ReorderableList(ListStyle.Round, "State")]
        private CameraFOVState[] m_WorldFOVStates;

        [Title("Overlay")]

        [SerializeField]
        private Camera m_OverlayCamera;

        [SerializeField, Range(30f, 120f)]
        private float m_BaseOverlayFOV = 50f;

        [SerializeField]
        private CameraFOVState m_IdleOverlayState;

        private CameraFOVState m_CurrentWorldState;
        private CameraFOVState m_CustomWorldState;
        private CameraFOVState m_CustomOverlayState;

        private IMotionController m_Motion;


        public override void OnInitialized()
        {
            GetModule(out m_Motion);

            m_WorldCamera.fieldOfView = m_BaseWorldFOV * 0.95f;
            m_OverlayCamera.fieldOfView = m_BaseOverlayFOV * 0.95f;

            m_CurrentWorldState = m_WorldFOVStates[0];
            m_CustomWorldState = null;
        }

        public void SetCustomWorldFOV(float fovMultiplier, float setSpeed = 10f)
        {
            m_CustomWorldState = new CameraFOVState(fovMultiplier, setSpeed);

            if (setSpeed == 0f)
                m_WorldCamera.fieldOfView = m_BaseWorldFOV * m_CustomWorldState.FOVMultiplier;
        }

        public void ClearCustomWorldFOV(bool instantly)
        {
            m_CustomWorldState = null;

            if (instantly)
                m_WorldCamera.fieldOfView = m_BaseWorldFOV * m_CurrentWorldState.FOVMultiplier;
        }

        public void SetCustomOverlayFOV(float fov)
        {
            float fovMultiplier = fov / (m_BaseOverlayFOV * m_IdleOverlayState.FOVMultiplier);
            m_CustomOverlayState = new CameraFOVState(fovMultiplier, 100f);
            m_OverlayCamera.fieldOfView = fov;
        }

        public void SetCustomOverlayFOV(float fovMultiplier, float setSpeed = 2f)
        {
            m_CustomOverlayState = new CameraFOVState(fovMultiplier, setSpeed);

            if (setSpeed == 0f)
                m_OverlayCamera.fieldOfView = m_BaseOverlayFOV * fovMultiplier;
        }

        public void ClearCustomOverlayFOV(bool instantly)
        {
            m_CustomOverlayState = null;

            if (instantly)
                m_OverlayCamera.fieldOfView = m_BaseOverlayFOV * m_IdleOverlayState.FOVMultiplier;
        }

        private void Update()
        {
            if (!IsInitialized)
                return;

            // Set World State
            var activeStateType = m_Motion.ActiveStateType;
            m_CurrentWorldState = GetWorldStateOfType(activeStateType);

            // Set World Camera FOV
            SetWorldCameraFOV();

            // Set Overlay Camera FOV
            SetOverlayCameraFOV();
        }

        private void SetWorldCameraFOV()
        {
            float baseFov = m_BaseWorldFOV * m_CurrentWorldState.FOVMultiplier;
            float fovMod = m_CustomWorldState == null ? baseFov : m_CustomWorldState.FOVMultiplier * baseFov;
            float fovSetSpeed = m_CustomWorldState == null ? m_CurrentWorldState.FOVSetSpeed : m_CustomWorldState.FOVSetSpeed;

            m_WorldCamera.fieldOfView = Mathf.Lerp(m_WorldCamera.fieldOfView, fovMod, fovSetSpeed * Time.deltaTime);
        }

        private void SetOverlayCameraFOV()
        {
            float baseFov = m_BaseOverlayFOV * m_IdleOverlayState.FOVMultiplier;
            float fovMod = m_CustomOverlayState == null ? baseFov : m_CustomOverlayState.FOVMultiplier * baseFov;
            float fovSetSpeed = m_CustomOverlayState == null ? m_IdleOverlayState.FOVSetSpeed : m_CustomOverlayState.FOVSetSpeed;

            m_OverlayCamera.fieldOfView = Mathf.Lerp(m_OverlayCamera.fieldOfView, fovMod, fovSetSpeed * Time.deltaTime);
        }

        private CameraFOVState GetWorldStateOfType(MotionStateType stateType)
        {
            for (int i = 0; i < m_WorldFOVStates.Length; i++)
            {
                if (m_WorldFOVStates[i].StateType == stateType)
                    return m_WorldFOVStates[i];
            }

            return m_WorldFOVStates[0];
        }
    }
}