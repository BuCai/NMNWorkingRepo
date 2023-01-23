using System;
using UnityEngine;

namespace SurvivalTemplatePro.InventorySystem
{
    [Serializable]
    public class ItemCategory : ICloneable
    {
        public string Name => m_Name;
        public ItemInfo[] Items { get => m_Items; set => m_Items = value; }

        [SerializeField]
        private string m_Name;

        [SerializeField]
        private ItemInfo[] m_Items;

        public object Clone() => (ItemCategory)MemberwiseClone();
    }
}