using System;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [CreateAssetMenu(menuName = "EventChannel/Item")]
    public class EventChannelItem : ScriptableObject
    {
        public event Action<ItemBase,int> OnEvent;

        public void RaiseEvent(ItemBase i, int amountToAdd)
        {
            OnEvent?.Invoke(i, amountToAdd);
        }
    }
}
