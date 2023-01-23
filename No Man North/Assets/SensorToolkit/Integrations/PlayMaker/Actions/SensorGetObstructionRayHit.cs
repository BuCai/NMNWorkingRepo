﻿#if PLAYMAKER

using System.Collections;
using HutongGames.PlayMaker;

namespace Micosmo.SensorToolkit.PlayMaker {

    [ActionCategory("SensorToolkit")]
    [Tooltip("For a valid raycasting sensor this will retrieve the ray intersection details where it's obstructed. Works with the Ray Sensor, Arc Sensor, NavMesh Sensor and their 2D analogues.")]
    public class SensorGetObstructionRayHit : FsmStateAction {

        [RequiredField]
        [ObjectType(typeof(BasePulsableSensor))]
        public FsmObject sensor;

        [ActionSection("Inputs")]

        [Tooltip("Run each frame?")]
        public bool everyFrame;

        [ActionSection("Outputs")]

        [UIHint(UIHint.Variable)]
        [Tooltip("Stores the point where the ray is obstructed")]
        public FsmVector3 storePoint;

        [UIHint(UIHint.Variable)]
        [Tooltip("Stores the normal vector at the interesection point")]
        public FsmVector3 storeNormal;

        [UIHint(UIHint.Variable)]
        [Tooltip("Stores the distance travelled by the ray before it's obstructed")]
        public FsmFloat storeDistance;

        [UIHint(UIHint.Variable)]
        [Tooltip("Stores the fraction of the ray's length travelled before reaching the obstruction")]
        public FsmFloat storeDistanceFraction;

        [ActionSection("Events")]

        [Tooltip("Invoked if the sensor is obstructed")]
        public FsmEvent isObstructedEvent;

        [Tooltip("Invoked if the sensor is not obstructed")]
        public FsmEvent isNotObstructedEvent;

        IRayCastingSensor _sensor => sensor.Value as IRayCastingSensor;

        public override void Reset() {
            OwnerDefaultSensor();
            storePoint = null;
            storeNormal = null;
            storeDistance = null;
            storeDistanceFraction = null;
            isObstructedEvent = null;
            isNotObstructedEvent = null;
            everyFrame = false;
        }

        void OwnerDefaultSensor() {
            if (Owner != null) {
                sensor = new FsmObject() { Value = Owner.GetComponent(typeof(IRayCastingSensor)) };
            } else {
                sensor = null;
            }
        }

        public override string ErrorCheck() {
            if (sensor.Value != null && _sensor == null) {
                return "'Sensor' is not Ray Casting. Must implement IRayCastingSensor";
            }
            return base.ErrorCheck();
        }

        public override void OnEnter() {
            DoAction();
            if (!everyFrame) {
                Finish();
            }
        }

        public override void OnUpdate() {
            DoAction();
        }

        void DoAction() {
            if (_sensor == null) {
                return;
            }
            var hit = _sensor.GetObstructionRayHit();
            storePoint.Value = hit.Point;
            storeNormal.Value = hit.Normal;
            storeDistance.Value = hit.Distance;
            storeDistanceFraction.Value = hit.DistanceFraction;
            if (hit.Equals(RayHit.None)) {
                Fsm.Event(isNotObstructedEvent);
            } else {
                Fsm.Event(isObstructedEvent);
            }
        }
    }

}

#endif