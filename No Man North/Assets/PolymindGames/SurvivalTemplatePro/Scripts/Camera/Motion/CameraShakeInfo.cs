using UnityEngine;

namespace SurvivalTemplatePro
{
    [CreateAssetMenu(fileName = "Camera Shake Info", menuName = "Survival Template Pro/Camera/Camera Shake Info")]
    public class CameraShakeInfo : ScriptableObject
    {
        public ShakeSettings Settings => m_ShakeSettings;
        public float Radius => m_ShakeRadius;

        [SerializeField, Range(0f, 100f)]
        private float m_ShakeRadius = 10f;

        [SerializeField]
        private ShakeSettings m_ShakeSettings;
    }
}