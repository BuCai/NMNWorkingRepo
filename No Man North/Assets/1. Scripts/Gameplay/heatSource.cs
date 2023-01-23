using Micosmo.SensorToolkit;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class heatSource : MonoBehaviour
    {
        #region Variables

        [SerializeField] private EventChannelInt OnMinChange;
        [SerializeField] private bool startLit = false;
        [SerializeField] private int minToLightFor;
        [SerializeField] private RangeSensor worldFrostLisenerSensor;

        [SerializeField] private GameObject LitEffects;

        //private List<WorldColdLisener> affectedUnits = new List<WorldColdLisener>();
        private int timeLeft;

        #endregion

        #region Unity Methods

        private void Start()
        {
            if (startLit)
            {
                lightFire();
            }
            else
            {
                fireExtinguished();
                this.enabled = false;
            }
        }



        #endregion

        #region Methods



        public void lightFire()
        {
            LitEffects.gameObject.SetActive(true);

            worldFrostLisenerSensor.enabled = true;

            worldFrostLisenerSensor.OnDetected.AddListener(OnEnterHeatSource);
            worldFrostLisenerSensor.OnLostDetection.AddListener(OnExitHeatSource);

            timeLeft = minToLightFor;

            OnMinChange.OnEvent += OnMinChange_OnEvent;

            this.enabled = true;
        }

        public void fireExtinguished()
        {
            LitEffects.gameObject.SetActive(false);

            worldFrostLisenerSensor.OnDetected.RemoveListener(OnEnterHeatSource);
            worldFrostLisenerSensor.OnLostDetection.RemoveListener(OnExitHeatSource);

            worldFrostLisenerSensor.enabled = false;
            OnMinChange.OnEvent -= OnMinChange_OnEvent;

            this.enabled = false;
        }

        private void OnMinChange_OnEvent(int obj)
        {
            timeLeft--;
            if (timeLeft <=0 )
            {
                fireExtinguished();
            }
        }

        private void OnEnterHeatSource(GameObject foundGameObject, Sensor sendo)
        {
            
            if (foundGameObject.TryGetComponent<WorldColdLisener>(out WorldColdLisener wcl))
            {
                print(foundGameObject.name);
                wcl.enterHeatSoruce(this);
            }
        }

        private void OnExitHeatSource(GameObject foundGameObject, Sensor sendo)
        {
            if (foundGameObject.TryGetComponent<WorldColdLisener>(out WorldColdLisener wcl))
            {
                wcl.exitHeatSource(this);
            }
        }

        #endregion
    }
}