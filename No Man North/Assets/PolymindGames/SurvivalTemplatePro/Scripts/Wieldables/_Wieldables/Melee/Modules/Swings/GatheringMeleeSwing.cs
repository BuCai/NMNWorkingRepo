#if SURVIVAL_TEMPLATE_PRO
using SurvivalTemplatePro.ResourceGathering;
#endif

using SurvivalTemplatePro.Surfaces;
using UnityEngine;
namespace SurvivalTemplatePro.WieldableSystem

{
	[AddComponentMenu("Wieldables/Melee/Gathering Swing")]
	public class GatheringMeleeSwing : BasicMeleeSwing
	{
		[Title("Gathering Swing")]

#if SURVIVAL_TEMPLATE_PRO
		[SerializeField, ReorderableList(HasLabels = false)]
		private GatherableDefinition[] m_ValidGatherables;
#endif

		[SerializeField, Range(0f, 10f)]
		private float m_MaxGatherDistance = 0.35f;


#if SURVIVAL_TEMPLATE_PRO
		public override bool CanSwing()
		{
			if (SphereCast(Wieldable.Character, GetUseRay(), m_HitRadius, m_HitDistance, out RaycastHit hitInfo))
			{
				IGatherable gatherable = hitInfo.collider.GetComponent<IGatherable>();

				bool canSwing = gatherable != null &&
								IsValidGatherable(gatherable) &&
								CheckDistanceWithGatherable(gatherable);

				return canSwing;
			}

			return false;
		}

		protected override RaycastHit DoHitCheck(ICharacter user, Ray ray)
		{
			if (SphereCast(user, ray, m_HitRadius, m_HitDistance, out RaycastHit hitInfo))
			{
				IGatherable gatherable = hitInfo.collider.GetComponent<IGatherable>();

				bool isValidGatherable = gatherable != null &&
										 IsValidGatherable(gatherable) &&
										 CheckDistanceWithGatherable(gatherable);

				if (isValidGatherable)
				{
					DamageInfo treeDamage = new DamageInfo(m_Damage, ray.origin + ray.direction * 0.5f + Vector3.Cross(Vector3.up, ray.direction) * 0.25f, ray.direction, m_ImpactForce);
					gatherable.Damage(treeDamage);

					// Spawn some effects for the gather swing impact
					SurfaceManager.SpawnEffect(hitInfo, SurfaceEffects.Stab, 1f);

					// TODO: Spawn custom effect
					// Vector3 chopImpactPos = GetChopPoint(m_ProximityTree) + Vector3.Cross(Vector3.up, ray.direction) * 0.15f;
					// SurfaceManager.SpawnEffect(chopImpactPos, chopImpactPos, Quaternion.LookRotation(Vector3.Cross(hitInfo.normal, Vector3.up)));

					// Hit Audio
					Wieldable.AudioPlayer.PlaySound(m_HitAudio);

					ConsumeItemDurability(m_DurabilityRemove);

					// Events
					Wieldable.EventHandler.TriggerAction(m_SwingHitEvent);
				}
			}

			return hitInfo;
		}

		private bool IsValidGatherable(IGatherable gatherable)
		{
			GatherableDefinition gatherDefinition = gatherable.Definition;

			for (int i = 0; i < m_ValidGatherables.Length; i++)
			{
				if (gatherDefinition == m_ValidGatherables[i])
					return true;
			}

			return false;
		}

		private bool CheckDistanceWithGatherable(IGatherable gatherable)
		{
			if (gatherable != null)
			{
				var tree = gatherable.transform;
				Ray useRay = GetUseRay();

				return Mathf.Abs((useRay.origin + useRay.direction).y - (tree.position + gatherable.GatherOffset).y) < m_MaxGatherDistance;
			}

			return false;
		}
#endif
	}
}