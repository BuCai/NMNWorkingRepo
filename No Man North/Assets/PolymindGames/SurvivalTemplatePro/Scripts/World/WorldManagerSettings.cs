using System;
using UnityEngine;
using Enviro;

//Modified along with world manager
namespace SurvivalTemplatePro.WorldManagement {
    [Serializable]
    public class TimeSettings {
        [Title("Time Progression")]

        public bool ProgressTime;

        [Range(0, 24)]
        public int Hour = 12;

        [Range(0, 60)]
        public int Minute;

        [Range(0, 60)]
        public int Second;

        [Title("Cycle Duration")]

        [Range(0, 120)]
        [Tooltip("Day duration in real time minutes.")]
        public float DayDurationInMinutes = 5f;

        [Range(0, 120)]
        [Tooltip("Night duration in real time minutes.")]
        public float NightDurationInMinutes = 5f;
    }

    [Serializable]
    public class WeatherSettings {
        [Title("Weather Changing")]
        [Tooltip("In-game hours between random weather selections")]
        public float weatherChangeHours = 12f;

        public WeatherCyle earlyStage;
        public WeatherCyle midStage;
        public WeatherCyle endStage;

        [Header("TVE Transition")]
        [Tooltip("Duration in in-game hours of how long the transition will take")]
        public float tveTransitionDurationInGameHours = 6f;
        [Tooltip("Starting TVE season float, should be late autumn")]
        public float startSeason = 3.2f;
        [Tooltip("Ending TVE season float, should be winter")]
        public float endSeason = 4f;

        [Tooltip("Starting TVE overlay float (Snow), should be not snowed at all")]
        public float startOverlay = 0.48f;
        [Tooltip("Ending TVE overlay float (Snow), should be fully covered in snow")]
        public float endOverlay = 1f;

        [Header("Storm")]
        [Tooltip("Position the storm object will be set to at the start of the game")]
        public Vector3 stormStartPos;
        [Tooltip("Storm weather preset")]
        public EnviroWeatherType stormWeatherType;
    }

    [Serializable]
    public struct WeatherCyle {
        [Tooltip("Position the storm object will be moving towards during the cycle")]
        public Vector3 stormTargetPos;
        [Tooltip("Duration in in-game hours of how long the storm will take to move to the target position")]
        public float stormTransitionDurationInGameHours;
        public WeatherPreset[] presets;

        [Serializable]
        public struct WeatherPreset {
            [SerializeField, Range(0, 1)] private float Weight;
            [HideInInspector] public float weight { get { return Weight; } set { Weight = Mathf.Clamp01(value); } }
            public EnviroWeatherType weatherType;
        }
    }

}