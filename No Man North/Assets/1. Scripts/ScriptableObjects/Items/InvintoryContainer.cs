using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    [SelectionBase]
    public class InvintoryContainer : Invintory
    {
        #region Variables
        [SerializeField] private EventChannelInvintoryContainer OnOpenInvintory;
        [SerializeField] private EventChannelInvintoryContainer OnOpenContainer;

        [field: SerializeField] public bool canAddItems { get; private set; } = false;
        [field: SerializeField] public int maxItems { get; private set; } = 10;


        [SerializeField] private Interactable interactable;

        [SerializeField] private GameObject dropLocation;
        [SerializeField] private GameObject itemPrefab;

        #endregion

        #region Unity Methods



        #endregion

        #region Methods

        public void changeWeightContainer(ItemBase item, int amount)
        {
            currentCarryWeight += (item.carryWeight * amount);
            raiseWeightChangeFromChild();
        }

        public void opened()
        {
            OnOpenInvintory?.RaiseEvent(this);
        }

        public void removeItem(InvintorySlot itemRemove)
        {
            items.Remove(itemRemove);
            if (items.Count == 0)
            {
                interactable.setDisplayNameModifier("(Empty)");
                if (canAddItems == false)
                {
                    interactable.setInteractable(false);
                }
                
            }
        }

        public override void dropItem(InvintorySlot itemRemove)
        {
            removeItem(itemRemove);
            changeWeight(itemRemove.item, itemRemove.amount * -1);

            ItemPickUp droppedItem = Instantiate(itemPrefab, dropLocation.transform.position, this.transform.rotation).GetComponent<ItemPickUp>();
            droppedItem.setItemSlot(itemRemove);
        }


        #endregion
    }
}