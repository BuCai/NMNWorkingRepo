using System.Collections.Generic;
using UnityEngine;
using System;

namespace MLC.NoManNorth.Eric
{
    [Serializable]
    public class InvintorySlot
    {
        public InvintorySlot(ItemBase itemIn, int amountIn)
        {
            item = itemIn;
            amount = amountIn;
        }

        public ItemBase item;
        public int amount;
    }

    public class Invintory : MonoBehaviour
    {

        #region Variables

        [SerializeField] protected int MaxInvintorySlots;

        protected float currentCarryWeight;
        [SerializeField] protected float maxCarryWeightBeforeEncumbered;
        [field: SerializeField] public List<InvintorySlot> items { private set; get; } = new List<InvintorySlot>();

        public event Action<float> OnChangeWeight;

        #endregion

        #region Unity Methods

        protected virtual void Start()
        {

        }

        protected virtual void Awake()
        {
           currentCarryWeight = 0;
        }


        #endregion

        #region Methods

        protected virtual void addItemToInvintory(InvintorySlot pickedUpItem)
        {   
            int leftOver = pickedUpItem.amount;
            
            for (int i = 0; i < items.Count; i++)
            {
                //no more to insert
                if (leftOver <= 0) return;

                if (items[i].item == pickedUpItem.item && items[i].amount < items[i].item.maxStackSize)
                {
                    //found item of same type - try to add and get the left overs
                    int howManyCanFit = items[i].item.maxStackSize - items[i].amount;

                    if (howManyCanFit <= leftOver)
                    {

                        addExistingInvintorySlot(items[i], howManyCanFit);
                        leftOver -= howManyCanFit;
                    }
                    else
                    {
                        addExistingInvintorySlot(items[i], leftOver);
                        leftOver = 0;
                    }
                }

            }
            //some left over
            if (leftOver > 0)
            {
                addNewItem(pickedUpItem.item, leftOver);
            }
        }

        //create a new InvintorySlot and add to the list
        protected virtual InvintorySlot addNewItem(ItemBase pickedUpItem, int amountToAdd)
        {
            
            if (items.Count >= MaxInvintorySlots )
            {
                //drop item
                print("Warning trying to add an item to a full invintory somehow");
                return null;
            }

            InvintorySlot temp = new InvintorySlot(pickedUpItem, amountToAdd);
            items.Add(temp);
            
            changeWeight(pickedUpItem, amountToAdd);

            return temp;
        }

        protected virtual InvintorySlot addExistingInvintorySlot( InvintorySlot slotToAddTo, int amountToAdd )
        {
            slotToAddTo.amount = Mathf.Clamp(slotToAddTo.amount + amountToAdd, 0, slotToAddTo.item.maxStackSize);
            changeWeight(slotToAddTo.item, amountToAdd);
            return slotToAddTo;
        }

        public virtual void dropItem(InvintorySlot invintorySlot)
        {

        }

        protected virtual void changeWeight(ItemBase pickedUpItem, int amountToAdd)
        {
            currentCarryWeight += (pickedUpItem.carryWeight * amountToAdd);
            OnChangeWeight?.Invoke(currentCarryWeight);
        }

        public bool hasItem(InvintorySlot slotToCheckFor )
        {
            return items.Contains(slotToCheckFor);
        }


        protected void raiseWeightChangeFromChild()
        {
            OnChangeWeight?.Invoke(currentCarryWeight);
        }


#if UNITY_EDITOR

        [ContextMenu("Print Items")]
        protected virtual void printItems()
        {
            print($"{this} Invintory - {items.Count}/{MaxInvintorySlots}");

            foreach (InvintorySlot itemSlot in items)
            {
                print($"{itemSlot.item.displayName}: {itemSlot.amount}");
            }
        }
#endif



        #endregion
    }
}