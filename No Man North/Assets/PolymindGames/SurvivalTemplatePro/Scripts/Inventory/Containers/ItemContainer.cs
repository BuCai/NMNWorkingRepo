using System;
using System.Collections;
using UnityEngine;

namespace SurvivalTemplatePro.InventorySystem
{
    [Serializable]
	public class ItemContainer : IEnumerable, IItemContainer
	{
		public IItemSlot this[int i] { get => m_Slots[i]; set => m_Slots[i] = value as ItemSlot; }

		/// <summary>Slot count.</summary>
		public int Count => m_Slots.Length;
		public IItemSlot[] Slots => m_Slots;
		public ItemContainerFlags Flag => m_Flag;

		[SerializeField]
		public bool CanAddItems { get; set; }

		[SerializeField]
		public bool CanRemoveItems { get; set; }

		public string Name => m_Name;
		public int MaxWeight => m_MaxWeight;

		public event ItemSlotChangedCallback onContainerChanged;

        [SerializeField]
		[Tooltip("The name of the item container.")]
		private string m_Name;

		[SerializeField]
		[Tooltip("The max weight that this container can hold, no item can be added if it exceeds the limit.")]
		private int m_MaxWeight;

        [SerializeField]
		[Tooltip("Acts as a container type.")]
		private ItemContainerFlags m_Flag;

        [SerializeField]
		[Tooltip("Number of item slots that this container has (e.g. Holster 8, Backpack 25 etc.).")]
		private ItemSlot[] m_Slots;

        [SerializeField]
		[Tooltip("Only items from the specified categories can be added")]
		private ItemCategoryReference[] m_ValidCategories;

        [SerializeField]
		[Tooltip("Only items with the specified properties can be added.")]
		private ItemPropertyReference[] m_RequiredProperties;

		[SerializeField]
		[Tooltip("Only items that are tagged with the specified tag can be added.")]
		private string m_RequiredTag;


		#region Initialization
		public void OnLoad() 
		{
			for (int i = 0; i < m_Slots.Length; i++)
				m_Slots[i].onChanged += OnSlotChanged;
		}

        public ItemContainer(string name, int maxWeight, int size, ItemContainerFlags flag, ItemCategoryReference[] validCategories, ItemPropertyReference[] requiredProperties, string requiredTag)
		{
			m_Name = name;
			m_MaxWeight = maxWeight;
			m_Slots = new ItemSlot[size];

			for (int i = 0;i < m_Slots.Length;i ++)
			{
				m_Slots[i] = new ItemSlot();
				m_Slots[i].onChanged += OnSlotChanged;
			}

			m_Flag = flag;
			m_ValidCategories = validCategories;
			m_RequiredProperties = requiredProperties;
			m_RequiredTag = (requiredTag == ItemDatabase.Untagged) ? "" : requiredTag;

			CanAddItems = true;
			CanRemoveItems = true;
		}

        IEnumerator IEnumerable.GetEnumerator() => m_Slots.GetEnumerator();

		private void OnSlotChanged(IItemSlot slot, ItemSlotChangeType changeType)
		{
			if (changeType != ItemSlotChangeType.PropertyChanged)
				onContainerChanged?.Invoke(slot, changeType);
		}
        #endregion

        #region Add Items
        public int AddItem(string name, int amount, IItemProperty[] customProperties = null)
		{
			ItemInfo itemInfo;

			if (!ItemDatabase.TryGetItemByName(name, out itemInfo) || (AllowItem(itemInfo, amount) < amount))
				return 0;

			return AddItemWithInfo(itemInfo, amount, customProperties);
		}

		public int AddItem(int id, int amount, IItemProperty[] customProperties = null)
		{
			ItemInfo itemInfo;

			if (!ItemDatabase.TryGetItemById(id, out itemInfo) || (AllowItem(itemInfo, amount) < amount))
				return 0;

			return AddItemWithInfo(itemInfo, amount, customProperties);
		}

		/// <summary>
		/// Adds an item to this container
		/// </summary>
		/// <param name="item"></param>
		/// <param name="flags"></param>
		/// <returns> Stack added count. </returns>
		public int AddItem(IItem item)
		{
			if (AllowsItem(item, true))
			{
				if (item.Info.StackSize > 1)
				{
					int stackAddedCount = AddItemWithInfo(item.Info, item.CurrentStackSize, item.Properties);
					item.CurrentStackSize -= stackAddedCount;

					return stackAddedCount;
				}
				else
				{
					// The item's not stackable, try find an empty slot for it
					for (int i = 0; i < m_Slots.Length; i++)
					{
						if (!m_Slots[i].HasItem)
						{
							m_Slots[i].SetItem(item);
							return 1;
						}
					}
				}
			}

			return 0;
		}

		public bool AddOrSwap(IItemContainer slotParent, IItemSlot slot)
		{
			if (!slot.HasItem)
				return false;

			IItem item = slot.Item;

			if (AllowsItem(item))
			{
				// Go through each slot and see where we can add the item
				for (int i = 0; i < m_Slots.Length; i++)
				{
					if (!m_Slots[i].HasItem)
					{
						m_Slots[i].SetItem(item);
						slot.SetItem(null);

						return true;
					}
				}

				if (slotParent.AllowsItem(m_Slots[0].Item))
				{
					IItem tempItem = m_Slots[0].Item;
					m_Slots[0].SetItem(item);
					slot.SetItem(tempItem);

					return true;
				}

				return false;
			}
			else
				return false;
		}

