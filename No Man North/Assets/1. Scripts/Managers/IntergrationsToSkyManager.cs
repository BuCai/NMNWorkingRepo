using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Enviro;
using TheVegetationEngine;
using SurvivalTemplatePro.WorldManagement;

namespace MLC.NoManNorth.Eric {
    public class IntergrationsToSkyManager : MonoBehaviour {
        public static IntergrationsToSkyManager Instance { get; private set; }

        #region Variables
        [SerializeField] private EnviroManager skyManager;

        [SerializeField] private EventChannelInt OnDayChange;
        [SerializeField] private EventChannelInt OnHourChange;
        [SerializeField] private EventChannelInt OnMinChange;

        [SerializeField] private EventChannel OnWeatherChange;

        private int hoursBeforeNextChange = 3;
        [SerializeField] private int hoursbetweenWeatherChange;

        private float currentHour = 0;
        private float currentMin = 0;

        //set to sunny to start with
        private int currentWeatherId = 2;
        private bool isInWarningArea = false;
        private bool isInFrostWall = false;
        #endregion

        #region Unity Methods

        private void Awake() {
            if (Instance != null && Instance != this) {
                Destroy(this);
            } else {
                Instance = this;
                if (OnDayChange != null) OnDayChange.OnEvent += OnDayChange_OnEvent;
                if (OnHourChange != null) OnHourChange.OnEvent += OnHourChange_OnEvent;
                if (OnMinChange != null) OnMinChange.OnEvent += OnMinChange_OnEvent;
            }
        }

        private void Update() {
            skyManager.Time.SetTimeOfDay(WorldManager.Instance.GetNormalizedTime() * 24);

            //Consider moving this to onweatherchanged
            if (TheVegetationEngine.TVEManager.Instance != null) {
                TheVegetationEngine.TVEManager.Instance.globalMotion.windPower = skyManager.Environment.Settings.windSpeed;
            }
        }

        private void Start() {
            //set the sky manger to sunny
            changeWeather();
        }

        private void OnDestroy() {
            if (OnDayChange != null) OnDayChange.OnEvent -= OnDayChange_OnEvent;
            if (OnHourChange != null) OnHourChange.OnEvent -= OnHourChange_OnEvent;
            if (OnMinChange != null) OnMinChange.OnEvent -= OnMinChange_OnEvent;

        }

        #endregion



        #region Methods
        private void OnDayChange_OnEvent(int dayNumber) {
            skyManager.Time.days = dayNumber;
        }


        private void OnHourChange_OnEvent(int hourNumber) {
            currentHour = hourNumber;
            //SetTime();

            hoursBeforeNextChange--;

            if (hoursBeforeNextChange <= 0) {
                //Takes a random weather id for the next weather not including the snow/heavy snow
                //currentWeatherId = Random.Range(2, skyManager.GetCurrentWeatherPresetList().Count);
                changeWeather();

                hoursBeforeNextChange = hoursbetweenWeatherChange;
            }

        }

        private void OnMinChange_OnEvent(int minNumber) {
            currentMin = minNumber;
            //SetTime();
        }

        private void changeWeather() {
            //DEBUG
            return;
            /*
            if (isInFrostWall == true) {
                Debug.Log("Heavy snow");
                skyManager.ChangeWeather(1);
                OnWeatherChange.RaiseEvent();
            } else if (isInWarningArea == true) {
                skyManager.ChangeWeather(0);
                Debug.Log("Light snow");
                OnWeatherChange.RaiseEvent();
            } else {
                Debug.Log("Weather ID: " + currentWeatherId.ToString());
                skyManager.ChangeWeather(currentWeatherId);
                OnWeatherChange.RaiseEvent();
            }
            */
        }

        public void playerEnteredWarningArea() {
            isInWarningArea = true;
            changeWeather();
        }

        public void playerLeftWarningArea() {
            isInWarningArea = false;
            changeWeather();
        }


        public void playerEnteredFrostWall() {
            isInFrostWall = true;
            changeWeather();
        }

        public void playerLeftFrostWall() {
            isInFrostWall = false;
            changeWeather();
        }

        #endregion
    }
}