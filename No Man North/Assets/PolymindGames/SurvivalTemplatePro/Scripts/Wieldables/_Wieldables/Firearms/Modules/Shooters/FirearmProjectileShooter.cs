using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Firearms/Shooters/Projectile Shooter")]
	public class FirearmProjectileShooter : FirearmShooterBehaviour
	{
        public override int AmmoPerShot => m_AmmoPerShot;

		[Space]

		[SerializeField]
		private ShaftedProjectile m_Projectile = null;

		[Space]

		[SerializeField, Range(0, 10)]
		private int m_AmmoPerShot = 1;

		[SerializeField, Range(1, 30)] 
		[Tooltip("The amount of projectiles that will be spawned in the world")]
		private int m_ProjectilesCount = 1;

		[SerializeField, Range(0f, 30f)]
		private float m_ShootSpread = 1f;

		[SerializeField, Range(0f, 10f)]
		private float m_DamageMod = 1f;

		[Space]

		[SerializeField]
		private Vector3 m_SpawnPositionOffset = Vector3.zero;

		[SerializeField]
		private Vector3 m_SpawnRotationOffset = Vector3.zero;

		[SerializeField, Range(0f, 100f)]
		private float m_SpawnVelocity = 50f;

		[SerializeField, Range(0f, 100f)]
		private float m_SpawnTorque = 0f;

		[Space]

		[SerializeField, Range(0f, 100f)]
		private float m_DurabilityRemove = 2f;

		[Title("Audio")]

		[SerializeField]
		private StandardSound m_ShootAudio;

		[SpaceArea]

		[SerializeField, LabelByChild("m_Clip"), ReorderableList(Foldable = true)]
		private DelayedSound[] m_HandlingAudio;

		[SerializeField, HideInInspector]
		private STPEventReference m_ShootEvent = new STPEventReference("On Shoot");

		[SerializeField, HideInInspector]
		private STPEventReference m_AimShootEvent = new STPEventReference("On Aim Shoot");


		public override void Shoot(float speedMod)
		{
			for (int i = 0; i < m_ProjectilesCount; i++)
				SpawnProjectile(Firearm.Character, Firearm.GetShootRay(m_ShootSpread), speedMod);

			// Lower the durability...
			if (Firearm.ItemDurability != null)
				Firearm.ItemDurability.Float = Mathf.Max(Firearm.ItemDurability.Float - m_DurabilityRemove, 0f);

			// Audio
			var audioPlayer = Firearm.AudioPlayer;
			audioPlayer.PlaySound(m_ShootAudio);
			audioPlayer.PlaySounds(m_HandlingAudio);

			// Events
			Firearm.EventHandler.TriggerAction(Firearm.Aimer.IsAiming ? m_AimShootEvent : m_ShootEvent, 1f);
		}

		private void SpawnProjectile(ICharacter user, Ray ray, float speedMod)
		{
			Vector3 position = ray.origin + user.ViewTransform.TransformVector(m_SpawnPositionOffset);
			Quaternion rotation = Quaternion.LookRotation(ray.direction) * Quaternion.Euler(m_SpawnRotationOffset);

			ShaftedProjectile projectile = Instantiate(m_Projectile, position, rotation);

			// Launch the projectile...
			if (projectile != null)
			{
				projectile.DamageMod = m_DamageMod;

				projectile.Rigidbody.velocity = (m_SpawnVelocity * speedMod * projectile.transform.forward) + (user.GetModule<ICharacterMotor>().Velocity / 10f);
				projectile.Rigidbody.angularVelocity = Random.onUnitSphere * m_SpawnTorque;

				projectile.Launch(user);
				projectile.CheckForSurfaces(ray.origin, ray.direction);
			}
		}
	}
}