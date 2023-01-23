using System;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    [RequireComponent(typeof(Collider))]
    public class TriggerEventHandler : MonoBehaviour
    {
        #region Internal
        [System.Serializable]
        public class ColliderEvent : UnityEvent<Collider> { }
        #endregion

        public event Action<Collider> onTriggerEnter;
        public event Action<Collider> onTriggerStay;
        public event Action<Collider> onTriggerExit;

        [SerializeField]
        private ColliderEvent m_TriggerEnter;

        [SerializeField]
        private ColliderEvent m_TriggerStay;

        [SerializeField]
        private ColliderEvent m_TriggerExit;


        private void OnTriggerEnter(Collider other)
        {
            m_TriggerEnter?.Invoke(other);
            onTriggerEnter?.Invoke(other);
        }

        private void OnTriggerStay(Collider other)
        {
            m_TriggerStay?.Invoke(other);
            onTriggerStay?.Invoke(other);
        }

        private void OnTriggerExit(Collider other)
        {
            m_TriggerExit?.Invoke(other);
            onTriggerExit?.Invoke(other);
        }

#if UNITY_EDITOR
        private void OnValidate()
        {
            GetComponent<Collider>().isTrigger = true;
        }
#endif
    }
}