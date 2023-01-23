using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace MLC.NoManNorth.Eric
{
    public class InvintoryEquipSlot : MonoBehaviour
    {
        #region Variables
        [SerializeField] private InputActionAsset _actions;

        public InputActionAsset actions
        {
            get => _actions;
            set => _actions = value;
        }

        private InputAction MainAttackInputAction { get; set; }

        private float _MainAttackInput;

        [SerializeField] GameObject GameObjectToShow;
        [SerializeField] Transform spawnLocation;

        [SerializeField] private ItemBase equiptedItem;

        [SerializeField] private EventChannelInvintorySlot OnEquipItemChannel;
        #endregion

        #region Unity Methods

        private void Start()
        {
            OnEquipItemChannel.OnEvent += EquipItem_OnEvent;

            if (actions == null)
            {
                return;
            }


            MainAttackInputAction = actions.FindAction("MainAttack");
            
            if (MainAttackInputAction != null)
            {
                
                MainAttackInputAction.started += useEquipmentSlotPrimaryMode;
            }
            MainAttackInputAction.Enable();
        }

        private void OnDestroy()
        {
            OnEquipItemChannel.OnEvent -= EquipItem_OnEvent;
            if (MainAttackInputAction != null)
            {
                MainAttackInputAction.started -= useEquipmentSlotPrimaryMode;
            }
        }

        private void EquipItem_OnEvent(InvintorySlot item)
        {
            if (item == null)
            {
                equiptedItem = null;
                return;
            }
            equiptedItem = item.item;
        }

        #endregion

        #region Methods

        [ContextMenu("Test Use Equipment")]
        private void useEquipmentSlotPrimaryMode(InputAction.CallbackContext context)
        {
            if (equiptedItem as ItemBaseMainUsable)
            {
                //(equiptedItem as ItemBaseMainUsable).PrimaryUse(this.gameObject, spawnLocation);
                return;
            }
        }

        #endregion
    }
}