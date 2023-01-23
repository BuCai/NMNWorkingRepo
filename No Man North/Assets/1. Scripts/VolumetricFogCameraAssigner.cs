using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VolumetricFogAndMist2;

//Volumetric fog manager and associated scripts do not automatically search for the main camera as it changes,
//So this script does it instead.
public class VolumetricFogCameraAssigner : MonoBehaviour {

    public VolumetricFogManager vfManager;
    public PointLightManager plManager;
    public FogVoidManager fvManager;

    private void Update() {
        if (vfManager.mainCamera != Camera.main) {
            vfManager.mainCamera = Camera.main;
            plManager.trackingCenter = Camera.main.transform;
            fvManager.trackingCenter = Camera.main.transform;
        }

        //TEMPORARY WORKAROUND FROM BUG
        if (vfManager.sun != null || vfManager.moon != null) {
            vfManager.sun = null;
            vfManager.moon = null;
        }
    }
}
