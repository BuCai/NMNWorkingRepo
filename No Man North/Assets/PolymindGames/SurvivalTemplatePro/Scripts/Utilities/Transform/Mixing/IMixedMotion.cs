using UnityEngine;

namespace SurvivalTemplatePro
{
    public interface IMixedMotion
    {
        Vector3 Position { get; }
        Quaternion Rotation { get; }

        void FixedUpdateTransform(float deltaTime);
        void UpdateTransform(float deltaTime);
    }
}