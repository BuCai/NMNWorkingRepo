using System;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [CreateAssetMenu(menuName = "EventChannel/Float")]
    public class EventChannelFloat : ScriptableObject
    {
        public event Action<float> OnEvent;

        public void RaiseEvent(float i)
        {
            OnEvent?.Invoke(i);
        }

    }
}

