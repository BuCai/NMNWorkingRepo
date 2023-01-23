using System;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
[CreateAssetMenu(menuName = "EventChannel/Interatable")]
    public class EventChannelInteratable : ScriptableObject
    {
        public event Action<Interactable> OnEvent;

        public void RaiseEvent(Interactable i)
        {
            OnEvent?.Invoke(i);
        }
    }
}
