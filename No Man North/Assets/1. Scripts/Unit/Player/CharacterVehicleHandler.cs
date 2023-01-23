using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using NWH.VehiclePhysics2;
using SurvivalTemplatePro;
using SurvivalTemplatePro.MovementSystem;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

namespace SurvivalTemplatePro {
    public class CharacterVehicleHandler : CharacterBehaviour, IVehicleHandler, ISaveableComponent {
        public Transform DriverSeatTransform => m_driverSeatTransform;
        public Transform DogSeatTransform => m_dogSeatTransform;
        public Transform HitchhikerSeatTransform => m_hitchhikerSeatTransform;
        public GameObject DriverCamera => m_driverCamera;
        public VehicleController VehicleController => m_vehicleController;
        public bool IsDriving => m_isDriving;
        public bool IsPassenger => m_isPassenger;
        private bool m_enabled = false;

        private Transform m_driverSeatTransform;
        private Transform m_dogSeatTransform;
        private Transform m_hitchhikerSeatTransform;
        private IVehicleDriver m_driver;
        private bool m_isDriving;
        private bool m_isPassenger;
        private GameObject m_driverCamera;
        private Camera m_driverCameraComponent;
        private VehicleController m_vehicleController;
        private SkinnedMeshRenderer m_driverMesh;
        private UnityAction OnPostViewUpdate;

        [SerializeField] private InputActionReference m_getOutAction;

        [SerializeField] private GameObject m_PlayerCamera;
        [SerializeField] private GameObject m_PlayerPrefab;

        [SerializeField] private GameObject breathParticleObj;
        [SerializeField] private Vector3 breathParticleOffset = new Vector3(0, -0.05f, 0.1f);

        [Space]
        [Title("First Person Driver Camera")]
        [SerializeField]
        private InputActionReference m_lookInput;

        [SerializeField] private float m_Sensitivity;
        [SerializeField] private bool m_invertY;
        [SerializeField] private Vector2 m_lookLimitsX = new Vector2(-60, 60);
        [SerializeField] private Vector2 m_lookLimitsY = new Vector2(-90, 90);
        [SerializeField] private bool m_Raw;
        [SerializeField, Range(0, 20)] private int m_SmoothSteps = 10;
        [SerializeField, Range(0f, 1f)] private float m_SmoothWeight = 0.4f;


        private Vector2 m_ViewAngle;
        private Vector2 m_CurrentInput;

        private float m_CurrentSensitivity;
        private const float m_SensitivityMod = 1f;
        private Vector2 m_CurrentMouseLook;
        private Vector2 m_SmoothMove;
        private readonly List<Vector2> m_SmoothBuffer = new List<Vector2>();

        private Vector2 m_CurrentAdditiveLook;
        private Vector2 m_CurrentAdditiveMovementVelocity;
        private float m_AdditiveLookDuration;

        public event UnityAction onPostViewUpdate;

        private Transform exitPoint;

        private void OnEnable() {
            //m_getOutAction.action.started += OnGetOutStart;
        }

        private void OnDisable() {
            //m_getOutAction.action.started -= OnGetOutStart;
        }

        public Vector2 GetInput() {
            Vector2 input = m_lookInput.action.ReadValue<Vector2>() / 10;
            input.ReverseVector();

            return input;
        }

