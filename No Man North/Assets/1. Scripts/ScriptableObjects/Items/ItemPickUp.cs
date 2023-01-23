using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric {
    [SelectionBase]
    public class ItemPickUp : MonoBehaviour {
        #region Variables
        [SerializeField] private EventChannelInvintorySlot OnPlayerPickUp;
        [SerializeField] private LayerMask groundMask;

        [SerializeField] private InvintorySlot invintorySlot;
        [SerializeField] private ItemBase initilizationItem;

        [SerializeField] private GameObject modelRoot;
        [SerializeField] private Interactable interactable;
        [SerializeField] private BoxCollider interactableCollider;
        #endregion

        #region Unity Methods

        private void Start() {
            if (initilizationItem != null) {
                setUp();
            }

        }

        private void OnValidate() {
            invintorySlot.item = null;
            invintorySlot.amount = 0;
#if UNITY_EDITOR
            if (modelRoot.transform.childCount > 0) {

                foreach (Transform child in modelRoot.transform) {
                    UnityEditor.EditorApplication.delayCall += () => {
                        if (child != null) {
                            DestroyImmediate(child.gameObject);
                        }

                    };

                }
            }
#endif
            setUp();

        }

        #endregion

        #region Methods

        public void setItemSlot(InvintorySlot invintoryItem) {
            if (invintoryItem == null) return;

            initilizationItem = invintoryItem.item;
            invintorySlot.item = invintoryItem.item;
            invintorySlot.amount = invintoryItem.amount;

            setUp();
        }

        public void setUp() {

            if (initilizationItem != null && invintorySlot.item != initilizationItem) {
                invintorySlot.item = initilizationItem;
                invintorySlot.amount = initilizationItem.initialStackSize;
            }

            interactable.setDisplayName(invintorySlot.item.displayName);
            GameObject.Instantiate(invintorySlot.item.modelPrefab, modelRoot.transform);
            setBoundingBox();

            moveItemToGround();

            name = $"Item pick up - {initilizationItem.displayName}";

            //Sets the hit box collider to the size of the game objects.
            void setBoundingBox() {
                var childColliders = modelRoot.GetComponentsInChildren<MeshRenderer>();
                Vector3 tempSize = Vector3.zero;

                foreach (var c in childColliders) {

                    if (c.bounds.size.x > tempSize.x) {
                        tempSize.x = c.bounds.size.x;
                    }
                    if (c.bounds.size.y > tempSize.y) {
                        tempSize.y = c.bounds.size.y;
                    }
                    if (c.bounds.size.z > tempSize.z) {
                        tempSize.z = c.bounds.size.z;
                    }
                }

                interactableCollider.center = new Vector3(0, tempSize.y * .5f, 0);
                interactableCollider.size = tempSize;
            }
        }

        public void moveItemToGround() {
            if (Physics.Raycast(transform.position, Vector3.down, out var groundHit, 100f, groundMask)) {
                this.transform.position = groundHit.point;
            }
        }

        public void AddToPlayerInvintory() {
            PlayerItemDisplayer.Instance.setObjectToHandLocation(modelRoot);

            OnPlayerPickUp?.RaiseEvent(invintorySlot);
        }

        public InvintorySlot getInvintory() {
            return invintorySlot;
        }



        #endregion
    }
}