using SurvivalTemplatePro.InputSystem;
using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/user-interface/behaviours/ui_inventory#item-drag-handler")]
	public class ItemDragHandler : PlayerUIBehaviour
	{
		[SerializeField]
		[Tooltip("Slot template prefab that will be instantiate when an item gets dragged.")]
		private ItemSlotUI m_DraggedSlotTemplate;

		[SerializeField, Range(0f, 5f)]
		[Tooltip("The visual scale of the dragged item.")]
		private float m_DraggedItemScale = 0.85f;

		[SerializeField, Range(0f, 5f)]
		[Tooltip("The transparency of the dragged item.")]
		private float m_DraggedItemAlpha = 0.75f;

        private bool m_IsDraggingItem;

		private IItem m_DraggedItem;
		private RectTransform m_DraggedItemRT;
		private Canvas m_Canvas;
		private RectTransform m_ParentCanvasRT;
		private Vector2 m_DragOffset;

		private IItemDropHandler m_ItemDropHandler;


		public override void OnAttachment()
		{
			m_Canvas = GetComponentInParent<Canvas>();
			m_ParentCanvasRT = m_Canvas.GetComponent<RectTransform>();

			Player.TryGetModule(out m_ItemDropHandler);
		}

        public override void OnInterfaceUpdate()
        {
			m_DragOffset = Vector2.Lerp(m_DragOffset, Vector2.zero, Time.deltaTime * 12f);
		}

		public void OnBeginDrag(DragEventParams eventParams)
		{
            m_IsDraggingItem = false;

			if (eventParams.DragStartRaycast == null)
				return;

			ItemSlotUI itemSlot = eventParams.DragStartRaycast.GetComponent<ItemSlotUI>();

			if (itemSlot == null)
				return;

			var dragDisabler = itemSlot.GetComponent<DisableItemDragAndDrop>();

			if (!itemSlot.HasItem || (dragDisabler != null && dragDisabler.DisableDragging))
				return;

			IItem itemUnderPointer = itemSlot.Item;

			if (itemUnderPointer != null)
			{
                m_IsDraggingItem = true;

				// Item Stack splitting
				if (eventParams.SplitItemStack && itemUnderPointer.CurrentStackSize > 1)
				{
					int initialAmount = itemUnderPointer.CurrentStackSize;
					int half = initialAmount / 2;
					itemUnderPointer.CurrentStackSize = initialAmount - half;

					m_DraggedItem = new Item(itemUnderPointer.Info, half, itemUnderPointer.Properties);
					itemSlot.DoRefresh();
				}
				else
				{
					itemSlot.ItemSlot.SetItem(null);
					m_DraggedItem = itemUnderPointer;
				}

				m_DraggedItemRT = m_DraggedSlotTemplate.GetItemUI(m_DraggedItem, m_DraggedItemAlpha);
				m_DraggedItemRT.gameObject.SetActive(true);
				m_DraggedItemRT.SetParent(m_ParentCanvasRT, true);

				m_DraggedItemRT.localScale = Vector3.one * m_DraggedItemScale;

				if (RectTransformUtility.ScreenPointToWorldPointInRectangle(m_ParentCanvasRT, eventParams.CurrentPointerPosition, null, out Vector3 worldPoint))
					m_DragOffset = itemSlot.transform.position - worldPoint;

				if (RectTransformUtility.ScreenPointToLocalPointInRectangle(m_ParentCanvasRT, eventParams.CurrentPointerPosition, null, out Vector2 localPoint))
					m_DraggedItemRT.localPosition = localPoint + (Vector2)m_ParentCanvasRT.InverseTransformVector(m_DragOffset);
			}
		}

		public void OnDrag(DragEventParams eventParams)
		{
			if (!m_IsDraggingItem)
				return;

			if (RectTransformUtility.ScreenPointToLocalPointInRectangle(m_ParentCanvasRT, eventParams.CurrentPointerPosition, null, out Vector2 localPoint))
				m_DraggedItemRT.localPosition = localPoint + (Vector2)m_ParentCanvasRT.InverseTransformVector(m_DragOffset);
		}

		public void OnEndDrag(DragEventParams eventParams)
		{
            if (!m_IsDraggingItem)
				return;

            m_IsDraggingItem = false;

            GameObject objectUnderPointer = eventParams.CurrentRaycast;
			ItemSlotUI slotUnderPointer = null;

			if (objectUnderPointer != null)
				slotUnderPointer = objectUnderPointer.GetComponent<ItemSlotUI>();

			ItemSlotUI dragStartItemSlot = eventParams.DragStartRaycast?.GetComponent<ItemSlotUI>();

			// Is there a slot under our pointer?
			if (slotUnderPointer != null)
			{
				// Is the drop disabled on this specific slot?
				var dropDisabler = dragStartItemSlot.GetComponent<DisableItemDragAndDrop>();
				if (dropDisabler != null && dropDisabler.DisableDropping)
				{
					PutItemBack(dragStartItemSlot);
				}
				// See if the slot allows this type of item.
				else if (slotUnderPointer.Parent == null || slotUnderPointer.Parent.ItemContainer.AllowsItem(m_DraggedItem, true))
				{
					// If the slot is empty...
					if (!slotUnderPointer.HasItem)
					{
						if (slotUnderPointer.ItemSlot != null)
							slotUnderPointer.ItemSlot.SetItem(m_DraggedItem);
						else
							Debug.LogError("You tried to drop an item over a Slot which is not attached.", this);
					}
					// If the slot is not empty...
					else
					{
						IItem itemUnderPointer = slotUnderPointer.Item;

						// Can we stack the items?
						bool canStackItems = (itemUnderPointer.Name == m_DraggedItem.Name && itemUnderPointer.Info.StackSize > 1 && itemUnderPointer.CurrentStackSize < itemUnderPointer.Info.StackSize);

						if (canStackItems)
							OnItemsStackable(slotUnderPointer, dragStartItemSlot);
						else
							OnItemNotStackable(slotUnderPointer, dragStartItemSlot);
					}
				}
				else
					PutItemBack(dragStartItemSlot);
			}
			// If the player dropped it on a safe spot...
			else if (objectUnderPointer != null && objectUnderPointer.GetComponent<ItemDropSafeZone>())
			{
				PutItemBack(dragStartItemSlot);
			}
			// Drop the item from the inventory...
			else
				m_ItemDropHandler.DropItem(m_DraggedItem);

			Destroy(m_DraggedItemRT.gameObject);
			m_DraggedItem = null;
            m_IsDraggingItem = false;
        }
			
		private void OnItemsStackable(ItemSlotUI slotUnderPointer, ItemSlotUI initialSlot)
		{
			int added = slotUnderPointer.ItemSlot.AddToStack(m_DraggedItem.CurrentStackSize);

			// Try to add the remaining items in the parent container.
			int remainedToAdd = m_DraggedItem.CurrentStackSize - added;
			if (remainedToAdd > 0)
			{
				if (initialSlot.HasItem)
					slotUnderPointer.Parent.ItemContainer.AddItem(m_DraggedItem.Id, remainedToAdd);
				else
					initialSlot.ItemSlot.SetItem(new Item(m_DraggedItem.Info, remainedToAdd, m_DraggedItem.Properties));
			}
		}
			
		private void OnItemNotStackable(ItemSlotUI slotUnderPointer, ItemSlotUI initialSlot)
		{
			if(!initialSlot.Parent.ItemContainer.AllowsItem(slotUnderPointer.Item, true))
			{
				PutItemBack(initialSlot);
				return;
			}

			// Swap the items because they are of different kinds / not stackable / reached maximum stack size.
			IItem temp = slotUnderPointer.Item;
			if (!initialSlot.HasItem)
			{
				slotUnderPointer.ItemSlot.SetItem(m_DraggedItem);
				initialSlot.ItemSlot.SetItem(temp);
			}
			else
			{
				var initialContainer = initialSlot.Parent.ItemContainer;

				// Add as much as possible to the item's stack.
				int added = initialContainer.AddItem(m_DraggedItem.Id, m_DraggedItem.CurrentStackSize);

				// Add the remained items too.
				int remainedToAdd = m_DraggedItem.CurrentStackSize - added;
				if (remainedToAdd > 0)
					initialContainer.AddItem(m_DraggedItem.Id, remainedToAdd);
			}
		}
			
		private void PutItemBack(ItemSlotUI initialSlot)
		{
			var initialContainer = initialSlot.Parent.ItemContainer;

			if (initialSlot.HasItem)
				initialContainer.AddItem(m_DraggedItem);
			else
				initialSlot.ItemSlot.SetItem(m_DraggedItem);
		}
	}
}
