using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    public class RadiationManager : CharacterVitalModule, IRadiationManager
    {
        public bool HasMaxRadiation => m_MaxRadiation - m_Radiation < 0.01f;

        public float Radiation
        {
            get => m_Radiation;
            set
            {
                float clampedValue = Mathf.Clamp(value, 0f, m_MaxRadiation);

                if (value != m_Radiation && clampedValue != m_Radiation)
                {
                    m_Radiation = clampedValue;
                    onThirstChanged?.Invoke(clampedValue);
                }
            }
        }

        public float MaxRadiation
        {
            get => m_MaxRadiation;
            set
            {
                float clampedValue = Mathf.Max(value, 0f);

                if (value != m_MaxRadiation && clampedValue != m_MaxRadiation)
                {
                    m_MaxRadiation = clampedValue;
                    onMaxThirstChanged?.Invoke(clampedValue);

                    Radiation = Mathf.Clamp(Radiation, 0f, m_MaxRadiation);
                }
            }
        }

        public event UnityAction<float> onThirstChanged;
        public event UnityAction<float> onMaxThirstChanged;

        private float m_Radiation;
        private float m_MaxRadiation;


        protected override void Awake()
        {
            base.Awake();

            InitalizeStat(ref m_Radiation, ref m_MaxRadiation);
        }

        private void Update()
        {
            if (m_HealthManager.IsAlive)
                DepleteStat(ref m_Radiation, m_MaxRadiation);
        }

#if UNITY_EDITOR
        protected override void OnValidate()
        {
            base.OnValidate();

            if (!Application.isPlaying)
                return;

            MaxRadiation = m_InitialMaxValue;
            Radiation = m_InitialValue;
        }
#endif
    }
}