using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class FadeToBlack : MonoBehaviour
    {
        #region Variables
        [SerializeField] private EventChannelInt OnHourFastForward;
        [SerializeField] private EventChannelInt OnMinFastForward;

        [SerializeField] private Animator animationController;
        #endregion

        #region Unity Methods
        private void Awake()
        {
            OnHourFastForward.OnEvent += OnHourFastForward_OnEvent;
            OnMinFastForward.OnEvent += OnMinFastForward_OnEvent; 
        }

        private void OnDestroy()
        {
            OnHourFastForward.OnEvent -= OnHourFastForward_OnEvent;
            OnMinFastForward.OnEvent -= OnMinFastForward_OnEvent;
        }

        private void Update()
        {
            if (TimeManager.Instance.isFastForwarding == false)
            {
                this.enabled = false;
                animationController.ResetTrigger("Fade to Black");
                animationController.ResetTrigger("Fade to Clear");
                animationController.SetTrigger("Fade to Clear");
            }
        }

        #endregion

        #region Methods

        private void OnHourFastForward_OnEvent(int obj)
        {
            this.enabled = true;
            animationController.ResetTrigger("Fade to Black");
            animationController.ResetTrigger("Fade to Clear");
            animationController.SetTrigger("Fade to Black");
        }

        private void OnMinFastForward_OnEvent(int obj)
        {
            this.enabled = true;
            animationController.ResetTrigger("Fade to Black");
            animationController.ResetTrigger("Fade to Clear");
            animationController.SetTrigger("Fade to Black");
        }

        #endregion
    }
}