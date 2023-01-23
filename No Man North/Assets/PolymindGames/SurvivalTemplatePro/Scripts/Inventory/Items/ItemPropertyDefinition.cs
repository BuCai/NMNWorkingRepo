using System;
using UnityEngine;

namespace SurvivalTemplatePro.InventorySystem
{
    [Serializable]
    public class ItemPropertyDefinition : ICloneable
    {
        [HideInInspector]
        public int Id;

        public string Name;

        public ItemPropertyType Type;

#if UNITY_EDITOR
        public string Description;
#endif

        public object Clone() => (ItemPropertyDefinition)MemberwiseClone();
    }
}