        // NOTE: Current version of this function assumes that a player can not start driving a different vehicle without exiting the current one
        public void Drive(IVehicleDriver vehicleDriver) {
            /*
            This needs to be disabled so seats can be switched without exiting the vehicle
            if (IsDriving)
                return;
            */

            m_isDriving = true;
            m_enabled = true;
            m_driver = vehicleDriver;
            m_isPassenger = m_driver.IsPassenger;
            m_driverSeatTransform = m_driver.DriverSeatTransform;
            if (m_driverMesh != null) {
                m_driverMesh.enabled = false;
            }
            m_driverMesh = m_driver.DriverMesh;
            if (m_driverCamera != null) {
                m_driverCamera.SetActive(false);
            }

            m_driverCamera = m_driver.DriverCamera;
            if (breathParticleObj != null) {
                breathParticleObj.transform.SetParent(m_driverCamera.transform);
                breathParticleObj.transform.localPosition = breathParticleOffset;
                breathParticleObj.transform.localEulerAngles = Vector3.zero;
            }

            Character.transform.SetParent(m_driverSeatTransform);
            Character.transform.SetPositionAndRotation(m_driverSeatTransform.position, m_driverSeatTransform.rotation);
            foreach (Collider col in Character.Colliders) {
                col.enabled = false;
            }

            m_vehicleController = m_driver.VehicleController;
            exitPoint = Character.transform;
            if (!m_isPassenger && m_vehicleController.IsAwake) {
                m_vehicleController.Sleep();
            }

            var companionHandler = Character.GetModule<IPlayerCompanionHandler>();
            if (companionHandler != null) {
                var dog = companionHandler.DogCompanion;
                if (dog != null) {
                    m_dogSeatTransform = m_driver.DogSeatTransform;
                    dog.GetInTheVan(m_dogSeatTransform);
                }

                var hitchhiker = companionHandler.HitchhikerCompanion;
                if (hitchhiker != null) {
                    m_hitchhikerSeatTransform = m_driver.HitchhikerSeatTransform;
                    hitchhiker.GetInTheVan(m_hitchhikerSeatTransform);
                }
            }

            SetModules(false);
            SetLookInput(GetInput);
        }

        public void ToggleEngine() {
            if (!m_isDriving || m_isPassenger) {
                return;
            }

            if (m_vehicleController.IsAwake) {
                m_vehicleController.Sleep();
            } else {
                m_vehicleController.Wake();
                m_vehicleController.powertrain.engine.Start();
            }
        }

        public void SetExitPoint(Transform position) {
            exitPoint = position;
        }

        public void Stop(bool exitOutside) {
            if (!IsDriving)
                return;

            SetModules(true);
            m_isDriving = false;
            m_enabled = false;
            if (m_vehicleController.IsAwake) {
                m_vehicleController.Sleep();
            }

            m_isPassenger = false;

            // Nullify everything just in case
            m_vehicleController = null;
            m_driver = null;
            m_driverSeatTransform = null;
            m_driverCamera = null;
            SetLookInput(null);

            // Reset the character transform and teleport next to the door.
            Character.transform.SetPositionAndRotation(exitPoint.position, exitPoint.rotation);
            foreach (Collider col in Character.Colliders) {
                col.enabled = false;
            }

            Character.transform.SetParent(null);
            Character.GetModule(out ICharacterMotor motor);
            motor.Teleport(exitPoint.position, exitPoint.rotation);

            if (exitOutside)
                CompanionsExitVan();
        }

        public void CompanionsExitVan() {
            var companionHandler = Character.GetModule<IPlayerCompanionHandler>();
            if (companionHandler != null) {
                var dog = companionHandler.DogCompanion;
                if (dog != null) {
                    dog.GetOutOfTheVan();
                }

                var hitchhiker = companionHandler.HitchhikerCompanion;
                if (hitchhiker != null) {
                    hitchhiker.GetOutOfTheVan();
                }
            }
        }

        private void SetModules(bool enable) {
            //Driving mesh
            m_driverMesh.enabled = !enable;

            // Swap driver/player camera
            m_driverCamera.SetActive(!enable);
            m_PlayerCamera.SetActive(enable);

            // Disable/enable movement modules
            // Motion
            Character.GetModule(out IMotionController motionController);
            motionController.gameObject.SetActive(enable);

            // Motor
            Character.GetModule(out ICharacterMotor motor);
            motor.gameObject.GetComponent<CharacterControllerMotor>().enabled = enable;

            // Camera
            Character.GetModule(out ICameraMotionHandler cameraHandler);
            cameraHandler.gameObject.SetActive(enable);

            //Interactables
            InteractionHandler interactionHandler = transform.parent.GetComponentInChildren<InteractionHandler>();
            interactionHandler.m_View = enable ? m_PlayerCamera.transform : m_driverCamera.transform;

            // Player visibility
            //Disabled, handled by STPCameraSwitcher
            //m_PlayerPrefab.SetActive(enable);
        }

        /*ENGINE START STOP BUTTON HAS BEEN UNASSIGNED, ENTERING/LEAVING WILL BE DONE BY INTERACTABLES
        private void OnGetOutStart(InputAction.CallbackContext context) {
            //DEBUG DEBUG DEBUG
            Debug.LogWarning("Get Out Command Blocked");
            return;
            

            Stop();
        }*/

        #region Look Input

