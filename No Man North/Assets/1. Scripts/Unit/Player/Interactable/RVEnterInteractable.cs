using NWH.VehiclePhysics2;
using SurvivalTemplatePro.MovementSystem;
using UnityEngine;
using System.Threading.Tasks;

namespace SurvivalTemplatePro {
    public class RVEnterInteractable : Interactable, IVehicleDriver {
        public Transform DriverSeatTransform => m_driverSeatTransform;
        public Transform DogSeatTransform => m_dogSeatTransform;
        public Transform HitchhikerSeatTransform => m_hitchhikerSeatTransform;
        public GameObject DriverCamera => m_camera;
        public VehicleController VehicleController => m_vehicleController;
        public SkinnedMeshRenderer DriverMesh => m_driverMesh;
        public bool IsPassenger => m_isPassenger;

        [SerializeField] private Transform m_driverSeatTransform;
        [SerializeField] private Transform m_dogSeatTransform;
        [SerializeField] private Transform m_hitchhikerSeatTransform;
        [SerializeField] private GameObject m_camera;
        [SerializeField] private VehicleController m_vehicleController;
        [SerializeField] private SkinnedMeshRenderer m_driverMesh;
        [SerializeField] private bool m_isPassenger;
        [SerializeField] private bool useTransition = false;
        [SerializeField] private bool animate = false;
        [SerializeField] private Animator animator;
        [SerializeField] private string parameterName;

        public override void OnInteract(ICharacter character) {
            if (character.TryGetModule(out IVehicleHandler vehicleHandler)) {
                base.OnInteract(character);
                Action(character, vehicleHandler);
            }
        }


        private async void Action(ICharacter character, IVehicleHandler vehicleHandler) {
            if (useTransition) {
                UISystem.FadeScreenUI.Instance.Fade(true, 0f, 2f);
                if (animate) {
                    animator.SetBool(parameterName, true);
                }

                await Task.Delay(500);
            }

            character.gameObject.GetComponentInChildren<STPCameraSwitcher>()
                .SwitchCamState(STPCameraSwitcher.CamState.First);
            vehicleHandler.Drive(this);
            if (useTransition) {
                UISystem.FadeScreenUI.Instance.Fade(false, 0f, 2f);
                if (animate) {
                    animator.SetBool(parameterName, false);
                }
            }
        }

        private void Awake() {
            if (m_vehicleController == null) {
                Debug.LogError("Vehicle controller not assigned");
            }

            if (animate && (animator == null || parameterName == "")) {
                Debug.LogError("Animation parameters null");
            }
        }

        //Uninteractable past 15kmh
        private void FixedUpdate() {
            if (m_vehicleController == null) {
                return;
            }

            if (m_vehicleController.Speed * 3.6f > 15f) {
                InteractionEnabled = false;
            } else {
                InteractionEnabled = true;
            }
        }
    }
}