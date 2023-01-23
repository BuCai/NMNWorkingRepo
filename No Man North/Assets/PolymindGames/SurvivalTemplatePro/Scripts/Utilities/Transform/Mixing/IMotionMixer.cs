using UnityEngine;

namespace SurvivalTemplatePro
{
    public interface IMotionMixer
    {
        Transform TargetTransform { get; }
        Vector3 PivotPosition { get; }
        Quaternion PivotRotation { get; }

        void AddMixedMotion(IMixedMotion mixedMotion);
        void RemoveMixedMotion(IMixedMotion mixedMotion);
    }
}