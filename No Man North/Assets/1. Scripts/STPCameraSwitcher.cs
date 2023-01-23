using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using MLC.NoManNorth.Eric;

//Handles camera offset and state switching post STP, only affects the character camera not the driver camera
//Currently does not work with old GameStateManager or Cinemachine
public class STPCameraSwitcher : MonoBehaviour {

    public enum CamState {
        Third,
        First
    }

    [SerializeField] private Camera mainCamera;
    [SerializeField] private GameObject breathParticleObj;
    [SerializeField] private Transform tpsCamHolder;
    [SerializeField] private Transform tpsBreathHolder;
    [SerializeField] private Transform fpsCamHolder;
    [SerializeField] private Transform fpsBreathHolder;
    [SerializeField] private GameObject model;
    private NoManNorthThirdPersonCharacterController camController; //Old script still being used
    public bool disableModelOnFps = true;

    [SerializeField] private bool fpsOnlyMode = false;

    public UnityEvent<CamState> camStateChanged = new UnityEvent<CamState>();

    private void Start() {
        camController = NoManNorthThirdPersonCharacterController.Instance;
        if (fpsOnlyMode) {
            SwitchCamState(CamState.First);
        } else {
            SwitchCamState(CamState.Third);
        }
    }

    //Switches camera to the desired camera state
    public void SwitchCamState(CamState state) {
        switch (state) {
            case CamState.Third:
                if (fpsOnlyMode) {
                    return;
                }
                mainCamera.transform.SetParent(tpsCamHolder);
                breathParticleObj.transform.SetParent(tpsBreathHolder);
                model.SetActive(true);
                camController._rotationMode = EasyCharacterMovement.RotationMode.OrientToMovement;
                break;
            case CamState.First:
                mainCamera.transform.SetParent(fpsCamHolder);
                breathParticleObj.transform.SetParent(fpsBreathHolder);
                if (disableModelOnFps) {
                    model.SetActive(false);
                } else {
                    camController._rotationMode = EasyCharacterMovement.RotationMode.OrientToCameraViewDirection;
                }
                break;
        }
        mainCamera.transform.localPosition = Vector3.zero;
        mainCamera.transform.localEulerAngles = Vector3.zero;
        breathParticleObj.transform.localPosition = Vector3.zero;
        breathParticleObj.transform.localEulerAngles = Vector3.zero;
        camStateChanged.Invoke(state);
    }
}
