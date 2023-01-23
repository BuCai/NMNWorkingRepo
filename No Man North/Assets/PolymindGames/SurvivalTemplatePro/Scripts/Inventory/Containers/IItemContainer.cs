using System.Collections;

namespace SurvivalTemplatePro.InventorySystem
{
    public interface IItemContainer : IEnumerable
	{
		IItemSlot this[int i] { get; set; }

		/// <summary>Slot count.</summary>
		int Count { get; }
		IItemSlot[] Slots { get; }
		ItemContainerFlags Flag { get; }

		bool CanAddItems { get; set; }
		bool CanRemoveItems { get; set; }

		string Name { get; }
		int MaxWeight { get; }

		event ItemSlotChangedCallback onContainerChanged;

		void OnLoad();

		/// <summary>
		/// Adds an item to this container
		/// </summary>
		/// <returns> Stack added count. </returns>
		int AddItem(IItem item);
		int AddItem(string name, int amount, IItemProperty[] customProperties = null);
		int AddItem(int id, int amount, IItemProperty[] customProperties = null);
		bool AddOrSwap(IItemContainer slotParent, IItemSlot slot);

		int RemoveItem(string name, int amount);
		int RemoveItem(int id, int amount);
		bool RemoveItem(IItem item);

		bool ContainsItem(IItem item);
		int GetItemCount(string name);
		int GetItemCount(int id);

		bool AllowsItem(IItem item, bool ignoreWeight = false);
		int GetSlotIndex(IItemSlot slot);
	}

	public delegate void ItemContainerChangedCallback(IItemSlot itemSlot);

	public enum SlotSelectionMethod
	{
		FirstFreeSlot,
		LastFreeSlot,
		RandomSlot
	}
}