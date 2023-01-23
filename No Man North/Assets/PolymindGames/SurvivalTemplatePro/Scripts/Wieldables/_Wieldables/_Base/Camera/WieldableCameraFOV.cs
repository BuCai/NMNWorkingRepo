using System;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Event Listeners/Camera FOV")]
    public class WieldableCameraFOV : STPWieldableEventsListener<WieldableCameraFOV>
    {
        #region Internal
        [Serializable]
        protected class CameraFOVEventSettings : STPEventListenerBehaviour
        {
            [Range(0f, 2)]
            public float FOVMod = 1f;

            [Range(0f, 2f)]
            public float FOVSetDelay = 0f;

            [Range(1f, 100f)]
            public float FOVSetSpeed = 10f;

            public bool ResetInstantly = false;

            protected override void OnActionTriggered(float value) => Instance.SetFOV(this, value);
        }
        #endregion

        [SerializeField, Range(0f, 110f), InfoBox("Field of View of the FP Model")]
        private float m_OverlayFOV = 45f;

        [SpaceArea]

        [SerializeField, ReorderableList(elementLabel: "FOV", Foldable = true)]
        private CameraFOVEventSettings[] m_CameraFOVSettings;

        [SerializeField, Tooltip("Events that will reset this behavior")]
        private STPActionEventsListener m_CameraFOVResetSettings;

        private float m_SetFOVDelayedTime;
        private bool m_SetFOVDelayed;
        private float m_FOVMod;

        private ICameraFOVHandler m_FOV;
        private CameraFOVEventSettings m_Current;


        protected override IEnumerable<STPEventListenerBehaviour> GetEvents()
        {
            var list = new List<STPEventListenerBehaviour>();
            list.AddRange(m_CameraFOVSettings);
            list.Add(m_CameraFOVResetSettings);
            return list;
        }

        protected void ResetFOV()
        {
            m_FOV.ClearCustomWorldFOV(m_Current != null && m_Current.ResetInstantly);
            m_SetFOVDelayed = false;
        }

        protected void SetFOV(CameraFOVEventSettings settings, float fovMod)
        {
            m_Current = settings;
            m_FOVMod = settings.FOVMod * fovMod;
            m_SetFOVDelayedTime = Time.time + m_Current.FOVSetDelay;
            m_SetFOVDelayed = true;
        }

        protected override void OnInitialized(ICharacter character) => character.TryGetModule(out m_FOV);

        protected override void OnWieldableEquipped()
        {
            base.OnWieldableEquipped();
            m_FOV.SetCustomOverlayFOV(m_OverlayFOV);
        }

        protected override void OnWieldableHolstered(float holsterSpeed) => ResetFOV();

        protected override void Awake()
        {
            base.Awake();
            m_CameraFOVResetSettings.onActionTriggered += ResetFOV;
        }

        private void Update()
        {
            if (m_SetFOVDelayed && Time.time > m_SetFOVDelayedTime)
                m_FOV.SetCustomWorldFOV(m_FOVMod, m_Current.FOVSetSpeed);
        }

#if UNITY_EDITOR
        private void OnValidate()
        {
            if (m_FOV != null && Application.isPlaying && Application.isEditor)
                m_FOV.SetCustomOverlayFOV(m_OverlayFOV);
        }
#endif
    }
}