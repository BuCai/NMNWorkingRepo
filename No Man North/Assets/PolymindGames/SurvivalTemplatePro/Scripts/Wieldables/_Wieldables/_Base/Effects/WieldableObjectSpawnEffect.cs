using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.WieldableSystem
{
    public class WieldableObjectSpawnEffect : WieldableEffectBehaviour
	{
		private enum RotationMode { Local, View, Random }
		private enum RootFollowMode { OnSpawn, Continuously }

		[SerializeField]
		private GameObject m_Prefab;

		[Title("Spawn Settings")]

		[SerializeField, Range(0f, 5f)]
		private float m_SpawnDelay = 1f;

		[SerializeField]
		private Transform m_SpawnRoot;

		[SerializeField]
		private RootFollowMode m_RootFollowMode = RootFollowMode.OnSpawn;

		[SerializeField]
		private RotationMode m_RotationMode = RotationMode.View;

		[SerializeField]
		private Vector3 m_PositionOffset;

		[SerializeField]
		private Vector3 m_RotationOffset;

		[Title("Pooling")]

		[SerializeField, Range(1f, 60f)]
		private float m_RecycleDelay = 2f;

		[SerializeField, Range(1, 50)]
		private int m_MinPoolSize = 2;

		[SerializeField, Range(1, 100)]
		private int m_MaxPoolSize = 6;

		[Space]

		[SerializeField]
		private UnityEvent m_OnSpawn;

		protected ICharacter m_Character;

		private readonly List<float> m_EffectsToSpawn = new List<float>();


		public override void DoEffect(ICharacter character)
		{
			if (!enabled || m_Prefab == null)
				return;

			if (m_Character != character)
				m_Character = character;

			m_EffectsToSpawn.Add(Time.time + m_SpawnDelay);
		}

		protected virtual PoolableObject SpawnEffect()
		{
			UpdateTransform();

			Quaternion spawnRotation;

			if (m_RotationMode == RotationMode.View)
				spawnRotation = m_Character.ViewTransform.rotation;
			else if (m_RotationMode == RotationMode.Random)
				spawnRotation = Random.rotation;
			else
				spawnRotation = transform.rotation;

			m_OnSpawn?.Invoke();

			return PoolingManager.Instance.GetObject(m_Prefab, gameObject.transform.position, spawnRotation, m_RootFollowMode == RootFollowMode.Continuously ? transform : null);
		}

		private void Awake()
		{
			if (m_Prefab != null)
				PoolingManager.Instance.CreatePool(m_Prefab, m_MinPoolSize, m_MaxPoolSize, true, m_Prefab.GetInstanceID().ToString(), m_RecycleDelay);
		}

        private void LateUpdate()
        {
			if (!enabled || m_SpawnRoot == null)
				return;

			UpdateEffectSpawn();

			if (m_RootFollowMode == RootFollowMode.Continuously)
				UpdateTransform();
		}

		private void UpdateEffectSpawn()
		{
			if (m_EffectsToSpawn.Count == 0)
				return;

			int i = 0;

			float currentTime = Time.time;

			while (true)
			{
				if (currentTime > m_EffectsToSpawn[i])
				{
					SpawnEffect();
					m_EffectsToSpawn.RemoveAt(i);
				}
				else
					i++;

				if (i >= m_EffectsToSpawn.Count)
					break;
			}
		}

		private void UpdateTransform() 
		{
			var position = m_SpawnRoot.position + m_SpawnRoot.TransformVector(m_PositionOffset);
			var rotation = m_SpawnRoot.rotation * Quaternion.Euler(m_RotationOffset);
			transform.SetPositionAndRotation(position, rotation);
		}

#if UNITY_EDITOR
		private void OnDrawGizmosSelected()
        {
			if (m_SpawnRoot == null)
				return;

			UpdateTransform();
			Gizmos.DrawSphere(transform.position, 0.05f);
        }
#endif
	}
}
