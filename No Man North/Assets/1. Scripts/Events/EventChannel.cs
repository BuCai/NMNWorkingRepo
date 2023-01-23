using System;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [CreateAssetMenu(menuName = "EventChannel/Base")]
    public class EventChannel : ScriptableObject
    {
        public event Action OnEvent;

        public void RaiseEvent()
        {
            OnEvent?.Invoke();
        }


    }
}
