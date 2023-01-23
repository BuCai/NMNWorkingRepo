using UnityEngine;

namespace SurvivalTemplatePro {
    //Adjusted to work with new temperature manager
    //Make sure to set the tag of the gameobject to "TempEffector"
    [RequireComponent(typeof(SphereCollider))]
    public class TemperatureEffector : MonoBehaviour {
        //Warning: Radius calculation is not affected by the scale of the object
        public float Radius {
            get => m_Radius;
            set {
                m_Radius = value;
                m_InfluenceVolume.radius = m_Radius;
            }
        }

        //Maximum temperature offset
        public float maxTemperatureOffset = 15;

        //Multiplier
        private float m_temperatureStrength = 1;
        public float temperatureStrength {
            get => m_temperatureStrength;
            set {
                m_temperatureStrength = Mathf.Clamp01(value);
            }
        }

        private float m_Radius;
        private SphereCollider m_InfluenceVolume;


        private void Awake() {
            m_InfluenceVolume = GetComponent<SphereCollider>();
            m_InfluenceVolume.isTrigger = true;
            Radius = m_InfluenceVolume.radius;
        }
    }
}