using System.Collections;
using UnityEngine;
using MLC.NoManNorth.Eric;
using Enviro;
using TheVegetationEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace SurvivalTemplatePro.WorldManagement {

    //Modified heavily from original stp world manager. Only handles time and weather changing
    //Note: Weather systems may not work properly if there are any active weather zones
    //This is because enviro 3 changes the way it handles weather changes when there are active weather zones
    public class WorldManager : WorldManagerBase, ISaveableComponent {
        public override bool TimeProgressionEnabled {
            get => m_Time.ProgressTime;
            set => m_Time.ProgressTime = value;
        }

        [SerializeField] private TimeSettings m_Time;

        private float m_DayDurationInMinutes;
        private float m_DayDurationInSeconds;
        private float m_TimeIncrementPerSecond;

        private float m_NormalizedTime;
        private TimeOfDay m_TimeOfDay;

        [SerializeField] private WeatherSettings m_Weather;

        enum WeatherStage {
            Early,
            Mid,
            End
        }
        private float weatherChangeCountdown; //Progress of the weather change timer from 0 to 1
        private float tveTransition = 0; //Progress of the tve transition from 0 to 1
        private float stormTransition = 0; //Progress of the storm transition from 0 to 1 (Resets every stage change)
        private bool m_inStorm = false;
        private bool inStorm {
            get { return m_inStorm; }
            set {
                if (m_inStorm != value) {
                    m_inStorm = value;
                    InStormChanged();
                }
            }
        }
        private GameObject stormObj;
        private WeatherStage curWeatherStage = WeatherStage.Early;
        private WeatherCyle curWeatherCycle {
            get {
                switch (curWeatherStage) {
                    case WeatherStage.Early:
                        return m_Weather.earlyStage;
                    case WeatherStage.Mid:
                        return m_Weather.midStage;
                    case WeatherStage.End:
                        return m_Weather.endStage;
                    default:
                        return new WeatherCyle();
                }
            }
        }

        //These are events that other classes/gameObjects will use to determine the time.
        [Header("Events")]

        public EventChannelInt dayChange;
        public EventChannelInt hourChange;
        public EventChannelInt minChange;


#if UNITY_EDITOR
        public void DisplayDebugInfo() {
            GUIStyle style = EditorStyles.centeredGreyMiniLabel;
            style.alignment = TextAnchor.MiddleLeft;

            EditorGUILayout.LabelField("Current Weather Stage: " + curWeatherStage, style);
            EditorGUILayout.LabelField("Current Weather Type: " + EnviroManager.instance.Weather.targetWeatherType.name, style);
            EditorGUILayout.LabelField("Current Environment Temperature: " + EnviroManager.instance.Environment.Settings.temperature.ToString("F1") + "°C", style);
            EditorGUILayout.Space();
            if (TVEManager.Instance != null) {
                EditorGUILayout.LabelField("Current TVE Transition: " + (tveTransition * 100).ToString("F1") + "%", style);
                EditorGUILayout.LabelField("Current TVE Season: " + TVEManager.Instance.globalControl.seasonControl.ToString("F2"), style);
                EditorGUILayout.LabelField("Current TVE Overlay: " + TVEManager.Instance.globalControl.globalOverlay.ToString("F2"), style);
                EditorGUILayout.LabelField("Current TVE Wind Power: " + TVEManager.Instance.globalMotion.windPower.ToString("F2"), style);
                EditorGUILayout.Space();
            }
            if (stormObj != null) {
                EditorGUILayout.LabelField("Current Storm Transition: " + (stormTransition * 100).ToString("F1") + "%", style);
                EditorGUILayout.LabelField("Current Storm Position: " + stormObj.transform.position.ToString("F0"), style);
                EditorGUILayout.LabelField("Current Storm Target Position: " + curWeatherCycle.stormTargetPos.ToString("F0"), style);
                EditorGUILayout.Space();
            }
            EditorGUILayout.LabelField("Normalized Time: " + (float)System.Math.Round(m_NormalizedTime, 2), style);
            EditorGUILayout.LabelField("Time Of Day: " + m_TimeOfDay, style);
            EditorGUILayout.LabelField("Hour: " + m_Time.Hour, style);
            EditorGUILayout.LabelField("Minute: " + m_Time.Minute, style);
            EditorGUILayout.LabelField("Second: " + m_Time.Second, style);
        }

        private void OnValidate() {
            if (m_Time == null)
                return;

            HandleSettings();
        }
#endif

        public void LoadMembers(object[] members) {
            m_NormalizedTime = (float)members[0];
            UpdateTime();
        }

        public object[] SaveMembers() {
            return new object[]
            {
                m_NormalizedTime
            };
        }

        public override float GetNormalizedTime() => m_NormalizedTime;
        public override TimeOfDay GetTimeOfDay() => m_TimeOfDay;
        public override GameTime GetGameTime() => new GameTime(m_Time.Hour, m_Time.Minute, m_Time.Second);
        public override float GetDayDurationInMinutes() => m_DayDurationInMinutes;
        public override float GetTimeIncrementPerSecond() => m_TimeIncrementPerSecond;

        public override void PassTime(float timeToPass, float duration) => StartCoroutine(C_PassTime(timeToPass, duration));

        private void Awake() {
            if (Instance == this)
                LevelManager.onGameLoaded += OnGameLoaded;
            m_DayDurationInMinutes = m_Time.DayDurationInMinutes + m_Time.NightDurationInMinutes;
            HandleSettings();
        }

        private int lastMinuteBroadcasted;
        private int lastHourBroadcasted;

        private void Start() {
            minChange.RaiseEvent(m_Time.Minute);
            lastMinuteBroadcasted = m_Time.Minute;
            hourChange.RaiseEvent(m_Time.Hour);
            lastHourBroadcasted = m_Time.Hour;
        }

        private void OnGameLoaded() {
            stormObj = GameObject.FindGameObjectWithTag("Storm");
            if (stormObj != null) {
                stormObj.transform.position = m_Weather.stormStartPos;
                StartCoroutine(StormTransition());
                EnableStormMist();
            }
        }

        private void Update() {
            if (!m_Time.ProgressTime || STPGameStateManager.Instance.isPaused || LevelManager.Instance.IsLoading)
                return;

            UpdateWeather();
            UpdateTime();
        }

        public void AdvanceWeatherStage() {
            //TODO
            //Change TVE season and opacity (Should take a few in game hours of snowing to transition fully)

            switch (curWeatherStage) {
                case WeatherStage.Early:
                    curWeatherStage = WeatherStage.Mid;
                    SwitchToWeather(curWeatherCycle.presets[0].weatherType);
                    StartCoroutine(StormTransition());
                    StartCoroutine(TVETransition());
                    return;
                case WeatherStage.Mid:
                    curWeatherStage = WeatherStage.End;
                    SwitchToWeather(curWeatherCycle.presets[0].weatherType);
                    StartCoroutine(StormTransition());
                    return;
                default:
                    Debug.Log("Cannot advance weather stage");
                    return;
            }
        }


        //Enable volumetric fog and mist
        private void EnableStormMist() {
            if (stormObj == null)
                return;

            VolumetricFogAndMist2.VolumetricFog mist = stormObj.GetComponentInChildren<VolumetricFogAndMist2.VolumetricFog>();
            if (mist != null)
                mist.gameObject.SetActive(true);
        }

        private IEnumerator StormTransition() {
            if (stormObj == null) {
                yield break;
            }
            WeatherCyle wCycle = curWeatherCycle;

            stormTransition = 0;
            Vector3 stormStartPos = stormObj.transform.position;
            while (stormTransition < 1 && WeatherCyle.Equals(wCycle, curWeatherCycle)) {
                if (m_Time.ProgressTime && !STPGameStateManager.Instance.isPaused && !LevelManager.Instance.IsLoading) {
                    stormTransition += (24 * m_TimeIncrementPerSecond * Time.deltaTime) / curWeatherCycle.stormTransitionDurationInGameHours;
                    stormObj.transform.position = Vector3.Lerp(stormStartPos, curWeatherCycle.stormTargetPos, stormTransition);
                }
                yield return null;
            }
        }

        private IEnumerator TVETransition() {
            if (TVEManager.Instance == null) {
                Debug.LogWarning("TVE not found");
                yield break;
            }
            tveTransition = 0;
            while (tveTransition < 1) {
                if (m_Time.ProgressTime && !STPGameStateManager.Instance.isPaused && !LevelManager.Instance.IsLoading) {
                    tveTransition += (24 * m_TimeIncrementPerSecond * Time.deltaTime) / m_Weather.tveTransitionDurationInGameHours;
                    TVEManager.Instance.globalControl.seasonControl = Mathf.Lerp(m_Weather.startSeason, m_Weather.endSeason, tveTransition);
                    TVEManager.Instance.globalControl.globalOverlay = Mathf.Lerp(m_Weather.startOverlay, m_Weather.endOverlay, tveTransition);
                }
                yield return null;
            }
        }

        private void UpdateWeather() {
            if (stormObj != null) {
                CheckStorm();
            }
            if (!inStorm) {
                weatherChangeCountdown += (24 * m_TimeIncrementPerSecond * Time.deltaTime) / m_Weather.weatherChangeHours; ;
                if (weatherChangeCountdown >= 1) {
                    CycleWeather();
                }
            }
        }

        private void CheckStorm() {
            Vector3 playerPos = Player.LocalPlayer.transform.position;
            playerPos.y = 0;
            Vector3 stormPos = stormObj.transform.position;
            stormPos.y = 0;
            //Change lossyScale.x to storms radius if storm is no longer scaled that way
            inStorm = Vector3.Distance(playerPos, stormPos) <= stormObj.transform.lossyScale.x / 2;
        }

        private void InStormChanged() {
            if (inStorm) {
                SwitchToWeather(m_Weather.stormWeatherType);
            } else {
                CycleWeather();
            }
        }

        private void SwitchToWeather(EnviroWeatherType RWType) {
            weatherChangeCountdown = 0;
            Debug.Log("Changing weather preset to " + RWType.name);
            EnviroManager.instance.Weather.ChangeWeather(RWType);
        }

        //Cycles weather type in current cylce
        public void CycleWeather() {
            if (inStorm) {
                return;
            }
            //Chooses a weather preset randomly using the weights
            float totalWeight = 0;
            foreach (WeatherCyle.WeatherPreset weatherPreset in curWeatherCycle.presets) {
                totalWeight += weatherPreset.weight;
            }
            float rand = Random.Range(0, totalWeight);
            float curWeight = 0;
            EnviroWeatherType RWType = null; //Random weather type
            foreach (WeatherCyle.WeatherPreset weatherPreset in curWeatherCycle.presets) {
                curWeight += weatherPreset.weight;
                if (rand <= curWeight) {
                    RWType = weatherPreset.weatherType;
                    break;
                }
            }
            SwitchToWeather(RWType);
        }

        private void UpdateTime() {
            m_NormalizedTime += m_TimeIncrementPerSecond * Time.deltaTime;
            if (m_NormalizedTime >= 1f) {
                dayChange.RaiseEvent(0);
            }
            m_NormalizedTime = Mathf.Repeat(m_NormalizedTime, 1f);

            m_TimeOfDay = (m_NormalizedTime < 0.25f || m_NormalizedTime >= 0.75f) ? TimeOfDay.Night : TimeOfDay.Day;

            m_Time.Hour = (int)(m_NormalizedTime * 24);
            m_Time.Minute = (int)((m_NormalizedTime * 24 - m_Time.Hour) * 60);
            m_Time.Second = (int)((((m_NormalizedTime * 24 - m_Time.Hour) * 60) - m_Time.Minute) * 60);

            if (m_Time.Hour != lastHourBroadcasted) {
                hourChange.RaiseEvent(m_Time.Hour);
                lastHourBroadcasted = m_Time.Hour;
            }
            if (m_Time.Minute != lastMinuteBroadcasted) {
                minChange.RaiseEvent(m_Time.Minute);
                lastMinuteBroadcasted = m_Time.Minute;
            }
        }

        private void HandleSettings() {
            m_NormalizedTime = (float)m_Time.Hour / 24 + (float)m_Time.Minute / 1440 + (float)m_Time.Second / 86400;
            m_TimeOfDay = (m_NormalizedTime < 0.25f || m_NormalizedTime >= 0.75f) ? TimeOfDay.Night : TimeOfDay.Day;

            m_DayDurationInSeconds = (m_Time.DayDurationInMinutes + m_Time.NightDurationInMinutes) * 60;
            m_TimeIncrementPerSecond = 1f / m_DayDurationInSeconds;
        }

        private IEnumerator C_PassTime(float timeToPass, float duration) {
            yield return null;

            bool timeProgressionActive = m_Time.ProgressTime;
            m_Time.ProgressTime = true;

            m_TimeIncrementPerSecond = timeToPass * (1 / duration);

            yield return new WaitForSeconds(duration);

            m_Time.ProgressTime = timeProgressionActive;
            m_TimeIncrementPerSecond = 1f / m_DayDurationInSeconds;
        }
    }
}