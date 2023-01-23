using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    public interface ICharacterMotor : ICharacterModule
    {
        bool IsGrounded { get; }
        float LastGroundedChangeTime { get; }
        float Gravity { get; }
        float VelocityMod { get; set; }

        Vector3 Velocity { get; }
        Vector3 SimulatedVelocity { get; }
        Vector3 GroundNormal { get; }
        float GroundSurfaceAngle { get; }
        CollisionFlags CollisionFlags { get; }

        float DefaultHeight { get; }
        float SlopeLimit { get; }
        float Height { get; }
        float Radius { get; }


        event UnityAction onTeleport;
        event UnityAction<bool> onGroundedStateChanged;
        event UnityAction<float> onFallImpact;
        event UnityAction<float> onHeightChanged;

        bool TrySetHeight(float height);
        bool CanSetHeight(float height);
        void SetHeight(float height);

        bool Raycast(Ray ray, float distance);
        bool Raycast(Ray ray, float distance, out RaycastHit raycastHit);
        bool SphereCast(Ray ray, float distance, float radius);

        void Teleport(Vector3 position, Quaternion rotation);

        /// <summary>
        /// A method that will be called when the character motor needs input. 
        /// </summary>
        void SetMotionInput(MotionInputCallback motionInput);
    }

    /// <summary>
    /// A delegate that will be called when the character motor needs input.
    /// </summary>
    public delegate void MotionInputCallback(ref Vector3 velocity, out bool useGravity, out bool snapToGround);
}