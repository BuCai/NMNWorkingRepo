using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

namespace MLC.NoManNorth.Eric
{
    public class Subtitles : MonoBehaviour
    {
        #region Variables
        private int currentLine = 0;
        [SerializeField] private TMP_Text lineOne;
        [SerializeField] private TMP_Text lineTwo;

        [SerializeField] private TMP_Text readerOne;
        [SerializeField] private TMP_Text readerTwo;

        [SerializeField] private Animator subTitlesAnimator;

        #endregion

        
        [SerializeField] private EventChannelString nextLine;
        
        #region Unity Methods
        private void OnEnable()
        {
            nextLine.OnEvent += NextLine_OnEvent;
            
        }

        private void OnDisable()
        {
            nextLine.OnEvent -= NextLine_OnEvent;
            
        }

        #endregion

        #region Methods

        private bool isFirstDialog;

        private void NextLine_OnEvent(string newSubtitle)
        {

            if (currentLine == 0)
            {
                lineOne.text = newSubtitle;
                //readerOne.text = $"{storyLine.getReader()} :";
                singleLineHider(1f);
                currentLine = 1;
            }
            else
            {
                lineTwo.text = newSubtitle;
                //readerTwo.text = $"{storyLine.getReader()} :";
                currentLine = 0;
                singleLineHider(1f);
            }

            if (isFirstDialog == false)
            {
                subTitlesAnimator.SetTrigger("Next Line");
            }
            else
            {
                isFirstDialog = false;
            }
            
        }

        private void singleLineHider(float timeIn)
        {
            if (hider_Coroutine != null)
            {
                StopCoroutine(hider_Coroutine);
            }
            hider_Coroutine = Linehider(timeIn);


            StartCoroutine(hider_Coroutine);
        }

        private IEnumerator hider_Coroutine;
        private IEnumerator Linehider(float timeIn)
        {
            yield return new WaitForSeconds(timeIn);
            //clears the next line
            if (currentLine == 0)
            {
                lineTwo.text = "";
            }
            else
            {
                lineOne.text = "";
            }

            subTitlesAnimator.SetTrigger("Next Line");
        }

        #endregion
    }
}