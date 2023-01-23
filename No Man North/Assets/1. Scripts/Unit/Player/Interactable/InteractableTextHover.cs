using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

namespace MLC.NoManNorth.Eric
{
    public class InteractableTextHover : MonoBehaviour
    {
        #region Variables

        [SerializeField] private TMP_Text displayText;
        [SerializeField] private EventChannelInteratable OnHover;
        [SerializeField] private EventChannelInteratable OnHoverLost;

        #endregion

        #region Unity Methods

        private void OnEnable()
        {
            OnHover.OnEvent += OnHover_OnEvent;
            OnHoverLost.OnEvent += OnHoverLost_OnEvent;
        }

        private void OnDisable()
        {
            OnHover.OnEvent -= OnHover_OnEvent;
            OnHoverLost.OnEvent -= OnHoverLost_OnEvent;
        }

        #endregion

        #region Methods



        private void OnHover_OnEvent(Interactable hoveredObject)
        {
            if (hoveredObject.displayNameOnHover == true)
            {
                displayText.text = hoveredObject.getDisplayName();

                if (hoveredObject as InteracrableRequireItem)
                {
                    displayText.text += "\n" + (hoveredObject as InteracrableRequireItem).requiredItem.displayName;                 
                }
                
            }


        }

        private void OnHoverLost_OnEvent(Interactable obj)
        {
            displayText.text = "";
        }

 

        #endregion
    }
}