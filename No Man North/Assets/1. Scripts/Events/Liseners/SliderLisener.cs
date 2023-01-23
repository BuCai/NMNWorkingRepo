using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace MLC.NoManNorth.Eric
{
    public class SliderLisener : MonoBehaviour
    {
        #region Variables

        [SerializeField] private EventChannelFloat OnValueChanged;
        [SerializeField] private Slider slider;
        #endregion

        #region Unity Methods

        private void Awake()
        {
            OnValueChanged.OnEvent += OnValueChanged_OnEvent;
        }

        private void OnDestroy()
        {
            
        }
        #endregion

        #region Methods

        private void OnValueChanged_OnEvent(float percentage)
        {
            
            slider.value = (percentage);
        }

        #endregion
    }
}