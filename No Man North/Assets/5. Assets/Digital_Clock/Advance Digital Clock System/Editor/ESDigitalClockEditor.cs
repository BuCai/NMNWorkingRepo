using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;

[CanEditMultipleObjects]
[CustomEditor(typeof(EsDigitalClockSystem))]
public class ESDigitalClockSystemEditor : Editor
{
    public EsDigitalClockSystem _esdigitalclocksystem;
    public bool m_Foldout01,m_foldout02,m_foldout03;
    public override void OnInspectorGUI()
    {
        
        _esdigitalclocksystem = target as EsDigitalClockSystem;
        _esdigitalclocksystem.DebugMode = EditorGUILayout.Toggle("DebugMode", _esdigitalclocksystem.DebugMode);
        m_Foldout01 = EditorGUILayout.Foldout(m_Foldout01, "Time Settings");
        if (m_Foldout01 == true)
        {
            _esdigitalclocksystem.SecondsModifier = EditorGUILayout.Slider("Seconds Modifier", _esdigitalclocksystem.SecondsModifier, 1, 360);

        }
        m_foldout02 = EditorGUILayout.Foldout(m_foldout02, "UI Values");
        if (m_foldout02 == true)
        {
            _esdigitalclocksystem.SecondsText = (Text)EditorGUILayout.ObjectField("SecondsText", _esdigitalclocksystem.SecondsText, typeof(Text), true) as Text;
            _esdigitalclocksystem.MinutesText = (Text)EditorGUILayout.ObjectField("MinutesText", _esdigitalclocksystem.MinutesText, typeof(Text), true) as Text;
            _esdigitalclocksystem.Is24Hours = EditorGUILayout.Toggle("Is24Hours", _esdigitalclocksystem.Is24Hours);
            if (_esdigitalclocksystem.Is24Hours)
            {
                _esdigitalclocksystem._24HourText = (Text)EditorGUILayout.ObjectField("_24HourText", _esdigitalclocksystem._24HourText, typeof(Text), true) as Text;
            }
            else
            {
                _esdigitalclocksystem.HourText = (Text)EditorGUILayout.ObjectField("HourText", _esdigitalclocksystem.HourText, typeof(Text), true) as Text;
            }
            
            _esdigitalclocksystem.FormatText = (Text)EditorGUILayout.ObjectField("FormatText", _esdigitalclocksystem.FormatText, typeof(Text), true) as Text;
        }
        m_foldout03 = EditorGUILayout.Foldout(m_foldout03, "Alarm Settings");
        if (m_foldout03 == true)
        {
            _esdigitalclocksystem.UseAlarm = EditorGUILayout.Toggle("UseAlarm", _esdigitalclocksystem.UseAlarm);
            _esdigitalclocksystem.A_hour = EditorGUILayout.FloatField("Hour(12/24)", _esdigitalclocksystem.A_hour);
            _esdigitalclocksystem.A_minutes = EditorGUILayout.FloatField("Minutes", _esdigitalclocksystem.A_minutes);
        }
        if (_esdigitalclocksystem.DebugMode)
        {
            GUILayout.Space(12);
            GUI.color = Color.red;
            EditorGUILayout.BeginVertical("Box");
           _esdigitalclocksystem.cellingsecs = EditorGUILayout.FloatField("Ceil Seconds", _esdigitalclocksystem.cellingsecs);
            _esdigitalclocksystem.minutes = EditorGUILayout.FloatField("Minutes", _esdigitalclocksystem.minutes);
            _esdigitalclocksystem.seconds = EditorGUILayout.FloatField("Seconds", _esdigitalclocksystem.seconds);
            _esdigitalclocksystem.Hour = EditorGUILayout.FloatField("Hour", _esdigitalclocksystem.Hour);
            _esdigitalclocksystem._24Hour = EditorGUILayout.FloatField("_24Hour", _esdigitalclocksystem._24Hour);
            _esdigitalclocksystem.format = EditorGUILayout.TextField("Format", _esdigitalclocksystem.format);
            _esdigitalclocksystem.AlarmTriggered = EditorGUILayout.Toggle("AlarmTriggered", _esdigitalclocksystem.AlarmTriggered);
            EditorGUILayout.EndVertical();
        }

        if (GUI.changed)
        {
            EditorUtility.SetDirty(_esdigitalclocksystem);
        }
    }
}
