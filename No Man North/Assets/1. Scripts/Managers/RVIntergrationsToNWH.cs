using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NWH;
using NWH.VehiclePhysics2;
using static NWH.VehiclePhysics2.Modules.VehicleModule;
using NWH.VehiclePhysics2.Modules.Fuel;
using SurvivalTemplatePro;
using SurvivalTemplatePro.InventorySystem;
using Enviro;

namespace MLC.NoManNorth.Eric {
    public class RVIntergrationsToNWH : MonoBehaviour {
        #region Variables

        [SerializeField] private VehicleController vehicle;

        [SerializeField] private EventChannelFloat OnRvGasPercentageChange;

        [SerializeField] private EventChannel OnWeatherChange;

        [SerializeField] private FuelModuleWrapper fuelModule;

        [SerializeField] private RVDashboard dashboard;
        [SerializeField] private Animator drivingModelAnimator;
        private float startingEnginePower;
        #endregion

        #region Unity Methods

        private void Start() {
            vehicle.onWake.AddListener(OnRvAwake);
            vehicle.onSleep.AddListener(OnRvSleep);
            startingEnginePower = vehicle.powertrain.engine.maxPower;
            OnWeatherChange.OnEvent += OnWeatherChange_OnEvent;
            drivingModelAnimator.SetBool("driving", true);
        }

        private void OnDestroy() {
            OnWeatherChange.OnEvent -= OnWeatherChange_OnEvent;
        }

        private void Update() {
            OnRvGasPercentageChange?.RaiseEvent((fuelModule.GetModule() as FuelModule).amount / (fuelModule.GetModule() as FuelModule).capacity);
            UpdateDashboard();
        }

        private void OnRvAwake() {
            //drivingModelAnimator.SetBool("driving", true);
        }
        private void OnRvSleep() {
            //drivingModelAnimator.SetBool("driving", false);
        }

        #endregion

        #region Methods

        private void OnWeatherChange_OnEvent() {

            if (EnviroManager.instance == null || EnviroManager.instance.Weather.currentZone.currentWeatherType == null) return;

        }

        public float FillUpGas(float amountInCan) {
            FuelModule fm = (fuelModule.GetModule() as FuelModule);
            float useAmount = Mathf.Min(amountInCan, fm.capacity - fm.amount);
            fm.amount += useAmount;
            return useAmount;
        }

        //Assumes 1 unity unit is 1 meter
        private void UpdateDashboard() {
            dashboard.UpdateDials(vehicle.Speed * 3.6f, vehicle.powertrain.engine.RPM, ((fuelModule.GetModule() as FuelModule).amount / (fuelModule.GetModule() as FuelModule).capacity) * 100, vehicle.steering.Angle);
            float baseTurnAmount = 2 * (vehicle.steering.Angle / vehicle.steering.maximumSteerAngle);
            if (baseTurnAmount >= 0) {
                drivingModelAnimator.SetFloat("turnLeftNormalized", 0);
                drivingModelAnimator.SetFloat("turnLeft2Normalized", 0);
                drivingModelAnimator.SetFloat("turnRightNormalized", Mathf.Clamp01(baseTurnAmount));
                drivingModelAnimator.SetFloat("turnRight2Normalized", Mathf.Clamp01(baseTurnAmount - 1));
            } else {
                drivingModelAnimator.SetFloat("turnRightNormalized", 0);
                drivingModelAnimator.SetFloat("turnRight2Normalized", 0);
                drivingModelAnimator.SetFloat("turnLeftNormalized", Mathf.Clamp01(-baseTurnAmount));
                drivingModelAnimator.SetFloat("turnLeft2Normalized", Mathf.Clamp01((-baseTurnAmount) - 1));
            }
        }

        #endregion
    }
}