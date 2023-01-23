using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class UIInvintoryManger : MonoBehaviour
    {
        #region Variables

        public static UIInvintoryManger Instance { get; private set; }

        [SerializeField] private EventChannelInvintorySlot OnAddedItemToPlayerInvintory;

        [SerializeField] private GameObject UISlotPrefab;
        

        [SerializeField] private Transform selectedItemSlot;

        [SerializeField] private RectTransform playerPanel;
        [SerializeField] private Transform playerHeldItemsRoot;


        [SerializeField] private RectTransform containerPanel;
        [SerializeField] private RectTransform containerHeldItemsRoot;
        private InvintoryContainer currentOpenContainer;
        private List<UIInvintorySlot> containerSlots = new List<UIInvintorySlot>();

        //[SerializeField] private RectTransform uiPanel;

        [SerializeField] private RectTransform uiMainEquip;
        [SerializeField] private RectTransform uiOffHandEquip;
        [SerializeField] private RectTransform uiQuickUseOne;
        [SerializeField] private RectTransform uiQuickUseTwo;

        [SerializeField] private EventChannelInvintorySlot OnEquipItemChannel;

        private UIInvintorySlot[] invitorySlots;
        private UIInvintorySlot[] equiptedSlots;

        #endregion

        #region Unity Methods

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(this);
            }
            else
            {
                Instance = this;
            }
        }

        

        private void Start()
        {
            invitorySlots = new UIInvintorySlot[InvintoryPlayer.Instance.getMaxNumberOfInvintory()];
            equiptedSlots = new UIInvintorySlot[4];
            equiptedSlots[0] = uiMainEquip.GetComponent<UIInvintorySlot>();
            equiptedSlots[1] = uiOffHandEquip.GetComponent<UIInvintorySlot>();
            equiptedSlots[2] = uiQuickUseOne.GetComponent<UIInvintorySlot>();
            equiptedSlots[3] = uiQuickUseTwo.GetComponent<UIInvintorySlot>();

            for (int i = 0; i < invitorySlots.Length; i++)
            {
                GameObject temp = Instantiate( UISlotPrefab, playerHeldItemsRoot);
                if (temp.TryGetComponent<UIInvintorySlot>(out UIInvintorySlot invintorySlot) )
                {
                    invitorySlots[i] = invintorySlot;
                    temp.name = "Invintory Slot -" + i;
                }
            }

            OnAddedItemToPlayerInvintory.OnEvent += OnAddItemToInvintory_OnEvent;

            GameStateManager.Instance.OnPlayerStateChanged += Instance_OnPlayerStateChanged;
            
        }

        private void OnDestroy()
        {
            OnAddedItemToPlayerInvintory.OnEvent -= OnAddItemToInvintory_OnEvent;
            GameStateManager.Instance.OnPlayerStateChanged -= Instance_OnPlayerStateChanged;
        }

        #endregion

        #region Methods

        public void updateUImanager( InvintorySlot slotToUpdate )
        {
            foreach (UIInvintorySlot slot in equiptedSlots)
            {
                if (slot.getHeldItem() == slotToUpdate)
                {
                    if (slot == null || slot.getHeldItem() == null || slot.getHeldItem().amount == 0 )
                    {
                        //print("I was cleared");
                        slot.clear();
                        return;
                    }
                    else
                    {
                        slot.updateAmount();
                        return;
                    }
                }
            }

            foreach (UIInvintorySlot slot in invitorySlots)
            {
                if (slot.getHeldItem() == slotToUpdate)
                {
                    if (slot.getHeldItem().amount == 0 || !InvintoryPlayer.Instance.hasItem(slotToUpdate) )
                    {
                        slot.clear();
                    }
                    else
                    {
                        slot.updateAmount();
                    }
                }
            }
            
        }

        private void OnAddItemToInvintory_OnEvent(InvintorySlot itemToAdd)
        {
            foreach (UIInvintorySlot uiInvintory in invitorySlots)
            {
                if (uiInvintory.isEmpty())
                {
                    uiInvintory.addItemToSlot(itemToAdd);
                    return;
                }
            }
        }

        public Transform getSelectedItemRoot()
        {
            return selectedItemSlot;
        }

        public void OnInvintorySlotDropped(UIInvintorySlot invintroySlotComingFrom, Vector2 mousePosition )
        {
            
            //drop item
            if (!RectTransformUtility.RectangleContainsScreenPoint(playerPanel, mousePosition) && !RectTransformUtility.RectangleContainsScreenPoint(containerPanel, mousePosition)) 
            {
                if (currentOpenContainer != null && currentOpenContainer.items.Contains(invintroySlotComingFrom.getHeldItem()))
                {
                    currentOpenContainer.dropItem(invintroySlotComingFrom.getHeldItem());
                    invintroySlotComingFrom.clear();
                    UpdateContainerUI();
                    return;
                }
                InvintoryPlayer.Instance.dropItem( invintroySlotComingFrom.getHeldItem() ) ;
                UnEquipItem(invintroySlotComingFrom);

                return;
            }
            //equip items
            //Main hand
            if (invintroySlotComingFrom.getHeldItem().item.equimentSlot == EquimentSlot.MainHand && RectTransformUtility.RectangleContainsScreenPoint(uiMainEquip, mousePosition))
            {
                if (uiMainEquip.TryGetComponent<UIInvintorySlot>(out UIInvintorySlot mainEquipmentSlot))
                {
                    AddItemToEquipmentSlot(EquimentSlot.MainHand, mainEquipmentSlot);
                    return;
                }
            }
            //Off hand
            if (invintroySlotComingFrom.getHeldItem().item.equimentSlot == EquimentSlot.OffHand && RectTransformUtility.RectangleContainsScreenPoint(uiOffHandEquip, mousePosition))
            {
                if (uiOffHandEquip.TryGetComponent<UIInvintorySlot>(out UIInvintorySlot offHandSlot))
                {
                    AddItemToEquipmentSlot(EquimentSlot.OffHand, offHandSlot);
                    return;
                }
            }
            //quick use 1
            if (invintroySlotComingFrom.getHeldItem().item.equimentSlot == EquimentSlot.QuickUse && RectTransformUtility.RectangleContainsScreenPoint(uiQuickUseOne, mousePosition))
            {
                if (uiQuickUseOne.TryGetComponent<UIInvintorySlot>(out UIInvintorySlot quickUseOneEquipmentSlot))
                {
                    AddItemToEquipmentSlot(EquimentSlot.QuickUse, quickUseOneEquipmentSlot, 1);
                    return;
                }
            }

            //quick use 2
            if (invintroySlotComingFrom.getHeldItem().item.equimentSlot == EquimentSlot.QuickUse && RectTransformUtility.RectangleContainsScreenPoint(uiQuickUseTwo, mousePosition))
            {
                if (uiQuickUseTwo.TryGetComponent<UIInvintorySlot>(out UIInvintorySlot quickUseTwoSlot))
                {
                    AddItemToEquipmentSlot(EquimentSlot.QuickUse, quickUseTwoSlot, 2);
                    return;
                }
            }

            //Adding To a Container

            if (currentOpenContainer != null && currentOpenContainer.canAddItems == true && RectTransformUtility.RectangleContainsScreenPoint(containerPanel as RectTransform, mousePosition) )
            {
                
                for (int i = 0; i < containerSlots.Count; i++)
                {
                    
                    if (RectTransformUtility.RectangleContainsScreenPoint(containerSlots[i].transform as RectTransform, mousePosition))
                    {
                        //currentOpenContainer
                        swapUISlots(invintroySlotComingFrom, containerSlots[i]);

                        //coming from the play
                        if (!currentOpenContainer.items.Contains( invintroySlotComingFrom.getHeldItem() ))
                        {
                            InvintoryPlayer.Instance.items.Remove(invintroySlotComingFrom.getHeldItem());
                            //if (invintroySlotComingFrom.getHeldItem() != null)
                            //{
                            //    currentOpenContainer.changeWeightContainer(invintroySlotComingFrom.getHeldItem().item, invintroySlotComingFrom.getHeldItem().amount);
                            //}
                        }

                        return;
                    }
                }
            }

            //Add to invintory Slot

            for (int i = 0; i < invitorySlots.Length; i++)
            {
                
                if (RectTransformUtility.RectangleContainsScreenPoint(invitorySlots[i].transform as RectTransform, mousePosition))
                {
                    //coming from an equipment slot need to add the item back to the main invintory
                    for (int j = 0; j < equiptedSlots.Length; j++)
                    {
                        if (equiptedSlots[j] == invintroySlotComingFrom)
                        {
                            print("Coming From equipment");
                            if (equiptedSlots[j].getHeldItem() != null && invitorySlots[i].getHeldItem()!= null)
                            {
                                // swapping items to equipted
                                if (equiptedSlots[j].getHeldItem().item.equimentSlot == invitorySlots[i].getHeldItem().item.equimentSlot)
                                {
                                    bool didEquip = false;
                                    if (equiptedSlots[j].getHeldItem().item.equimentSlot != EquimentSlot.QuickUse)
                                    {
                                        didEquip = InvintoryPlayer.Instance.equipItem(equiptedSlots[j].getHeldItem().item.equimentSlot, invitorySlots[i].getHeldItem());
                                    }
                                    else
                                    {
                                        print("Quick use item");
                                        if (j == 2)
                                        {
                                            didEquip = InvintoryPlayer.Instance.equipItem(equiptedSlots[j].getHeldItem().item.equimentSlot, invitorySlots[i].getHeldItem(),1);
                                        }
                                        if (j == 3)
                                        {
                                            didEquip = InvintoryPlayer.Instance.equipItem(equiptedSlots[j].getHeldItem().item.equimentSlot, invitorySlots[i].getHeldItem(), 2);
                                        }
                                        
                                    }
                                    
                                    if (didEquip == false) return;
                                    print("Can swap");
                                    InvintoryPlayer.Instance.addItemFromEquipedSlot(invintroySlotComingFrom.getHeldItem());
                                    swapUISlots(invintroySlotComingFrom, invitorySlots[i]);
                                    return;
                                }
                                else // cant swap item
                                {
                                    print("not swapping");
                                    return;
                                }
                            }
                            
                            InvintoryPlayer.Instance.addItemFromEquipedSlot(equiptedSlots[j].getHeldItem());
                            UnEquipItem(invintroySlotComingFrom);
                            break;
                        }
                    }

                    //coming from the open container
                    if (containerSlots.Contains(invintroySlotComingFrom))
                    {
                        print("coming from opened container");
                        //do not swap if the slot is full and the contaier does not allow adding
                        if (currentOpenContainer.canAddItems == false && invitorySlots[i].getHeldItem() != null)
                        {
                            print("Cant swap into this container");
                            return;
                        }
                        if (invitorySlots[i].getHeldItem() == null)
                        {
                            InvintoryPlayer.Instance.addItemFromContainer(invintroySlotComingFrom.getHeldItem());
                            
                            currentOpenContainer.removeItem(invintroySlotComingFrom.getHeldItem());
                            
                            swapUISlots(invintroySlotComingFrom, invitorySlots[i]);
                            UpdateContainerUI();

                            return;
                        }

                    }

                    //print($"Swapping {slot.name} into slot:{invitorySlots[i].name}");

                    swapUISlots(invintroySlotComingFrom, invitorySlots[i]);



                    if (uiMainEquip.TryGetComponent<UIInvintorySlot>(out UIInvintorySlot mainEquipmentSlot))
                    {
                        if (mainEquipmentSlot == invintroySlotComingFrom) 
                        {
                            OnEquipItemChannel.RaiseEvent(null);
                        }
                    }

                    return;
                }
                
            }

            void swapUISlots(UIInvintorySlot first, UIInvintorySlot secound)
            {
                InvintorySlot temp = first.getHeldItem();
                first.clear();
                first.addItemToSlot(secound.getHeldItem());

                secound.clear();
                secound.addItemToSlot(temp);
            }

            void AddItemToEquipmentSlot(EquimentSlot slotToAddTo, UIInvintorySlot slotToEqupTo, int quickSlotIndes = 0)
            {
                if ( ! InvintoryPlayer.Instance.equipItem(slotToAddTo, invintroySlotComingFrom.getHeldItem(), quickSlotIndes )) return; 

                
                InvintorySlot temp = invintroySlotComingFrom.getHeldItem();

                invintroySlotComingFrom.clear();
                invintroySlotComingFrom.addItemToSlot(slotToEqupTo.getHeldItem());

                slotToEqupTo.clear();
                slotToEqupTo.addItemToSlot(temp);

                OnEquipItemChannel.RaiseEvent(slotToEqupTo.getHeldItem());
            }

            void UnEquipItem(UIInvintorySlot invintorySlotToCheckFor)
            {
                //main hand
                if (equiptedSlots[0] == invintorySlotToCheckFor)
                {
                    InvintoryPlayer.Instance.unEquipItem(EquimentSlot.MainHand, invintorySlotToCheckFor.getHeldItem());
                }
                //off hand
                if (equiptedSlots[1] == invintorySlotToCheckFor)
                {
                    InvintoryPlayer.Instance.unEquipItem(EquimentSlot.OffHand, invintorySlotToCheckFor.getHeldItem());
                }
                // quick use one
                if (equiptedSlots[2] == invintorySlotToCheckFor)
                {
                    InvintoryPlayer.Instance.unEquipItem(EquimentSlot.QuickUse, invintorySlotToCheckFor.getHeldItem(), 1);
                }
                //quick use two
                if (equiptedSlots[3] == invintorySlotToCheckFor)
                {
                    InvintoryPlayer.Instance.unEquipItem(EquimentSlot.QuickUse, invintorySlotToCheckFor.getHeldItem(), 2);
                }
            }

        }


        public void OnOpenContainer_OnEvent(InvintoryContainer openingContainer)
        {
            if (currentOpenContainer != null) return;

            currentOpenContainer = openingContainer;
            if (currentOpenContainer == null) return;
            if (currentOpenContainer.items.Count == 0 && currentOpenContainer.canAddItems == false) return;

            if (currentOpenContainer.canAddItems == true)
            {
                for (int i = 0; i < currentOpenContainer.maxItems; i++)
                {
                    GameObject temp = Instantiate(UISlotPrefab, containerHeldItemsRoot);
                    if (temp.TryGetComponent<UIInvintorySlot>(out UIInvintorySlot invintorySlot))
                    {
                        containerSlots.Add(invintorySlot);
                        temp.name = "Invintory Slot -" + i;
                        if (i < currentOpenContainer.items.Count)
                        {
                            invintorySlot.addItemToSlot(currentOpenContainer.items[i]);
                        }
                    }
                }

            }
            else
            {
                for (int i = 0; i < currentOpenContainer.items.Count; i++)
                {
                    GameObject temp = Instantiate(UISlotPrefab, containerHeldItemsRoot);
                    if (temp.TryGetComponent<UIInvintorySlot>(out UIInvintorySlot invintorySlot))
                    {
                        containerSlots.Add(invintorySlot);
                        invintorySlot.addItemToSlot(currentOpenContainer.items[i]);
                        temp.name = "Invintory Slot -" + i;
                    }
                }
            }

            containerPanel.gameObject.SetActive(true);
        }

        
        public void CloseContainer()
        {
            //should pool these instead of destroy create them/but this is faster to create
            for (int i = containerSlots.Count - 1; i >= 0; i--)
            {
                var temp = containerSlots[i];
                containerSlots.Remove( containerSlots[i] );
                Destroy(temp.gameObject);
            }

            currentOpenContainer = null;
            containerPanel.gameObject.SetActive(false);
        }

        private void UpdateContainerUI()
        {
            if (currentOpenContainer == null) return;

            if (currentOpenContainer.canAddItems == false)
            {
                
                for (int i = containerSlots.Count -1; i >= 0; i--)
                {
                    
                    if (containerSlots[i].getHeldItem() == null)
                    {
                        var temp = containerSlots[i];
                        containerSlots.Remove(temp);
                        Destroy(temp.gameObject);
                    }
                }
            }


            if (containerSlots.Count == 0)
            {
                CloseContainer();
            }
        }

        private void Instance_OnPlayerStateChanged(PlayerState newPlayerState)
        {
            if ( newPlayerState == PlayerState.First )
            {
                uiMainEquip.transform.gameObject.SetActive(true);
                uiOffHandEquip.transform.gameObject.SetActive(true);
            }
            if (newPlayerState == PlayerState.Third)
            {
                uiMainEquip.transform.gameObject.SetActive(false);
                uiOffHandEquip.transform.gameObject.SetActive(false);
            }
        }

        #endregion
    }
}