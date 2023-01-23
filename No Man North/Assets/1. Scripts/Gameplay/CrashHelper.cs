using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class CrashHelper : MonoBehaviour
    {
        #region Variables

        [SerializeField] private EventChannelFloat OnPlayerHpChange;
        [SerializeField] private EventChannelFloat OnRVHpChange;

        [SerializeField] private float minimumCrashThreshHold;
        [SerializeField] private float maxDamageOnCrash;

        [SerializeField] private float damageOnCrashMultiplier;

        #endregion

        #region Unity Methods

        #endregion

        #region Methods

        public void crashHelper(Collision collision)
        {
            if (GameStateManager.Instance.CurrentPlayerState == PlayerState.RV)
            {
                if (collision.relativeVelocity.magnitude >= minimumCrashThreshHold)
                {
                    OnPlayerHpChange.RaiseEvent(Mathf.Clamp(collision.relativeVelocity.magnitude * -damageOnCrashMultiplier, -maxDamageOnCrash, 0));
                    OnRVHpChange.RaiseEvent(Mathf.Clamp(collision.relativeVelocity.magnitude * -damageOnCrashMultiplier, -maxDamageOnCrash, 0));
                }
            }
        }


        #endregion
    }
}