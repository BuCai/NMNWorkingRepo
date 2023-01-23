using Micosmo.SensorToolkit;

using UnityEngine;
using UnityEngine.InputSystem;

namespace MLC.NoManNorth.Eric
{
    public class PlayerInteractor : MonoBehaviour
    {
        #region Variables

        [SerializeField] private InputActionAsset actions;
        private InputAction interactButton;

        [SerializeField] private RaySensor sensor;

        [SerializeField] private EventChannelInteratable OnHover;
        [SerializeField] private EventChannelInteratable OnHoverLost;

        [SerializeField] private Animator characterAnimator;

        private Interactable currentHoveredInteract;
        private Interactable currentAnimatingInteract;
        #endregion

        #region Unity Methods

        private void Awake()
        {
            sensor.OnDetected.AddListener(OnDetectedInteratable);
            sensor.OnLostDetection.AddListener(OnLostInteratable);

            interactButton = actions.FindAction("InteractWithObject");
            if (interactButton != null)
            { 
                interactButton.started += interactButtonPress;
            }

            interactButton.Enable();
        }

        private void OnDestroy()
        {
            sensor.OnDetected.RemoveListener(OnDetectedInteratable);
            sensor.OnLostDetection.RemoveListener(OnLostInteratable);

            if (interactButton != null)
            {
                interactButton.started -= interactButtonPress;
            }
        }

        #endregion

        #region Methods

        private void interactButtonPress(InputAction.CallbackContext obj)
        {
            if (currentHoveredInteract != null /*&& GameStateManager.Instance.CurrentGameState == GameState.Gameplay*/ )
            {
                if (currentHoveredInteract.AnimationToPlay == "")
                {
                    currentHoveredInteract.Interact();
                }
                else
                {
                    currentAnimatingInteract = currentHoveredInteract;

                    
                    characterAnimator.SetTrigger(currentAnimatingInteract.AnimationToPlay);

                    //should pause player input here then unpause then either inturupted or completed

                    //waits for the animation reach a certain point to call on animation invoke

                }


            }
        }



        public void OnAnimationFireInteract()
        {
            if (currentAnimatingInteract != null) currentAnimatingInteract.invokeOnInteract();

            currentAnimatingInteract = null;
        }

        private void OnDetectedInteratable(GameObject detectedObject, Micosmo.SensorToolkit.Sensor sensor)
        {
            if (currentHoveredInteract != null)
            {
                return;
            }

            if( detectedObject.TryGetComponent<Interactable>(out Interactable interactedObject) )
            {
                if (interactedObject.enabled == true && interactedObject.getInteractable())
                {
                    currentHoveredInteract = interactedObject;
                    currentHoveredInteract.isHovered();
                    OnHover.RaiseEvent(currentHoveredInteract);
                }
            }              
        }

        private void OnLostInteratable(GameObject detectedObject, Micosmo.SensorToolkit.Sensor sensor)
        {
            if (currentHoveredInteract == null )
            {
                return;
            }

            if (detectedObject.TryGetComponent<Interactable>(out Interactable interactedObject))
            {
                if (interactedObject == currentHoveredInteract)
                {
                    OnHoverLost.RaiseEvent(currentHoveredInteract);
                    currentHoveredInteract.stoppedHovered();
                    currentHoveredInteract = null;

                    tryToHoverAnotherInteratable();

                    return;
                }
            }
        }

        private void tryToHoverAnotherInteratable()
        {
            foreach ( GameObject detectedObject in sensor.GetDetectionsByDistance())
            {
                if (detectedObject.TryGetComponent<Interactable>(out Interactable interactedObject))
                {
                    if (interactedObject.enabled == true && interactedObject.getInteractable())
                    {
                        currentHoveredInteract = interactedObject;
                        currentHoveredInteract.isHovered();
                        OnHover.RaiseEvent(currentHoveredInteract);
                        return;
                    }
                }
            }
        }
        



        #endregion
    }
}