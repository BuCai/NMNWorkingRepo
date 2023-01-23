using SurvivalTemplatePro.CameraSystem;
using UnityEngine;

namespace SurvivalTemplatePro
{
    public interface ICameraMotionHandler : ICharacterModule
    {
        void AddRotationForce(SpringForce force);
        void AddRotationForce(Vector3 recoilForce, int distribution = 1);

        void SetCustomForceSpringSettings(Spring.Settings settings); 
        void ClearCustomForceSpringSettings();

        void SetCustomHeadbob(CameraBob headbob);

        void SetCustomState(CameraMotionState state);
        void ClearCustomState();
    }
}