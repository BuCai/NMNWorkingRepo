using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace MLC.NoManNorth.Eric
{
    public class InvintoryPlayer : Invintory
    {
        #region Variables
        public static InvintoryPlayer Instance { get; private set; }

        [SerializeField] private InputActionAsset _actions;

        public InputActionAsset actions
        {
            get => _actions;
            set => _actions = value;
        }
        private InputAction PrimaryItemUseInputAction { get; set; }
        private InputAction SecondaryItemUseAction { get; set; }

        private InputAction MainHandEquipInputAction { get; set; }
        private InputAction OffHandEquipInputAction { get; set; }
        private InputAction QuickUseOneEquipInputAction { get; set; }
        private InputAction QuickUseTwoEquipInputAction { get; set; }

        [SerializeField] private EventChannelInvintorySlot OnEquipMainWeapon;

        [SerializeField] private EventChannelInvintorySlot OnPickUpItem;
        [SerializeField] private EventChannelInvintorySlot OnDropItem;

        [SerializeField] private EventChannelInvintorySlot OnAddItemToUI;

        [SerializeField] private GameObject ItemPrefab;

        private ItemBase equiptedItem;

        private InvintorySlot heldItem;

        private InvintorySlot mainHandItem;
        private InvintorySlot OffHandItem;
        private InvintorySlot quickUseOneItem;
        private InvintorySlot quickUseTwoItem;
        #endregion

        #region Unity Methods

        protected override void Start()
        {
            base.Start();
            if (OnPickUpItem != null)
            {
                OnPickUpItem.OnEvent += OnPickUpItem_OnEvent;
            }

            //set up inputs
            // Primary item use
            PrimaryItemUseInputAction = actions.FindAction("PrimaryItemUse");

            if (PrimaryItemUseInputAction != null)
            {
                PrimaryItemUseInputAction.started += PrimaryItemInputAction_started; ;
            }
            PrimaryItemUseInputAction.Enable();

            //secoundary item use
            SecondaryItemUseAction = actions.FindAction("SecondaryItemUse");

            if (SecondaryItemUseAction != null)
            {
                SecondaryItemUseAction.started += SecondaryItemUseAction_started; ;
            }
            SecondaryItemUseAction.Enable();

            //Equip main hand

            MainHandEquipInputAction = actions.FindAction("EquipMainHandItem");

            if (MainHandEquipInputAction != null)
            {
                MainHandEquipInputAction.started += MainHandEquipInputAction_started;
            }
            MainHandEquipInputAction.Enable();

            //Equip off hand

            OffHandEquipInputAction = actions.FindAction("EquipOffHandItem");

            if (OffHandEquipInputAction != null)
            {
                OffHandEquipInputAction.started += OffHandEquipInputAction_started;
            }
            OffHandEquipInputAction.Enable();

            //Equip Quick Select One

            QuickUseOneEquipInputAction = actions.FindAction("EquipQuickSelectOne");

            if (QuickUseOneEquipInputAction != null)
            {
                QuickUseOneEquipInputAction.started += QuickUseOneEquipInputAction_started;
            }
            QuickUseOneEquipInputAction.Enable();

            //Equip Quick Select Two

            QuickUseTwoEquipInputAction = actions.FindAction("EquipQuickSelectTwo");

            if (QuickUseTwoEquipInputAction != null)
            {
                QuickUseTwoEquipInputAction.started += QuickUseTwoEquipInputAction_started;
            }
            QuickUseTwoEquipInputAction.Enable();

        }

        public MeleeAttackType getDamageTypeOfCurrentEquiptedItem()
        {
            if (equiptedItem == null) return 0;

            if (equiptedItem as ItemMeleeWeapon)
            {
                return ((ItemMeleeWeapon)equiptedItem).MeleeAttackType;
            }
            return 0;
        }

        public float getAttackDamageOfCurrentEquiptedItem()
        {
            if (equiptedItem == null) return 1;

            if (equiptedItem as ItemMeleeWeapon)
            {
                return ((ItemMeleeWeapon)equiptedItem).damage;
            }
            return 1;
        }

        protected override void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(this);
            }
            else
            {
                Instance = this;
            }
            base.Awake();
        }

        private void OnDestroy()
        {
            if (OnPickUpItem != null)
            {
                OnPickUpItem.OnEvent -= OnPickUpItem_OnEvent;
            }
        }

        #endregion

        #region Methods

        public float getCarryWeightLimit()
        {
            return maxCarryWeightBeforeEncumbered;
        }

        public bool useItem(ItemBase usedItem)
        {
            if (mainHandItem != null && mainHandItem.item == usedItem)
            {
                mainHandItem.amount--;
                changeWeight(mainHandItem.item, -1);
                

                UIInvintoryManger.Instance.updateUImanager(mainHandItem);
                return true;
            }

            if (OffHandItem != null && OffHandItem.item == usedItem)
            {
                OffHandItem.amount--;
                changeWeight(OffHandItem.item, -1);
                

                UIInvintoryManger.Instance.updateUImanager(OffHandItem);
                return true;
            }

            if (quickUseOneItem != null && quickUseOneItem.item == usedItem)
            {
                quickUseOneItem.amount--;
                changeWeight(quickUseOneItem.item, -1);
                

                UIInvintoryManger.Instance.updateUImanager(quickUseOneItem);
                return true;
            }

            if (quickUseTwoItem != null && quickUseTwoItem.item == usedItem)
            {
                quickUseTwoItem.amount--;
                changeWeight(quickUseTwoItem.item, -1);
                

                UIInvintoryManger.Instance.updateUImanager(quickUseTwoItem);
                return true;
            }

            foreach (InvintorySlot slot in items)
            {
                if (slot != null && slot.item == usedItem)
                {
                    slot.amount--;
                    changeWeight( slot.item, -1 );
                    if (slot.amount == 0)
                    {
                        items.Remove(slot);
                    }

                    UIInvintoryManger.Instance.updateUImanager(slot);
                    return true;
                }
            }

            return false;
        }

        private void OnPickUpItem_OnEvent(InvintorySlot pickedUpItem)
        {
            if ( pickedUpItem.item as ItemCarryOnly )
            {
                addItemToHand(pickedUpItem);
                return;
            }

            addItemToInvintory(pickedUpItem);
        }

        private void addItemToHand(InvintorySlot pickedUpItem)
        {
            heldItem = pickedUpItem;

            Instantiate(pickedUpItem.item.modelPrefab, NoManNorthThirdPersonCharacterController.Instance.heldItemRoot.transform);
        }

        private void removeItemFromHand()
        {
            dropItem(heldItem);
            heldItem = null;
        }

        protected override InvintorySlot addNewItem(ItemBase pickedUpItem, int amountToAdd)
        {

            InvintorySlot outPut = base.addNewItem(pickedUpItem, amountToAdd);

            UIInvintoryManger.Instance.updateUImanager(outPut);

            OnAddItemToUI.RaiseEvent(outPut);

            return outPut;
        }

        protected override InvintorySlot addExistingInvintorySlot(InvintorySlot slotToAddTo, int amountToAdd)
        {
            InvintorySlot outPut = base.addExistingInvintorySlot(slotToAddTo, amountToAdd);

            UIInvintoryManger.Instance.updateUImanager(outPut);

            return outPut;
        }


        public int getMaxNumberOfInvintory()
        {
            return MaxInvintorySlots;
         }

        public override void dropItem(InvintorySlot invintorySlot)
        {
            if (items.Contains(invintorySlot) )
            {
                items.Remove(invintorySlot);
            }

            changeWeight(invintorySlot.item, -1 * invintorySlot.amount);
            ItemPickUp droppedItem = Instantiate(ItemPrefab,getDropLocation(), this.transform.rotation).GetComponent<ItemPickUp>();
            droppedItem.setItemSlot(invintorySlot);
            
            UIInvintoryManger.Instance.updateUImanager(invintorySlot);
            //set up droppedItem is set on start

            Vector3 getDropLocation()
            {
                if (GameStateManager.Instance.CurrentPlayerState == PlayerState.Third)
                {
                    return NoManNorthThirdPersonCharacterController.Instance.dropLocation.transform.position;
                }

                return Vector3.zero;
            }
        }

        public bool equipItem(EquimentSlot slotToAddTo, InvintorySlot slotEquiping, int quickSlot = 0)
        {
            //if its not found in the items return
           
            if (items.Contains(slotEquiping) == false )
            {
                //swapping quick use items equipment slot
                if (slotToAddTo == EquimentSlot.QuickUse)
                {
                    if (quickUseOneItem == slotEquiping && quickSlot == 2 )
                    {
                        var temp = quickUseTwoItem;
                        quickUseTwoItem = quickUseOneItem;
                        quickUseOneItem = temp;
                        return true;
                    }

                    if (quickUseTwoItem == slotEquiping && quickSlot == 1)
                    {
                        var temp = quickUseTwoItem;
                        quickUseTwoItem = quickUseOneItem;
                        quickUseOneItem = temp;
                        return true;
                    }

                    return false;
                }
            }
            
            //equiping from items

            if (slotToAddTo == EquimentSlot.MainHand)
            {
                mainHandItem = slotEquiping;
                PlayerItemDisplayer.Instance.equipOntoBackpack(mainHandItem.item.modelPrefab.name);
                items.Remove(slotEquiping);
                return true;
            }

            if (slotToAddTo == EquimentSlot.OffHand)
            {
                OffHandItem = slotEquiping;
                PlayerItemDisplayer.Instance.equipOntoBackpack(OffHandItem.item.modelPrefab.name);
                items.Remove(slotEquiping);
                return true;
            }

            if (slotToAddTo == EquimentSlot.QuickUse && quickSlot == 1)
            {
                quickUseOneItem = slotEquiping;
                items.Remove(slotEquiping);
                return true;
            }

            if (slotToAddTo == EquimentSlot.QuickUse && quickSlot == 2)
            {
                quickUseTwoItem = slotEquiping;
                items.Remove(slotEquiping);
                return true;
            }

            return false;
        }

        public void unEquipItem(EquimentSlot slotToAddTo, InvintorySlot invintorySlot, int quickSlot = 0)
        {
            

            if (slotToAddTo == EquimentSlot.MainHand)
            {
                PlayerItemDisplayer.Instance.removeFromBackPack(mainHandItem.item.modelPrefab.name);
                PlayerItemDisplayer.Instance.removeFromHands(mainHandItem.item.modelPrefab.name);
                mainHandItem = null;
                
                return;
            }

            if (slotToAddTo == EquimentSlot.OffHand)
            {
                PlayerItemDisplayer.Instance.removeFromBackPack(OffHandItem.item.modelPrefab.name);
                PlayerItemDisplayer.Instance.removeFromHands(OffHandItem.item.modelPrefab.name);
                OffHandItem = null;
                
                return;
            }

            if (slotToAddTo == EquimentSlot.QuickUse && quickSlot == 1)
            {
                quickUseOneItem = null;
                
                return;
            }

            if (slotToAddTo == EquimentSlot.QuickUse && quickSlot == 2)
            {
                quickUseTwoItem = null;
                
                return ;
            }
        }

        public void addItemFromEquipedSlot(InvintorySlot slotToAddToItems)
        {
            items.Add(slotToAddToItems);
        }

        public void addItemFromContainer(InvintorySlot slotToAddToItems)
        {
            items.Add(slotToAddToItems);
            changeWeight(slotToAddToItems.item,slotToAddToItems.amount);
        }

        private void PrimaryItemInputAction_started(InputAction.CallbackContext obj)
        {
            if (equiptedItem == null) return;

            if (equiptedItem as ItemBaseTwoHandedHeld)
            {
                print("This is a carry Item");
                return;
            }

            if (equiptedItem as ItemBaseMainUsable)
            {
                (equiptedItem as ItemBaseMainUsable).PrimaryUse(this.gameObject, NoManNorthThirdPersonCharacterController.Instance.gameObject.transform);
                return;
            }
        }

        private void SecondaryItemUseAction_started(InputAction.CallbackContext obj)
        {
            if (equiptedItem == null) return;

            if (equiptedItem as ItemBaseTwoHandedHeld)
            {
                print("This is a carry Item");
                return;
            }

            if (equiptedItem as ItemBaseMainAndSecoundaryUsable)
            {
                (equiptedItem as ItemBaseMainAndSecoundaryUsable).SecondaryUse(this.gameObject, NoManNorthThirdPersonCharacterController.Instance.gameObject.transform);
                return;
            }
        }
        private void MainHandEquipInputAction_started(InputAction.CallbackContext obj)
        {
            if (mainHandItem != null)
            {
                if (equiptedItem != null )
                {
                    PlayerItemDisplayer.Instance.equipOntoBackpack(equiptedItem.modelPrefab.name);
                    PlayerItemDisplayer.Instance.removeFromHands(equiptedItem.modelPrefab.name);
                }


                equiptedItem = mainHandItem.item;
                PlayerItemDisplayer.Instance.removeFromBackPack(equiptedItem.modelPrefab.name);
                PlayerItemDisplayer.Instance.equipToHands(equiptedItem.modelPrefab.name);
            }
            else
            {
                equiptedItem = null;
            }
        }

        private void OffHandEquipInputAction_started(InputAction.CallbackContext obj)
        {
            if (OffHandItem != null)
            {
                if (equiptedItem != null)
                {
                    PlayerItemDisplayer.Instance.equipOntoBackpack(equiptedItem.modelPrefab.name);
                    PlayerItemDisplayer.Instance.removeFromHands(equiptedItem.modelPrefab.name);
                }


                equiptedItem = OffHandItem.item;
                PlayerItemDisplayer.Instance.removeFromBackPack(equiptedItem.modelPrefab.name);
                PlayerItemDisplayer.Instance.equipToHands(equiptedItem.modelPrefab.name);
            }
            else
            {
                equiptedItem = null;
            }
        }

        private void QuickUseOneEquipInputAction_started(InputAction.CallbackContext obj)
        {
            if (quickUseOneItem != null)
            {
                equiptedItem = quickUseOneItem.item;
            }
            else
            {
                equiptedItem = null;
            }
        }

        private void QuickUseTwoEquipInputAction_started(InputAction.CallbackContext obj)
        {
            if (quickUseTwoItem != null)
            {
                equiptedItem = quickUseTwoItem.item;
            }
            else
            {
                equiptedItem = null;
            }
        }


#if UNITY_EDITOR
        [ContextMenu("Print Items Player")]
        protected override void printItems()
        {
            base.printItems();
            if (mainHandItem != null)
            {
                print($"Equipted Items - Main Hand {mainHandItem.item.name}");
            }
            if (OffHandItem != null)
            {
                print($"Equipted Items - Off Hand {OffHandItem.item.name}");
            }
            if (quickUseOneItem != null)
            {
                print($"Equipted Items - quickUseOne {quickUseOneItem.item.name}");
            }
            if (quickUseTwoItem != null)
            {
                print($"Equipted Items - Main Hand {quickUseTwoItem.item.name}");
            }
        }

#endif

        #endregion
    }
}