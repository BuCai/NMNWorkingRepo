using UnityEngine;

namespace SurvivalTemplatePro.Demo
{
    public class TeleportPlayerBehaviour : MonoBehaviour
    {
        [SerializeField, ReorderableList(elementLabel:"point")]
        private Transform[] m_TeleportPoints;


        public void TeleportPlayer(ICharacter character)
        {
            if (character.TryGetModule(out ICharacterMotor motor))
            {
                Transform teleportPoint = m_TeleportPoints.SelectRandom();
                motor.Teleport(teleportPoint.position, teleportPoint.rotation);
            }
        }

        public void TeleportCollider(Collider collider)
        {
            if (collider.TryGetComponent(out ICharacter character))
                TeleportPlayer(character);
        }
    }
}