using UnityEngine;
using UnityEngine.Events;

namespace MLC.NoManNorth.Eric
{
    public class UnityEventLisener : MonoBehaviour
    {
        #region Variables

        [SerializeField] private EventChannel EventToLisenFor;
        [SerializeField] private UnityEvent OnEventLisened;

        #endregion

        #region Unity Methods
        private void Start()
        {
            EventToLisenFor.OnEvent += EventToLisenFor_OnEvent;
        }

        private void OnDestroy()
        {
            EventToLisenFor.OnEvent -= EventToLisenFor_OnEvent;
        }
        #endregion

        #region Methods
        private void EventToLisenFor_OnEvent()
        {
            OnEventLisened.Invoke();
        }
        #endregion
    }
}