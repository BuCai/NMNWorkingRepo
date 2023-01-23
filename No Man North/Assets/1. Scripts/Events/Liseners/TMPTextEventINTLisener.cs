using TMPro;
using UnityEngine;

namespace MLC.NoManNorth.Eric
{
    public class TMPTextEventINTLisener : MonoBehaviour 
    {
        #region Variables
        //Start text should be set in the TMP_Text object

        [SerializeField] private TMP_Text text;
        [SerializeField] private string beforeText;
        [SerializeField] private string afterText;

        [SerializeField] private EventChannelInt EventToLisenFor;
        #endregion

        #region Unity Methods

        private void Start()
        {
            EventToLisenFor.OnEvent += EventToLisenFor_OnEvent;   
        }

        private void OnDestroy()
        {
            EventToLisenFor.OnEvent += EventToLisenFor_OnEvent;
        }

        #endregion

        #region Methods

        private void EventToLisenFor_OnEvent(int intIn)
        {
            text.text = beforeText + intIn.ToString() + afterText;
        }

        #endregion
    }
}