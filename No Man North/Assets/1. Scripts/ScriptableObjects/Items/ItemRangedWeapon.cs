using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [CreateAssetMenu(menuName = "Item/RangedWeapon")]
    public class ItemRangedWeapon : ItemBaseMainAndSecoundaryUsable
    {
        

        [field: SerializeField] public float damage { private set; get; }
        [Header("Ranged Weapon")]
        [SerializeField] private float fireRate;
        [SerializeField] private GameObject Projectile;
        [SerializeField] private ItemAmmo ammoType;

        public override void PrimaryUse(GameObject owner, Transform spawnLocation)
        {
            if( InvintoryPlayer.Instance.useItem(ammoType) == false)
            {
                return;
            }

            GameObject spawnedBullet = Instantiate(Projectile, spawnLocation.position, spawnLocation.rotation);
            if (spawnedBullet.TryGetComponent<HitDetection>( out HitDetection spawnedProjectile ))
            {   
                spawnedProjectile.setUpHitData(UNIT_TEAM.PLAYER, owner, damage, MeleeAttackType.Ranged);
            }

        }

        public override void SecondaryUse(GameObject owner, Transform spawnLocation)
        {
            Debug.Log("Secondary Use not Implemented yet");
        }
    }
}