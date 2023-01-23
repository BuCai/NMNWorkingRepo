using UnityEngine;

namespace SurvivalTemplatePro
{
    [ExecuteInEditMode]
    public class MoveToSpawnPoint : MonoBehaviour
    {
        [SerializeField]
        private Vector3 m_Offset;


#if UNITY_EDITOR
        public void MoveToRandomPoint()
        {
            UnityEditor.Undo.RecordObject(transform, "MoveSpawnPoint");

            // Search for random spawn point.
            var spawnPoint = SpawnPointData.Default;
            var foundSpawnPoints = FindObjectsOfType<SpawnPoint>();

            if (foundSpawnPoints != null && foundSpawnPoints.Length > 0)
                spawnPoint = foundSpawnPoints.SelectRandom().GetSpawnPoint();

            transform.position = spawnPoint.Position + m_Offset;
            transform.rotation = spawnPoint.Rotation;
        }
#endif
    }
}