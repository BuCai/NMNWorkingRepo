using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public enum UNIT_TEAM { PLAYER, ALLY, ENEMY, NUETRAL };
    public class Hitable : MonoBehaviour
    {
        #region Variables

        [SerializeField, Range(0,2)] private float damageMultiplier = 1;
        [SerializeField, Range(0, 2)] private float damageMultiplierBlunt = 1;
        [SerializeField, Range(0, 2)] private float damageMultiplierSharp = 1;
        [SerializeField, Range(0, 2)] private float damageMultiplierUnAramed = 1;
        [SerializeField] private UNIT_TEAM team;
        public event Action<HitData> OnHitEvent;
        #endregion

        #region Unity Methods

        #endregion

        #region Methods

        public void registerHit(HitData hitData)
        {
            //Unit Hit
            float damageMall = damageMultiplier;
            if (hitData.attackType == MeleeAttackType.Blunt)
            {
                damageMall += damageMultiplierBlunt;
                damageMall = damageMall / 2;
            }
            if (hitData.attackType == MeleeAttackType.Sharp)
            {
                damageMall += damageMultiplierSharp;
                damageMall = damageMall / 2;
            }
            if (hitData.attackType == MeleeAttackType.Unarmed)
            {
                damageMall += damageMultiplierUnAramed;
                damageMall = damageMall / 2;
            }

            hitData.multiplyDamage(damageMultiplier);
            print($"{gameObject.name} - {hitData.damage}");
            OnHitEvent?.Invoke(hitData);
        }

        public UNIT_TEAM getTeam()
        {
            return team;
        }

        #endregion
    }
}