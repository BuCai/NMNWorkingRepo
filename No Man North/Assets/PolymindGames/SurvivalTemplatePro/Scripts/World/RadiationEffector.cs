using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro
{
    [RequireComponent(typeof(SphereCollider))]
    public class RadiationEffector : MonoBehaviour
    {
        #region Internal
        private enum StatChangeType
        {
            IncreaseStat,
            DecreaseStat
        }
        #endregion

        public float RadiusMod { get; set; } = 1f;
        public float RadiationMod { get; set; } = 1f;

        [SerializeField]
        private SphereCollider m_InfluenceVolume;

        [Space]

        [SerializeField]
        private StatChangeType m_StatChangeType;

        [SerializeField, Range(0f, 100f)]
        private float m_RadiationStrength = 1f;

        [SerializeField, Range(0f, 100f)]
        private float m_RadiationRadius = 1f;

        private float m_Radius;
        private readonly List<ICharacter> m_CharactersInsideTrigger = new List<ICharacter>();


        private void OnTriggerEnter(Collider other)
        {
            if (other.TryGetComponent(out ICharacter character))
            {
                if (!m_CharactersInsideTrigger.Contains(character))
                    m_CharactersInsideTrigger.Add(character);
            }
        }

        private void OnTriggerStay(Collider other)
        {
            CalculateRadius();

            for (int i = 0; i < m_CharactersInsideTrigger.Count; i++)
            {
                if (m_CharactersInsideTrigger[i].TryGetModule(out IRadiationManager radiationManager))
                {
                    float distanceToCharacter = Vector3.Distance(transform.position, other.transform.position);
                    float radFactor = 1f - distanceToCharacter / m_Radius;
                    float radChange = RadiationMod * m_RadiationStrength * radFactor * Time.deltaTime;

                    radiationManager.Radiation = m_StatChangeType == StatChangeType.IncreaseStat ? radiationManager.Radiation + radChange : radiationManager.Radiation - radChange;
                }
            }
        }

        private void OnTriggerExit(Collider other)
        {
            if (other.TryGetComponent(out ICharacter character))
                m_CharactersInsideTrigger.Remove(character);
        }

        private void CalculateRadius() 
        {
            m_Radius = m_RadiationRadius * RadiusMod;
            m_InfluenceVolume.radius = m_Radius;
        }

#if UNITY_EDITOR
        private void OnDrawGizmosSelected()
        {
            var prevColor = Gizmos.color;
            Gizmos.color = new Color(1f, 1f, 1f, 0.3f) * Color.green;

            CalculateRadius();
            Gizmos.DrawSphere(transform.position, m_Radius);

            Gizmos.color = prevColor;
        }

        private void OnValidate()
        {
            m_InfluenceVolume = GetComponent<SphereCollider>();
            m_InfluenceVolume.isTrigger = true;
        }
#endif
    }
}