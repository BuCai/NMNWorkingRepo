using System;
using UnityEngine;

namespace SurvivalTemplatePro.InventorySystem
{
    [Serializable]
	public class ItemSlot : IItemSlot
	{
		public bool HasItem => Item != null;
		public IItem Item => m_Item;

		/// <summary>Sent when this slot has changed (e.g. when the item has changed).</summary>
		public event ItemSlotChangedCallback onChanged;

		[SerializeField]
		private Item m_Item;


        public void SetItem(IItem item)
		{
			if (m_Item != item)
			{
				if (HasItem)
				{
					m_Item.onPropertyChanged -= OnPropertyChanged;
					m_Item.onStackChanged -= OnStackChanged;
				}

				m_Item = item as Item;

				if (m_Item != null)
				{
					m_Item.onPropertyChanged += OnPropertyChanged;
					m_Item.onStackChanged += OnStackChanged;
				}

				onChanged?.Invoke(this, ItemSlotChangeType.ItemChanged);
			}
		}

		public int RemoveFromStack(int amount)
		{
			if (!HasItem)
				return 0;

			if (amount >= m_Item.CurrentStackSize)
			{
				int stackSize = m_Item.CurrentStackSize;
				SetItem(null);

				return stackSize;
			}

			int oldStack = m_Item.CurrentStackSize;
			Item.CurrentStackSize = Mathf.Max(Item.CurrentStackSize - amount, 0);

			if (oldStack != m_Item.CurrentStackSize)
				onChanged?.Invoke(this, ItemSlotChangeType.StackChanged);

			return oldStack - m_Item.CurrentStackSize;
		}

		public int AddToStack(int amount)
		{
			if (!HasItem || m_Item.Info.StackSize <= 1)
				return 0;

			int oldStackCount = m_Item.CurrentStackSize;
			int surplus = amount + oldStackCount - Item.Info.StackSize;
			int currentStackCount = oldStackCount;

			if (surplus <= 0)
				currentStackCount += amount;
			else
				currentStackCount = m_Item.Info.StackSize;

			m_Item.CurrentStackSize = currentStackCount;

			return currentStackCount - oldStackCount;
		}

		private void OnPropertyChanged(IItemProperty itemProperty) => onChanged?.Invoke(this, ItemSlotChangeType.PropertyChanged);
		private void OnStackChanged() => onChanged?.Invoke(this, ItemSlotChangeType.StackChanged);
	}
}
