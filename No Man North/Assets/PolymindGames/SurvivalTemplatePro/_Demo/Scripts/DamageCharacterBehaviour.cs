using UnityEngine;

namespace SurvivalTemplatePro.Demo
{
    public class DamageCharacterBehaviour : MonoBehaviour
    {
        [SerializeField, MinMaxSlider(0f, 100f)]
        private Vector2 m_Damage;

        [SerializeField, Range(0f, 100f)]
        private float m_HitImpulse = 5f;


        public void DamageCharacter(ICharacter character)
        {
            DamageInfo dmgInfo = new DamageInfo(m_Damage.GetRandomFloat(), DamageType.Cut, transform.position, transform.position - character.transform.position, m_HitImpulse, null);
            character.HealthManager.ReceiveDamage(dmgInfo);
        }

        public void DamageCollider(Collider collider)
        {
            if (collider.TryGetComponent(out ICharacter character))
                DamageCharacter(character);
        }
    }
}
