using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NWH.VehiclePhysics2;
using Enviro;

namespace SurvivalTemplatePro {

    //Handles the RV temperature zone, ac and stove
    public class RvTemperatureZone : TemperatureZone {
        [SerializeField] private RvResources resources;
        [SerializeField] private VehicleController vehicle;

        [SerializeField] private float acTempOffset = 5f;
        [SerializeField] private float stoveTempOffset = 7f;
        [SerializeField] private Interactable acInteractable;
        [SerializeField] private GameObject stoveTempEffector;

        //Amount of propane used per in-game hour to run the stove (1f = 1L of propane per in-game hour)
        [SerializeField] private float stovePropaneUse = 5f;

        private float m_zoneTemperature;
        private float tempOffset { get { return (acTempOffset * (isAcOn ? 1 : 0)) + (stoveTempOffset * (isStoveOn ? 1 : 0)); } }
        private bool isAcOn = false;
        private bool isStoveOn = false;

        [HideInInspector] public override float ZoneTemperature { get => m_zoneTemperature; }
        public float EnviroTemperature {
            get => EnviroManager.instance.Environment.Settings.temperature;
        }

        private void Awake() {
            if (resources == null) {
                Debug.LogError("Rv Resources script not assigned");
            }
            if (vehicle == null) {
                Debug.LogError("Vehicle controller not assigned");
            }
            stoveTempEffector.SetActive(isStoveOn);
        }
        private void Update() {
            if (isStoveOn) {
                if (resources.propaneLeft <= 0) {
                    toggleStove();
                } else {
                    resources.propaneLeft -= stovePropaneUse * Time.deltaTime * WorldManagement.WorldManager.Instance.GetTimeIncrementPerSecond() * 24f;
                }
            }
            if (!vehicle.IsAwake) {
                acInteractable.InteractionEnabled = false;
                if (isAcOn) {
                    toggleAc();
                }
            } else {
                acInteractable.InteractionEnabled = true;
            }

            //TODO: Interpolate
            m_zoneTemperature = getTargetTemperature();
        }

        //Base temp decreases from 20 degrees at half the difference from the enviro temp
        //Maximum difference between the base temp and enviro temp is 7 degrees
        //Base temp can't be colder than the enviro temp
        //AC and Stove affects the offset that is added to the base temp
        private float getTargetTemperature() {
            float baseTemperature = Mathf.Clamp(20 - ((20 - EnviroTemperature) / 2), EnviroTemperature, EnviroTemperature + 7);
            return baseTemperature + tempOffset;
        }

        public void toggleAc() {
            if (!isAcOn && !vehicle.IsAwake) {
                return;
            }
            isAcOn = !isAcOn;
        }
        public void toggleStove() {
            if (!isStoveOn && resources.propaneLeft <= 0) {
                return;
            }
            isStoveOn = !isStoveOn;
            if (stoveTempEffector != null) {
                stoveTempEffector.SetActive(isStoveOn);
            }
        }
    }
}
