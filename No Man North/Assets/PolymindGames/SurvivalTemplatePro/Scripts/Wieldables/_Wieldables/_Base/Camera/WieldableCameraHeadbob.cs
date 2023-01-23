using SurvivalTemplatePro.CameraSystem;
using System;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Event Listeners/Camera Headbob")]
    public class WieldableCameraHeadbob : STPWieldableEventsListener<WieldableCameraHeadbob>
    {
        #region Internal
        [Serializable]
        protected class CameraRecoilEventSettings : STPEventListenerBehaviour
        {
            public CameraBob Headbob;

            protected override void OnActionTriggered(float value) => Instance.SetHeadbob(Headbob);
        }

        #endregion

        [SerializeField, ReorderableList(elementLabel: "Headbob", Foldable = true)]
        private CameraRecoilEventSettings[] m_HeadbobSettings;

        [SerializeField, Tooltip("Events that will reset this behavior")]
        private STPActionEventsListener m_ResetSettings;

        private ICameraMotionHandler m_Motion;


        protected override IEnumerable<STPEventListenerBehaviour> GetEvents()
        {
            var list = new List<STPEventListenerBehaviour>();
            list.AddRange(m_HeadbobSettings);
            list.Add(m_ResetSettings);
            return list;
        }

        protected void SetHeadbob(CameraBob cameraHeadbob) => m_Motion.SetCustomHeadbob(cameraHeadbob);
        protected void ClearHeadbob() => m_Motion.SetCustomHeadbob(null);

        protected override void Awake()
        {
            base.Awake();

            m_ResetSettings.onActionTriggered += ClearHeadbob;
        }

        protected override void OnInitialized(ICharacter character) => character.TryGetModule(out m_Motion);
        protected override void OnWieldableHolstered(float holsterSpeed) => m_Motion.SetCustomHeadbob(null);
    }
}