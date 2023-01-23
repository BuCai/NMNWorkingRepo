using TMPro;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class TimerEventLisenerUI : MonoBehaviour
    {
        #region Variables

        [SerializeField] private TMP_Text TimerText;

        [SerializeField] private EventChannelInt DayEvent;
        [SerializeField] private EventChannelInt HourEvent;
        [SerializeField] private EventChannelInt MinEvent;
        
        private int currentDay;
        private int currentHour;
        private int currentMin;

        #endregion

        #region Unity Methods

        private void OnEnable()
        {
            if (DayEvent != null)
            {
                DayEvent.OnEvent += dayChange;
            }
            if (HourEvent != null)
            {
                HourEvent.OnEvent += hourChange;
            }
            if(MinEvent != null)
            {
                MinEvent.OnEvent += minChange;
            }
            
        }

        private void OnDisable()
        {
            if (DayEvent != null)
            {
                DayEvent.OnEvent -= dayChange;
            }
            if (HourEvent != null)
            {
                HourEvent.OnEvent -= hourChange;
            }
            if (MinEvent != null)
            {
                MinEvent.OnEvent -= minChange;
            }
        }

        #endregion

        #region Methods

        private void dayChange(int i)
        {
            currentDay = i;
            RefreshText();
        }
        private void hourChange(int i)
        {
            currentHour = i;
            RefreshText();
        }

        private void minChange(int i)
        {
            currentMin = i;
            RefreshText();
        }

        private void RefreshText()
        {
            int displayMin = currentMin;
            displayMin = displayMin % 60 ;

            int displayHour = currentHour;
            displayHour = displayHour % 12;

            if (displayHour == 0)
            {
                displayHour = 12;
            }
            string amOrPm = "am";
            if (currentHour >= 12)
            {
                amOrPm = "pm";
            }

            if (displayMin < 10)
            {
                TimerText.text = $"{currentDay} - {displayHour}:0{displayMin}{amOrPm}";
            }
            else
            {
                TimerText.text = $"{currentDay} - {displayHour}:{displayMin}{amOrPm}";
            }
        }

        #endregion
    }
}