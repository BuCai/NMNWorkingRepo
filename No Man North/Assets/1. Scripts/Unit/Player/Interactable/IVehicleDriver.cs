using System.Collections;
using System.Collections.Generic;
using NWH.VehiclePhysics2;
using UnityEngine;

namespace SurvivalTemplatePro {
    public interface IVehicleDriver {
        Transform DriverSeatTransform { get; }
        Transform DogSeatTransform { get; }
        Transform HitchhikerSeatTransform { get; }
        GameObject DriverCamera { get; }
        VehicleController VehicleController { get; }
        SkinnedMeshRenderer DriverMesh { get; }
        bool IsPassenger { get; }

    }
}