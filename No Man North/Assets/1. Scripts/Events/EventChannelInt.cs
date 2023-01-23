using System;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [CreateAssetMenu(menuName = "EventChannel/Int")]
    public class EventChannelInt : ScriptableObject
    {
        public event Action<int> OnEvent;

        public void RaiseEvent(int i)
        {
            OnEvent?.Invoke(i);
        }

    }
}
