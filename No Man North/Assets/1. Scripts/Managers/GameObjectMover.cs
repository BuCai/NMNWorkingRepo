using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class GameObjectMover : MonoBehaviour
    {
        #region Variables
        [SerializeField] private GameObject toMove;
        [SerializeField] private GameObject target;
        #endregion

        #region Unity Methods

        #endregion

        #region Methods

        public void moveGameObject()
        {
            toMove.transform.position = target.transform.position;
        }

        #endregion
    }
}