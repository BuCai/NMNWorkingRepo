using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [Serializable]
    public struct hitBoxMultipliers
    {

    }

    public class UnitStatHp : MonoBehaviour
    {
        #region Variables

        [SerializeField] private float maxHp;
        private float currentHp;

        [SerializeField] private Hitable[] hitable;
        public event System.Action OnDeath;

        #endregion

        #region Unity Methods

        private void Start()
        {
            currentHp = maxHp;

            foreach(Hitable hit in hitable)
            {
                hit.OnHitEvent += Hitable_OnHitEvent;
            }

            //hitable.OnHitEvent += Hitable_OnHitEvent;
        }

        private void OnDestroy()
        {
            foreach (Hitable hit in hitable)
            {
                hit.OnHitEvent -= Hitable_OnHitEvent;
            }
        }

        #endregion

        #region Methods

        private void Hitable_OnHitEvent(HitData hitData)
        {
            currentHp = currentHp - hitData.damage;
            
            if (currentHp <= 0)
            {
                this.gameObject.SetActive(false);
                OnDeath?.Invoke();
            }
        }

        #endregion
    }
}