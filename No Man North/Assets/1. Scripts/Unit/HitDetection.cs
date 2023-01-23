using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

namespace MLC.NoManNorth.Eric
{
	public class HitData
    {
		[field: SerializeField] public float damage { private set; get; }
		[field: SerializeField] public MeleeAttackType attackType { private set; get; }

		Vector3 impactVelocity;
		public HitData(float damageIn, Vector3 velIn, MeleeAttackType attackTypeIn)
        {
			impactVelocity = velIn;
			damage = damageIn;
			attackType = attackTypeIn;
		}

		public void multiplyDamage(float multiplier)
        {
			damage = damage * multiplier;
        }

		public Vector3 getVelocity()
        {
			return impactVelocity;
        }
    }


	public class HitDetection : MonoBehaviour
	{

		[SerializeField] private GameObject hitSuccessVFX;
		[SerializeField] private UNIT_TEAM team;
		
		private GameObject Owner = null;
		private float damage = 1;
		private MeleeAttackType attackType;

		void Start()
		{
			if (hitSuccessVFX != null)
			{
				hitSuccessVFX.transform.parent = null;
			}
		}

		public void setUpHitData(UNIT_TEAM teamIn, GameObject OwnerIn, float damageIn, MeleeAttackType attackTypeIn)
		{
			Owner = OwnerIn;
			//ID = idIn;

			team = teamIn;
			damage = damageIn;
			attackType = attackTypeIn;
		}

		private void OnTriggerEnter(Collider other)
		{
			if (!(other.CompareTag("Hitable"))) { return; }

			// hit a unit collider with a statBlock
			if (other.TryGetComponent<Hitable>(out Hitable hitObject))
			{
				//Checks to see if you can effect this unit
				if (CheckHitUnit(hitObject.getTeam()) == true)
				{
					SuccessfulHit();
				}
				else
				{
					return;
				}
			}

			void SuccessfulHit()
			{
				if (hitSuccessVFX != null)
				{
					hitSuccessVFX.transform.position = this.transform.position;
				}
				
				HitData hitData = new HitData(damage, Vector3.zero, attackType);
				
				hitObject.registerHit(hitData);
				//Hide the game object Can only hit one thing
				this.gameObject.SetActive(false);
			}

			bool CheckHitUnit(UNIT_TEAM hitUnitTeam)
			{
				//Will need owner if you decide to add frienly fire later
				if (Owner == null)
				{
					print("Owner Not found");
					return false;
				}

                if (team != hitUnitTeam)
                {
					return true;
                }
				return false;
			}
		}

	}
}
