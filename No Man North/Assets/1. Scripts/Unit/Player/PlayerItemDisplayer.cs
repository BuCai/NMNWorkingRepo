using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class PlayerItemDisplayer : MonoBehaviour
    {
        #region Variables

        public static PlayerItemDisplayer Instance { get; private set; }

        [SerializeField] private GameObject HandLocation;
        [SerializeField] private GameObject[] DisplayGameObjects;
        [SerializeField] private GameObject[] DisplayGameObjectsInHand;

        private GameObject backpackParent;
        [SerializeField] private GameObject Backpack;
        [SerializeField] private GameObject BackpackLocationInInvintory;

        private GameObject handItem;


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

            foreach (GameObject obj in DisplayGameObjects)
            {
                obj.SetActive(false);
            }

            foreach (GameObject obj in DisplayGameObjectsInHand)
            {
                obj.SetActive(false);
            }

            backpackParent = Backpack.transform.parent.gameObject;
        }

        #endregion

        #region Methods

        public void setObjectToHandLocation( GameObject handItemToDisplay)
        {
            if (handItemToDisplay == null) return; 
            handItem = handItemToDisplay;
            handItem.transform.parent = HandLocation.transform;
            handItem.transform.localPosition = Vector3.zero;
        }

        public void hideHandObject()
        {
            if (handItem == null) return;

            handItem.SetActive(false);
            handItem = null;
        }

        public void equipOntoBackpack(string modelPrefabName)
        {
            foreach (GameObject obj in DisplayGameObjects)
            {
                if (modelPrefabName == obj.name)
                {
                    obj.SetActive(true);
                }
            }
        }

        public void removeFromBackPack(string modelPrefabName)
        {
            foreach (GameObject obj in DisplayGameObjects)
            {
                if (modelPrefabName == obj.name)
                {
                    obj.SetActive(false);
                }
            }
        }

        public void equipToHands(string modelPrefabName)
        {
            foreach (GameObject obj in DisplayGameObjectsInHand)
            {
                if (modelPrefabName == obj.name)
                {
                    obj.SetActive(true);
                }
            }
        }

        public void removeFromHands(string modelPrefabName)
        {
            foreach (GameObject obj in DisplayGameObjectsInHand)
            {
                if (modelPrefabName == obj.name)
                {
                    obj.SetActive(false);
                }
            }
        }

        public void OpenInvintory()
        {
            Backpack.transform.SetParent(BackpackLocationInInvintory.transform);
            Backpack.transform.localPosition = Vector3.zero;
            Backpack.transform.localRotation = Quaternion.identity;
            
        }

        public void CloseInvintory()
        {
            Backpack.transform.SetParent(backpackParent.transform);
            Backpack.transform.localPosition = Vector3.zero;
            Backpack.transform.localRotation = Quaternion.identity;
        }

        #endregion
    }
}