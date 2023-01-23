using EasyCharacterMovement;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class NoManNorthCharacterLooks : CharacterLook
    {
        #region Variables

        public static NoManNorthCharacterLooks Instance { get; private set; }

        #endregion

        #region Unity Methods

        private void Awake()
        {

            if (Instance != null && Instance != this)
            {
                Destroy(this);
            }
            else
            {
                Instance = this;
            }
        }

        #endregion

        #region Methods
        public void LockCursor(bool lockedState)
        {
            _isCursorLocked = lockedState;
        }
        #endregion
    }
}