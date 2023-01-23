using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace MLC.NoManNorth.Eric
{
    public class EventLisenr : MonoBehaviour
    {
        #region Variables
        [SerializeField] private EventChannel eventToLisenFor;
        [SerializeField] private UnityEvent onLisenedToEvent;
        #endregion

        #region Unity Methods

        private void OnEnable()
        {
            eventToLisenFor.OnEvent += EventToLisenFor_OnEvent;
        }

        private void OnDisable()
        {
            eventToLisenFor.OnEvent -= EventToLisenFor_OnEvent;
        }

        #endregion

        #region Methods

        private void EventToLisenFor_OnEvent()
        {
            onLisenedToEvent.Invoke();
        }

        #endregion
    }
}