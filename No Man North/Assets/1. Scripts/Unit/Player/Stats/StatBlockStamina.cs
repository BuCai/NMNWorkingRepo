using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [System.Serializable]
    public class StatBlockStamina : StatBlock
    {
        #region Variables

        [SerializeField] private float restorePerGameMin;
        
        #endregion

        #region Unity Methods

        #endregion

        #region Methods
        public override void OnGameMin_OnEvent(int minOfTheDay)
        {
            if( GameStateManager.Instance.CurrentPlayerState == PlayerState.Third && NoManNorthThirdPersonCharacterController.Instance.canRestoreStamina() )
            {
                changeStat(restorePerGameMin);
            }
        }

        public override void changeStat(float change)
        {
            if ( change > 0 && (PlayerStatManager.Instance.getMaxStamPercentage()) < (current + change)/max ) 
            {
                change = 0;
            }

            base.changeStat(change);
        }

        #endregion
    }
}