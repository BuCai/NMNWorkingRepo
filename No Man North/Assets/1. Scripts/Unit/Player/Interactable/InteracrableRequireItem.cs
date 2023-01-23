using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class InteracrableRequireItem : Interactable
    {
        #region Variables
        
        [field: SerializeField] public ItemBase requiredItem { get; private set; }
        #endregion

        #region Unity Methods

        #endregion

        #region Methods

        protected override void ActiveInteract()
        {
            if (InvintoryPlayer.Instance.useItem(requiredItem) )
            {
                base.ActiveInteract();
            }
        }

        #endregion
    }
}