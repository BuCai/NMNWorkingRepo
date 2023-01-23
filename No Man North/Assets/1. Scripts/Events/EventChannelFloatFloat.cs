using System;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [CreateAssetMenu(menuName = "EventChannel/FloatFloat")]
    public class EventChannelFloatFloat : ScriptableObject
    {
        public event Action<float,float> OnEvent;

        public void RaiseEvent(float i, float s)
        {
            OnEvent?.Invoke(i,s);
        }

    }
}
