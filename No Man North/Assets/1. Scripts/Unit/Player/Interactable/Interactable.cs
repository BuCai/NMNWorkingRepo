using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace MLC.NoManNorth.Eric
{

    public class Interactable : MonoBehaviour
    {



        #region Variables
        [SerializeField] private string displayName;
        [SerializeField] private string displayNameModifier;

        [SerializeField] public bool canOnlyActivateOnce = false;
        private bool hasActivatedOnce = false;

        [SerializeField] private Animator InteractableOnHover;

        [field: SerializeField] public bool displayNameOnHover { get; private set; } = true;

        [SerializeField] private bool isInteratable = true;
        
        [SerializeField] private UnityEvent OnActive;

        [field: SerializeField] public string AnimationToPlay { private set; get; }

        #endregion

        #region Unity Methods

        private void OnEnable()
        {
            
        }

        #endregion

        #region Methods

        private float lastActivated;
        private float coolDown = .2f;
        public void Interact()
        {
            if (enabled == false)
            {
                return;
            }

            if(isInteratable == false || (canOnlyActivateOnce == true && hasActivatedOnce == true)  || lastActivated + coolDown > Time.time )
            {
                return;
            }

                       
            ActiveInteract();
            hasActivatedOnce = true;

            lastActivated = Time.time;
        }

        public string getDisplayName()
        {
            return displayName + " " + displayNameModifier;
        }

        public void setDisplayName(string displayNameIn)
        {
            displayName = displayNameIn;
        }

        public void setDisplayNameModifier(string displayModifierNameIn)
        {
            displayNameModifier = displayModifierNameIn;
        }

        public void setInteractable(bool state)
        {
            isInteratable = state;
        }

        public bool getInteractable()
        {
            return isInteratable;
        }

        protected virtual void ActiveInteract()
        {
            if (AnimationToPlay == "")
            {
                OnActive.Invoke();
            }
        }

        public void invokeOnInteract()
        {
            OnActive.Invoke();
        }

        public void isHovered()
        {
            if (InteractableOnHover != null)
            {
                InteractableOnHover.SetBool("IsOpen", true);
            }
        }

        public void stoppedHovered()
        {
            if (InteractableOnHover != null)
            {
                InteractableOnHover.SetBool("IsOpen", false);
            }
        }

        #endregion
    }
}