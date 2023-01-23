using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [System.Serializable]
    class consumeAmounts
    {
        [SerializeField] private EventChannelFloat statToChange;
        [SerializeField] private float value;

        public void consume()
        {
            if (statToChange != null) statToChange.RaiseEvent(value);
        }
    }

    [CreateAssetMenu(menuName = "Item/Consumable")]
    public class ItemConsumable : ItemBaseMainUsable
    {
        #region Variables
        
        [SerializeField] private consumeAmounts[] statsToChange;

        #endregion

        #region Unity Methods

        #endregion

        #region Methods
        public override void PrimaryUse(GameObject owner, Transform spawnLocation)
        {
            
            if( InvintoryPlayer.Instance.useItem(this) == false) return;

            foreach (consumeAmounts toEat in statsToChange)
            {
                toEat.consume();
            }
        }
        #endregion
    }
}