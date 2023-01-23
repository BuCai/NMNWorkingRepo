namespace SurvivalTemplatePro.InventorySystem
{
    public interface IItemSlot
    {
		bool HasItem { get; }
		IItem Item { get; }

		/// <summary>Sent when this slot has changed (e.g. when the item has changed).</summary>
		event ItemSlotChangedCallback onChanged;

		void SetItem(IItem item);

		int RemoveFromStack(int amount);
		int AddToStack(int amount);
	}

	public enum ItemSlotChangeType
	{
		ItemChanged,
		StackChanged,
		PropertyChanged
	}

	public delegate void ItemSlotChangedCallback(IItemSlot itemSlot, ItemSlotChangeType slotChangeType);
}