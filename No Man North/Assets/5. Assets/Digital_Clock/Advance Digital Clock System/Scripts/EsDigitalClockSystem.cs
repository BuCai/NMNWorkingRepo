using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EsDigitalClockSystem : MonoBehaviour 
{
    // Hey there this script has been made easy to understand,modify and upgraded to suit your current Project :)
    public float seconds;
    [Range(1f, 360f)]
    public float SecondsModifier = 1f;
    public float cellingsecs;
    public float minutes;
    public float Hour,_24Hour;
    public string format = "AM";
    public bool JustLeft,StopAlarm;
    public bool AlarmTriggered;
    public bool DebugMode;
    public bool Is24Hours;
    //Exposed Values
    public Text SecondsText;
    public Text MinutesText;
    public Text HourText;
    public Text _24HourText;
    public Text FormatText;
    //AlarmSettings
    public bool UseAlarm;
    public float A_hour;
    public float A_minutes;

    private void Awake()
    {
        AlarmTriggered = false;
    }

    private void Update()
    {
        CalcTime();
      
    }

    private void CalcTime()
    {
        seconds += Time.deltaTime *SecondsModifier;
       cellingsecs = Mathf.Ceil(seconds);
        if (seconds > 59f)
        {
            seconds = 0f;
            minutes++;
        }
        if (minutes > 59)
        {
            minutes = 0f;
            Hour++;
            _24Hour++;
        }

        if (Hour > 12 && format =="PM")
        {
            Hour = 1;
            _24Hour = 13;
        }
        //
        if (Hour > 12 && format =="AM")
        {
            Hour = 1;
            _24Hour = 1;
        }
        //
        if (Hour == 12 && format == "PM")
        {
          
            _24Hour = 0;
        }
        //
        if (format == "AM" && Hour == 12 && !JustLeft)
        {
            format = "PM";
           
            JustLeft = true;
           
        }
        //
        if (JustLeft && Hour == 1)
        {
            JustLeft = false;
        }
        //
        if (format == "PM" && Hour == 12 && !JustLeft)
        {
            format = "AM";
            JustLeft = true;
           
        }
        //
       ExposedValues();
        if(UseAlarm)
       AlarmSystem(A_minutes, A_hour, Is24Hours);

    }

    private void AlarmSystem(float mins,float hrs,bool Is24Hours)
    {
        if (!StopAlarm)
        {
            if (!Is24Hours)
            {
                if (mins == minutes && hrs == Hour)
                {
                    AlarmTriggered = true;
                }
            }
            //
            if (Is24Hours)
            {
                if (mins == minutes && hrs == _24Hour)
                {
                    AlarmTriggered = true;
                }
            }
        }
    }

    private void TimerReset()
    {
        //call this method if you ever want to reset time 
        seconds = 0;
        cellingsecs = 0;
        _24Hour = 12;
        Hour = 12;
        minutes = 0;
        format = "AM";
    }

   

    private void ExposedValues()
    {
        if (cellingsecs < 9)
        {
            SecondsText.text = "0" + cellingsecs.ToString();
        }
        if (cellingsecs >= 10)
        {
            SecondsText.text = cellingsecs.ToString();
        }
        if (minutes < 9)
        {
            MinutesText.text ="0" + minutes.ToString();
        }
        if (minutes >= 10)
        {
            MinutesText.text = minutes.ToString();
        }


        if (Is24Hours)
        {
            if (_24Hour < 9)
            {
                _24HourText.text = "0" + _24Hour.ToString();
            }
            if (_24Hour >= 10)
            {
                _24HourText.text = _24Hour.ToString();
            }
        }
        else
        {
            if (Hour < 9)
            {
                HourText.text = "0" + Hour.ToString();
            }
            if (Hour >= 10)
            {
                HourText.text = Hour.ToString();
            }
        }


        FormatText.text = format;
    }

}