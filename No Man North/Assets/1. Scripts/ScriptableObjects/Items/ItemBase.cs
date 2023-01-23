using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public enum EquimentSlot{ None, MainHand, OffHand, QuickUse };
    public abstract class ItemBase : ScriptableObject
    {
        [field: SerializeField] public string displayName { get; private set; }
        [field: SerializeField] public string Description { get; private set; }
        [field: SerializeField] public GameObject modelPrefab { get; private set; }
        [field: SerializeField] public Sprite ui_Icon { get; private set; }
        [field: SerializeField] public float carryWeight { get; private set; }

        [field: SerializeField] public int initialStackSize { get; private set; }
        [field: SerializeField] public int maxStackSize { get; private set; }
        [field: SerializeField] public EquimentSlot equimentSlot { get; private set; }

    }
}