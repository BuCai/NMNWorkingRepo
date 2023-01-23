using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace MLC.NoManNorth.Eric
{
    public class UIInvintorySlot : MonoBehaviour, IDragHandler, IEndDragHandler, IBeginDragHandler
    {
        #region Variables
        [SerializeField] private InputActionAsset actions;
        [SerializeField] private Sprite emptyIcon;
        private InputAction mousePosition;


        private InvintorySlot heldItem;
        [SerializeField] private Image invintoryIcon;
        [SerializeField] private Color initialColor;
        [SerializeField] private Color dragColor;
        [SerializeField] private GameObject gameObjectStackAmount;
        [SerializeField] private TMP_Text textStackAmount;
        #endregion

        #region Unity Methods

        private void Awake()
        {
            mousePosition = actions.FindAction("Mouse Position");
            mousePosition.Enable();

            //invintoryIcon.sprite = emptyIcon;

            if (heldItem == null)
            {
                gameObjectStackAmount.SetActive(false);
            }
        }

        #endregion

        #region Methods

        public void addItemToSlot(InvintorySlot newHeldItem)
        {
            if (newHeldItem == null)
            {
                gameObjectStackAmount.SetActive(false);
                return;
            }

            heldItem = newHeldItem;
            invintoryIcon.sprite = heldItem.item.ui_Icon;

            if (heldItem.item.maxStackSize != 1)
            {
                gameObjectStackAmount.SetActive( true );
                textStackAmount.text = heldItem.amount.ToString();
            }
            else
            {
                gameObjectStackAmount.SetActive(false);
                textStackAmount.text = "";
            }

        }

        public InvintorySlot getHeldItem()
        {
            return heldItem;
        }

        public bool isEmpty()
        {
            if (heldItem == null)
            {
                return true;
            }
            return false;
        }

        public void clear()
        {
            heldItem = null;
            invintoryIcon.sprite = emptyIcon;
            
            textStackAmount.text = "";
        }

        public void updateAmount()
        {
            if (heldItem.item.maxStackSize != 1)
            {
                gameObjectStackAmount.SetActive(true);
                textStackAmount.text = heldItem.amount.ToString();
            }
        }

        public void OnBeginDrag(PointerEventData eventData)
        {
            if (heldItem == null) return;

            invintoryIcon.color = dragColor;

            invintoryIcon.transform.SetParent(UIInvintoryManger.Instance.getSelectedItemRoot());
        }

        public void OnDrag(PointerEventData eventData)
        {
            if (heldItem == null) return;
            
            invintoryIcon.transform.position = mousePosition.ReadValue<Vector2>();
        }

        public void OnEndDrag(PointerEventData eventData)
        {
            if (heldItem == null) return;

            invintoryIcon.transform.SetParent(this.transform);

            invintoryIcon.color = initialColor;
            invintoryIcon.transform.localPosition = Vector3.zero; 

            UIInvintoryManger.Instance.OnInvintorySlotDropped(this, mousePosition.ReadValue<Vector2>());
        }

        #endregion
    }
}