		public bool AllowsItem(IItem item, bool ignoreWeight = false)
		{
			if (item == null)
				return false;

			return AllowItem(item.Info, item.CurrentStackSize, ignoreWeight) > 0;
		}

		/// <returns> allow count </returns>
		private int AllowItem(ItemInfo itemInfo, int count, bool ignoreWeight = false)
		{
			if (!CanAddItems)
				return 0;

			int allowAmount = count;

			// Weight-check first
			if (!ignoreWeight)
			{
				if (count == 1)
				{
					if (GetContainerWeight() + itemInfo.Weight * count > m_MaxWeight)
						return 0;
				}
				else
				{
					allowAmount = (int)Mathf.Clamp(count, 0f, (m_MaxWeight - GetContainerWeight()) / itemInfo.Weight);

					if (allowAmount == 0)
						return 0;
				}
			}

			// Check category
			bool isFromValidCategories = m_ValidCategories == null || m_ValidCategories.Length == 0;

			if (m_ValidCategories != null)
			{
				for (int i = 0; i < m_ValidCategories.Length; i++)
				{
					if (m_ValidCategories[i] == itemInfo.Category)
						isFromValidCategories = true;
				}
			}

			if (!isFromValidCategories)
				return 0;

			// Check properties
			if (m_RequiredProperties != null)
			{
				for (int i = 0; i < m_RequiredProperties.Length; i++)
				{
					bool hasProperty = false;

					for (int p = 0; p < itemInfo.Properties.Length; p++)
					{
						if (itemInfo.Properties[p].Id == m_RequiredProperties[i])
						{
							hasProperty = true;
							break;
						}
					}

					if (!hasProperty)
						return 0;
				}
			}

			// Check tags
			if (!string.IsNullOrEmpty(m_RequiredTag))
			{
				if (!itemInfo.CompareTag(m_RequiredTag))
					return 0;
			}

			return allowAmount;
		}

		private int AddItemWithInfo(ItemInfo itemInfo, int amount, IItemProperty[] customProperties = null)
		{
			if (itemInfo == null)
				return 0;

			amount = AllowItem(itemInfo, amount);
			int added = 0;

			// Go through each slot and see where we can add the item(s)
			for (int i = 0; i < m_Slots.Length; i++)
			{
				added += AddItemToSlot(m_Slots[i], itemInfo, amount, customProperties);

				// We've added all the items, we can stop now
				if (added == amount)
					return added;
			}

			return added;
		}

		private int AddItemToSlot(ItemSlot slot, ItemInfo itemInfo, int amount, IItemProperty[] properties = null)
		{
			if (slot.HasItem && itemInfo.Name != slot.Item.Name)
				return 0;

			bool wasEmpty = false;

			if (!slot.HasItem)
			{
				slot.SetItem(new Item(itemInfo, 1, properties));
				amount--;
				wasEmpty = true;
			}

			int addedToStack = slot.AddToStack(amount);

			return addedToStack + (wasEmpty ? 1 : 0);
		}
		#endregion

		#region Remove Items
		public int RemoveItem(string name, int amount)
		{
			int removed = 0;

			for (int i = 0; i < m_Slots.Length; i++)
			{
				if (m_Slots[i].HasItem && m_Slots[i].Item.Name == name)
				{
					removed += m_Slots[i].RemoveFromStack(amount - removed);

					// We've removed all the items, we can stop now
					if (removed == amount)
						return removed;
				}
			}

			return removed;
		}

		public int RemoveItem(int id, int amount)
		{
			int removed = 0;

			for (int i = 0; i < m_Slots.Length; i++)
			{
				if (m_Slots[i].HasItem && m_Slots[i].Item.Id == id)
				{
					removed += m_Slots[i].RemoveFromStack(amount - removed);

					// We've removed all the items, we can stop now
					if (removed == amount)
						return removed;
				}
			}

			return removed;
		}

		public bool RemoveItem(IItem item)
		{
			for (int i = 0; i < m_Slots.Length; i++)
			{
				if (m_Slots[i].Item == item)
				{
					m_Slots[i].SetItem(null);
					return true;
				}
			}

			return false;
		}
		#endregion

		#region Item Checks
		public bool ContainsItem(IItem item)
		{
			for (int i = 0; i < m_Slots.Length; i++)
			{
				if (m_Slots[i].Item == item)
					return true;
			}

			return false;
		}

		public int GetItemCount(string name)
		{
			int count = 0;

			for (int i = 0; i < m_Slots.Length; i++)
			{
				if (m_Slots[i].HasItem && m_Slots[i].Item.Name == name)
					count += m_Slots[i].Item.CurrentStackSize;
			}

			return count;
		}

		public int GetItemCount(int id)
		{
			int count = 0;

			for (int i = 0; i < m_Slots.Length; i++)
			{
				if (m_Slots[i].HasItem && m_Slots[i].Item.Id == id)
					count += m_Slots[i].Item.CurrentStackSize;
			}

			return count;
		}

		public int GetSlotIndex(IItemSlot slot)
		{
			for (int i = 0; i < m_Slots.Length; i++)
			{
				if (m_Slots[i] == slot)
					return i;
			}

			return -1;
		}

		private float GetContainerWeight()
		{
			float weight = 0f;

			for (int i = 0; i < m_Slots.Length; i++)
			{
				if (m_Slots[i].HasItem)
					weight += m_Slots[i].Item.TotalWeight;
			}

			return weight;
		}
		#endregion
	}
}