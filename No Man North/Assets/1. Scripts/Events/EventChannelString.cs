using System;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [CreateAssetMenu(menuName = "EventChannel/String")]
    public class EventChannelString : ScriptableObject
    {
        public event Action<String> OnEvent;

        public void RaiseEvent(String i)
        {
            OnEvent?.Invoke(i);
        }

    }
}