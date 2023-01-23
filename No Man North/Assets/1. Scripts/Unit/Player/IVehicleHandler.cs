using System.Collections;
using System.Collections.Generic;
using NWH.VehiclePhysics2;
using UnityEngine;

namespace SurvivalTemplatePro {
    public interface IVehicleHandler : ICharacterModule {
        bool IsDriving { get; }
        bool IsPassenger { get; }

        Transform DriverSeatTransform { get; }
        Transform DogSeatTransform { get; }
        Transform HitchhikerSeatTransform { get; }
        GameObject DriverCamera { get; }

        VehicleController VehicleController { get; }

        void Drive(IVehicleDriver driver);
        void Stop(bool exitOutside);
        void SetExitPoint(Transform position);
        void ToggleEngine();
        void CompanionsExitVan();
    }
}