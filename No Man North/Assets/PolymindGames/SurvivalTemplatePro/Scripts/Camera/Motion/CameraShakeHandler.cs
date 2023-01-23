using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro
{
    public class CameraShakeHandler : CharacterBehaviour, IMixedMotion
    {
        public Vector3 Position { get; private set; } = Vector3.zero;
        public Quaternion Rotation { get; private set; } = Quaternion.identity;

        [SerializeField]
        [Tooltip("The transform that will be rotated using a spring.")]
        private MotionMixer m_MotionMixer;

        [Space]

        [SerializeField, Range(0f, 500f)]
        private float m_LerpSpeed = 0f;

        [SerializeField]
        [Tooltip("The default shake spring force settings (Stiffness and Damping).")]
        private Spring.Settings m_SpringSettings = Spring.Settings.Default;

        [SpaceArea]

        [SerializeField]
        private ShakeSettings m_GetHitShake;

        private Spring m_PositionSpring;
        private Spring m_RotationSpring;

        private static CameraShakeHandler m_Instance;
        private readonly List<SpringShake> m_Shakes = new List<SpringShake>();


        public static void DoShake(Vector3 position, CameraShakeInfo shakeInfo, float scale)
        {
            ShakeSettings shakeSettings = shakeInfo.Settings;

            if (m_Instance == null || shakeSettings.Duration < 0.01f)
                return;

            float distToImpactSqr = (m_Instance.m_MotionMixer.TargetTransform.position - position).sqrMagnitude;
            float impactRadiusSqr = shakeInfo.Radius * shakeInfo.Radius;

            if (impactRadiusSqr - distToImpactSqr > 0f)
            {
                float distanceFactor = 1f - Mathf.Clamp01(distToImpactSqr / impactRadiusSqr);
                m_Instance.m_Shakes.Add(new SpringShake(shakeSettings, m_Instance.m_PositionSpring, m_Instance.m_RotationSpring, distanceFactor * scale));
            }
        }

        public static void DoShake(Vector3 position, ShakeSettings shakeSettings, float radius, float scale = 1f)
        {
            if (m_Instance == null || shakeSettings.Duration < 0.01f)
                return;

            float distToImpactSqr = (m_Instance.m_MotionMixer.TargetTransform.position - position).sqrMagnitude;
            float impactRadiusSqr = radius * radius;

            if (impactRadiusSqr - distToImpactSqr > 0f)
            {
                float distanceFactor = 1f - Mathf.Clamp01(distToImpactSqr / impactRadiusSqr);
                m_Instance.m_Shakes.Add(new SpringShake(shakeSettings, m_Instance.m_PositionSpring, m_Instance.m_RotationSpring, distanceFactor * scale));
            }
        }

        public static void DoShake(CameraShakeInfo shakeInfo, float scale = 1f)
        {
            ShakeSettings shakeSettings = shakeInfo.Settings;

            if (m_Instance == null || shakeSettings.Duration < 0.01f)
                return;

            m_Instance.m_Shakes.Add(new SpringShake(shakeSettings, m_Instance.m_PositionSpring, m_Instance.m_RotationSpring, scale));
        }

        public static void DoShake(ShakeSettings shakeSettings, float scale = 1f)
        {
            if (m_Instance == null || shakeSettings.Duration < 0.01f)
                return;

            m_Instance.m_Shakes.Add(new SpringShake(shakeSettings, m_Instance.m_PositionSpring, m_Instance.m_RotationSpring, scale));
        }

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

        public override void OnInitialized()
        {
            Character.HealthManager.onDamageTaken += OnDamageTaken;
        }

        private void OnEnable()
        {
            m_Instance = this;

            // Initalize the springs
            m_PositionSpring = new Spring(m_SpringSettings, m_LerpSpeed, 0);
            m_RotationSpring = new Spring(m_SpringSettings, m_LerpSpeed, 0);

            m_MotionMixer.AddMixedMotion(this);
        }

        private void OnDisable()
        {
            if (m_MotionMixer != null)
                m_MotionMixer.RemoveMixedMotion(this);
        }

        private void OnDamageTaken(DamageInfo dmgInfo)
        {
            if (dmgInfo.Damage < 5f)
                return;

            var healthManager = Character.HealthManager;
            float healthRemovePercent = Mathf.Min(1f, healthManager.MaxHealth / ((Character.HealthManager.PrevHealth - dmgInfo.Damage) * 2f));

            DoShake(m_GetHitShake, healthRemovePercent);
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
    }
}