        private void LateUpdate() {
            if (!m_enabled)
                return;
            m_CurrentInput = Vector2.zero;
            float deltaTime = Time.deltaTime;

            if (m_CurrentInput != null)
                m_CurrentInput = m_lookInputCallback();

            m_CurrentSensitivity = GetTargetSensitivity(m_CurrentSensitivity, deltaTime * 8.0f);
            MoveView(m_CurrentInput, deltaTime);
            UpdateAdditiveLook();

            onPostViewUpdate?.Invoke();
        }

        private void MoveView(Vector2 lookInput, float deltaTime) {
            if (!m_Raw) {
                CalculateSmoothLookInput(lookInput, deltaTime);

                m_ViewAngle.x += m_CurrentMouseLook.x * m_CurrentSensitivity * (m_invertY ? 1f : -1f);
                m_ViewAngle.y += m_CurrentMouseLook.y * m_CurrentSensitivity;

                m_ViewAngle.x = ClampAngle(m_ViewAngle.x, m_lookLimitsX.x, m_lookLimitsX.y);
                m_ViewAngle.y = ClampAngle(m_ViewAngle.y, m_lookLimitsY.x, m_lookLimitsY.y);
            } else {
                m_ViewAngle.x += lookInput.x * m_CurrentSensitivity * (m_invertY ? 1f : -1f);
                m_ViewAngle.y += lookInput.y * m_CurrentSensitivity;

                m_ViewAngle.x = ClampAngle(m_ViewAngle.x, m_lookLimitsX.x, m_lookLimitsX.y);
                m_ViewAngle.y = ClampAngle(m_ViewAngle.y, m_lookLimitsY.x, m_lookLimitsY.y);
            }

            m_driverCamera.transform.localRotation = Quaternion.Euler(m_ViewAngle.x, m_ViewAngle.y, 0f);
        }

        private static float ClampAngle(float angle, float min, float max) {
            if (angle > 360f)
                angle -= 360f;
            else if (angle < -360f)
                angle += 360f;

            return Mathf.Clamp(angle, min, max);
        }

        private void CalculateSmoothLookInput(Vector2 lookInput, float deltaTime) {
            if (deltaTime == 0f)
                return;

            m_SmoothMove = new Vector2(lookInput.x, lookInput.y);

            m_SmoothSteps = Mathf.Clamp(m_SmoothSteps, 1, 20);
            m_SmoothWeight = Mathf.Clamp01(m_SmoothWeight);

            while (m_SmoothBuffer.Count > m_SmoothSteps)
                m_SmoothBuffer.RemoveAt(0);

            m_SmoothBuffer.Add(m_SmoothMove);

            var weight = 1.0f;
            Vector2 average = Vector2.zero;
            var averageTotal = 0.0f;

            for (var i = m_SmoothBuffer.Count - 1; i > 0; i--) {
                average += m_SmoothBuffer[i] * weight;
                averageTotal += weight;
                weight *= m_SmoothWeight / (deltaTime * 60f);
            }

            averageTotal = Mathf.Max(1f, averageTotal);
            m_CurrentMouseLook = average / averageTotal;
        }

        private float GetTargetSensitivity(float currentSens, float delta) {
            var targetSensitivity = m_Sensitivity * m_SensitivityMod;
            targetSensitivity *= m_driverCameraComponent != null ? m_driverCameraComponent.fieldOfView / 90.0f : 1.0f;

            return Mathf.Lerp(currentSens, targetSensitivity, delta);
        }

        private void UpdateAdditiveLook() {
            m_CurrentAdditiveLook = Vector2.SmoothDamp(m_CurrentAdditiveLook, Vector2.zero,
                ref m_CurrentAdditiveMovementVelocity, m_AdditiveLookDuration);

            if (m_CurrentAdditiveLook != Vector2.zero)
                m_ViewAngle += m_CurrentAdditiveLook;
        }

        private LookInputCallback m_lookInputCallback;
        private void SetLookInput(LookInputCallback lookInputCallback) => m_lookInputCallback = lookInputCallback;

        #endregion

        #region Save & Load

        public void LoadMembers(object[] members) {
            m_driverSeatTransform = (Transform)members[0];
        }

        public object[] SaveMembers() {
            return new object[]
            {
                m_driverSeatTransform
            };
        }

        #endregion
    }
}