using System;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [CreateAssetMenu(menuName = "EventChannel/InvintorySlot")]
    public class EventChannelInvintorySlot : ScriptableObject
    {
        public event Action<InvintorySlot> OnEvent;

        public void RaiseEvent(InvintorySlot i)
        {
            OnEvent?.Invoke(i);
        }


    }
}
