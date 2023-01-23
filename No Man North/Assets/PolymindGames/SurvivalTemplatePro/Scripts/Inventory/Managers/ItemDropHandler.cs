using SurvivalTemplatePro.MovementSystem;
using System.Collections;
using UnityEngine;

namespace SurvivalTemplatePro.InventorySystem
{
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/inventory#item-drop-handler-module")]
	public class ItemDropHandler : ObjectDropHandler, IItemDropHandler
	{
		[Space]

		[SerializeField]
		[Tooltip("Position, rotation offsets etc.")]
		private ObjectDropSettings m_ItemDropSettings;

		[Space]

		[SerializeField, AssetPreview]
		[Tooltip("The prefab used when an item that's dropped doesn't have a pickup (e.g. clothes) or when dropping multiple items at once.")]
		private GameObject m_SackPrefab;


		public void DropItem(IItem itemToDrop, float dropDelay = 0f)
		{
			if (itemToDrop == null)
				return;

			StartItemDrop(itemToDrop, dropDelay);

			// Remove dropped item from the inventory
			Character.Inventory.RemoveItem(itemToDrop);
		}

		public void DropItem(IItemSlot itemSlot, float dropDelay = 0)
		{
			if (itemSlot == null || !itemSlot.HasItem)
				return;

			StartItemDrop(itemSlot.Item, dropDelay);

			// Remove dropped item from the slot
			itemSlot.SetItem(null);
		}

		private void StartItemDrop(IItem itemToDrop, float dropDelay)
		{
			if (dropDelay > 0.01f)
				StartCoroutine(C_DropWithDelay(itemToDrop, dropDelay));
			else
				DropItem(itemToDrop);
		}

		private void DropItem(IItem itemToDrop) 
		{
			if (itemToDrop == null)
				return;

			GameObject prefabToDrop;

			if (itemToDrop.CurrentStackSize == 1 && itemToDrop.Info.Pickup != null)
				prefabToDrop = itemToDrop.Info.Pickup.gameObject;
			else
				prefabToDrop = m_SackPrefab;

			float dropHeightMod = Character.GetModule<IMotionController>().ActiveStateType == MotionStateType.Crouch ? 0.5f : 1f;
			GameObject droppedObj = DropObject(m_ItemDropSettings, prefabToDrop, dropHeightMod);

			// Link the pickup with the dropped object
			if (droppedObj.TryGetComponent(out ItemPickup itemPickup))
				itemPickup.LinkWithItem(itemToDrop);
		}

		private IEnumerator C_DropWithDelay(IItem itemToDrop, float dropDelay) 
		{
			yield return new WaitForSeconds(dropDelay);

			DropItem(itemToDrop);
		}
    }
}