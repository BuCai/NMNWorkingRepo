using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/First Person/FP Recoil")]
    [RequireComponent(typeof(MotionMixer))]
    public class FPWieldableRecoil : STPWieldableEventsListener<FPWieldableRecoil>, IMixedMotion
    {
        #region Internal
        [System.Serializable]
        protected class RecoilEventSettings : STPEventListenerBehaviour
        {
            public RecoilType RecoilType;

            [Space]

            public FPRecoilForce Force;
            public ShakeSettings Shake;


            protected override void OnActionTriggered(float recoilMod)
            {
                switch (RecoilType)
                {
                    case RecoilType.Force:
                        Instance.AddRecoilForce(Force, recoilMod);
                        break;
                    case RecoilType.Skake:
                        Instance.DoShake(Shake, recoilMod);
                        break;
                    case RecoilType.Both:
                        Instance.AddRecoilForce(Force, recoilMod);
                        Instance.DoShake(Shake, recoilMod);
                        break;
                }
            }
        }

        protected enum RecoilType
        {
            Force,
            Skake,
            Both
        }
        #endregion

        public Vector3 Position { get; private set; } = Vector3.zero;
        public Quaternion Rotation { get; private set; } = Quaternion.identity;

        [Title("Spring")]

        [SerializeField, Range(0f, 100f)]
        private float m_SpringLerpSpeed = 30f;

        [SerializeField]
        private Spring.Settings m_PositionSpringSettings = Spring.Settings.Default;

        [SerializeField]
        private Spring.Settings m_RotationSpringSettings = Spring.Settings.Default;

        [SpaceArea]

        [SerializeField, ReorderableList(elementLabel: "Recoil", Foldable = true)]
        private RecoilEventSettings[] m_RecoilSettings;

        private Spring m_PositionSpring;
        private Spring m_RotationSpring;
        private IMotionMixer m_MotionMixer;

        private readonly List<SpringShake> m_Shakes = new List<SpringShake>();


        #region Public Methods
        public void AddRecoilForce(FPRecoilForce recoilForce, float recoilMod = 1f)
        {
            m_PositionSpring.AddForce(recoilForce.GetPositionForce(recoilMod));
            m_RotationSpring.AddForce(recoilForce.GetRotationForce(recoilMod));
        }

        public void AddPositionRecoil(SpringForce force) => m_PositionSpring.AddForce(force);
        public void AddRotationRecoil(SpringForce force) => m_RotationSpring.AddForce(force);

        public void SetCustomSpringSettings(Spring.Settings positionSettings, Spring.Settings rotationSettings)
        {
            m_PositionSpring.Adjust(positionSettings);
            m_RotationSpring.Adjust(rotationSettings);
        }

        public void ClearCustomSpringSettings() 
        {
            m_PositionSpring.Adjust(m_PositionSpringSettings);
            m_RotationSpring.Adjust(m_RotationSpringSettings);
        }

        public void DoShake(ShakeSettings shake, float shakeScale = 1f) => m_Shakes.Add(new SpringShake(shake, m_PositionSpring, m_RotationSpring, shakeScale));
        #endregion

        protected override IEnumerable<STPEventListenerBehaviour> GetEvents() => m_RecoilSettings;

        protected override void Awake()
        {
            base.Awake();

            m_MotionMixer = GetComponent<MotionMixer>();

            m_PositionSpring = new Spring(m_PositionSpringSettings, m_SpringLerpSpeed);
            m_RotationSpring = new Spring(m_RotationSpringSettings, m_SpringLerpSpeed);
        }

        private void OnEnable() => m_MotionMixer.AddMixedMotion(this);
        private void OnDisable() => m_MotionMixer.RemoveMixedMotion(this);

        public void FixedUpdateTransform(float deltaTime)
        {
            UpdateShakes();

            m_PositionSpring.FixedUpdate(deltaTime);
            m_RotationSpring.FixedUpdate(deltaTime);
        }

        public void UpdateTransform(float deltaTime)
        {
            m_PositionSpring.Update(deltaTime);
            m_RotationSpring.Update(deltaTime);

            Position = m_PositionSpring.Position;
            Rotation = m_RotationSpring.Rotation;
        }

        private void UpdateShakes()
        {
            if (m_Shakes.Count == 0)
                return;

            int i = 0;

            while (true)
            {
                if (m_Shakes[i].IsDone)
                    m_Shakes.RemoveAt(i);
                else
                {
                    m_Shakes[i].Update();
                    i++;
                }

                if (i >= m_Shakes.Count)
                    break;
            }
        }

#if UNITY_EDITOR
        private void OnValidate()
        {
            if (Application.isPlaying && m_PositionSpring != null)
            {
                m_PositionSpring.Adjust(m_PositionSpringSettings);
                m_RotationSpring.Adjust(m_RotationSpringSettings);
            }
        }
#endif
    }
}