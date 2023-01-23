using UnityEngine;
using UnityEngine.Events;
using Enviro;

namespace SurvivalTemplatePro {
    //COMPLETELY OVERHAULED
    //Functions completely differently from the STP temperature manager

    //Player temperature is interpolated by taking into account the environment temperature, zone temperature and any effectors (offset)
    //Other systems can subscribe to the temperatureLevelChanged event to update their effects depending on the temperature level

    public enum TemperatureLevel {
        Freezing,
        Chill,
        Mild,
        Warm,
        Hot
    }

    public class TemperatureManager : MonoBehaviour, ITemperatureManager {

        [SerializeField] private float tempChangeTime = 1f;

        [Header("Minimum temperatures for each temperature level")]
        public float chillTemp = 0;
        public float mildTemp = 10;
        public float warmTemp = 17;
        public float hotTemp = 25;

        [Header("Temperature vital effect settings")]
        [SerializeField] private float freezingDPS = 2;
        [SerializeField] private float hotDPS = 5;

        private HealthManager healthManager;
        private TemperatureLevel m_curTempLevel = TemperatureLevel.Mild;
        public UnityEvent<TemperatureLevel> temperatureLevelChanged = new UnityEvent<TemperatureLevel>();
        private float m_PlayerTemperature = 15;
        public TemperatureLevel curTemperatureLevel {
            get => m_curTempLevel;
            set {
                if (m_curTempLevel != value) {
                    m_curTempLevel = value;
                    temperatureLevelChanged.Invoke(value);
                }
            }
        }
        public float PlayerTemperature {
            get => m_PlayerTemperature;
        }

        private TemperatureZone temperatureZone;
        public float tempOffset { get; set; }

        private void Awake() {
            healthManager = GetComponent<HealthManager>();
            if (healthManager == null) {
                Debug.LogWarning("Temperature manager running without health manager");
            }
            m_PlayerTemperature = getTargetTemperature();
        }

        private void Start() {
            temperatureLevelChanged.Invoke(curTemperatureLevel);
        }

        private float curTempDelta = 0;
        private float upsCountdown = 1;
        private void Update() {
            if (STPGameStateManager.Instance.isPaused) {
                return;
            }
            upsCountdown -= Time.deltaTime;
            if (upsCountdown <= 0) {
                upsCountdown += 1;
                UpdatePerSecond();
            }

            float targetTemp = getTargetTemperature();
            m_PlayerTemperature = Mathf.SmoothDamp(m_PlayerTemperature, targetTemp, ref curTempDelta, tempChangeTime);
            if (Mathf.Abs(m_PlayerTemperature - targetTemp) < 0.1f) {
                m_PlayerTemperature = targetTemp;
            }
            UpdateTemperatureLevel();
        }

        //Runs approximately once a second
        private void UpdatePerSecond() {
            UpdateTemperatureEffects();
        }

        private void UpdateTemperatureEffects() {
            if (healthManager == null) {
                return;
            }
            switch (curTemperatureLevel) {
                case TemperatureLevel.Freezing:
                    healthManager.ReceiveDamage(new DamageInfo(freezingDPS));
                    healthManager.temperatureRegenMultiplier = 0f;
                    break;
                case TemperatureLevel.Chill:
                    healthManager.temperatureRegenMultiplier = 0.3f;
                    break;
                case TemperatureLevel.Mild:
                    healthManager.temperatureRegenMultiplier = 1f;
                    break;
                case TemperatureLevel.Warm:
                    healthManager.temperatureRegenMultiplier = 1.5f;
                    break;
                case TemperatureLevel.Hot:
                    healthManager.temperatureRegenMultiplier = 1f;
                    healthManager.ReceiveDamage(new DamageInfo(hotDPS));
                    break;
                default:
                    break;
            }
        }

        private void UpdateTemperatureLevel() {
            if (m_PlayerTemperature >= hotTemp) {
                curTemperatureLevel = TemperatureLevel.Hot;
            } else if (m_PlayerTemperature >= warmTemp) {
                curTemperatureLevel = TemperatureLevel.Warm;
            } else if (m_PlayerTemperature >= mildTemp) {
                curTemperatureLevel = TemperatureLevel.Mild;
            } else if (m_PlayerTemperature >= chillTemp) {
                curTemperatureLevel = TemperatureLevel.Chill;
            } else {
                curTemperatureLevel = TemperatureLevel.Freezing;
            }
        }

        //Checks for temperature zones
        private void FixedUpdate() {
            TemperatureZone _temperatureZone = null;
            float _tempOffset = 0;

            Vector3 checkPosOffset = new Vector3(0, 1, 0);
            Collider[] cols = Physics.OverlapSphere(transform.position + checkPosOffset, 0.05f, LayerMask.GetMask("TempZone", "TempEffector"), QueryTriggerInteraction.Collide);
            if (cols != null && cols.Length != 0) {
                foreach (Collider col in cols) {
                    if (col.gameObject.layer == LayerMask.NameToLayer("TempZone")) {
                        _temperatureZone = col.GetComponent<TemperatureZone>();
                    } else {
                        TemperatureEffector colEffector = col.GetComponent<TemperatureEffector>();
                        float distanceToEffector = Vector3.Distance(transform.position + checkPosOffset, col.transform.position);
                        float colTempFactor = 1f - distanceToEffector / colEffector.Radius;
                        float colTempOffset = colEffector.maxTemperatureOffset * colTempFactor * colEffector.temperatureStrength;
                        _tempOffset = Mathf.Max(_tempOffset, colTempOffset);
                    }
                }
            }
            temperatureZone = _temperatureZone;
            tempOffset = _tempOffset;
        }

        private float getTargetTemperature() {
            if (temperatureZone != null) {
                return temperatureZone.ZoneTemperature + tempOffset;
            } else {
                return EnviroTemperature + tempOffset;
            }
        }

        public float EnviroTemperature {
            get => EnviroManager.instance.Environment.Settings.temperature;
        }

    }
}