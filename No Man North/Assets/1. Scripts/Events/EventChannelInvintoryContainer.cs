using System;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [CreateAssetMenu(menuName = "EventChannel/InvintoryContainer")]
    public class EventChannelInvintoryContainer : ScriptableObject
    {
        public event Action<InvintoryContainer> OnEvent;

        public void RaiseEvent(InvintoryContainer i)
        {
            OnEvent?.Invoke(i);
        }

    }
}