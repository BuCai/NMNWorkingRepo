using System;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Event Listeners/Camera Animator")]
    public class WieldableCameraAnimator : STPWieldableEventsListener<WieldableCameraAnimator>
    {
        #region Internal
        [Serializable]
        protected class CameraMotionEvent : STPEventListenerBehaviour
        {
            [ReorderableList(elementLabel: "Camera Force")]
            public CameraForce[] CameraForces;

            protected override void OnActionTriggered(float value) => Instance.QueueCameraForces(CameraForces);
        }

        [Serializable]
        public struct CameraForce
        {
            [Range(0f, 5f)]
            public float Delay;

            public Vector3 Force;

            [Range(1, 20)]
            public int Distribution;
        }

        [Serializable]
        public struct QueuedCameraForce
        {
            public readonly float PlayTime;
            public readonly Vector3 Force;
            public readonly int Distribution;


            public QueuedCameraForce(CameraForce camForce)
            {
                PlayTime = Time.time + camForce.Delay;
                Force = camForce.Force;
                Distribution = camForce.Distribution;
            }
        }

        #endregion

        [SerializeField, ReorderableList(elementLabel: "Animation", Foldable = true)]
        private CameraMotionEvent[] m_AnimationSettings;

        private ICameraMotionHandler m_Motion;
        private readonly List<QueuedCameraForce> m_QueuedCamForces = new List<QueuedCameraForce>(10);


        protected override IEnumerable<STPEventListenerBehaviour> GetEvents() => m_AnimationSettings;

        protected void QueueCameraForces(CameraForce[] forces)
        {
            for (int i = 0; i < forces.Length; i++)
                m_QueuedCamForces.Add(new QueuedCameraForce(forces[i]));
        }

        protected override void OnInitialized(ICharacter character) => character.TryGetModule(out m_Motion);
        protected override void OnWieldableHolstered(float holsterSpeed) => m_QueuedCamForces.Clear();

        protected virtual void Update()
        {
            for (int i = 0; i < m_QueuedCamForces.Count; i++)
            {
                QueuedCameraForce cameraForce = m_QueuedCamForces[i];

                if (Time.time >= cameraForce.PlayTime)
                {
                    m_Motion.AddRotationForce(cameraForce.Force, cameraForce.Distribution);
                    m_QueuedCamForces.RemoveAt(i);
                }
            }
        }
    }
}