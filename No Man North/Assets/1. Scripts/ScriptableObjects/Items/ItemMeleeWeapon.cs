using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public enum MeleeAttackType { Ranged, Unarmed, Blunt, Sharp };

    [CreateAssetMenu(menuName = "Item/MeleeWeapon")]
    public class ItemMeleeWeapon : ItemBaseMainUsable
    {
        #region Variables

        [field: SerializeField] public float damage { private set; get; }
        [field: SerializeField] public MeleeAttackType MeleeAttackType { private set; get; }
        [SerializeField] private float fireRate;
        [SerializeField] private float staminaUse;
        [SerializeField] private EventChannelFloat OnPlayerStaminaChange;
        #endregion

        #region Methods

        public override void PrimaryUse(GameObject owner, Transform spawnLocation)
        {
            //If you dont have the stamina to use it
            if (PlayerStatManager.Instance.stamina.current < staminaUse) return;

            OnPlayerStaminaChange.RaiseEvent(-staminaUse);

            PlayerAnimationHelper.Instance.AxeAttack();
            //hit boxes are activated on 
        }

        #endregion
    }
}
