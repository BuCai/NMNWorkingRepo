using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric {
    [System.Serializable]
    public class StatBlock {
        [SerializeField] private EventChannelFloat OnValueChanged;
        [SerializeField] private EventChannelFloat OnUpdateChanges;

        [SerializeField] private EventChannelFloat OnStatChangeWhenEmpty;

        [field: SerializeField] public float max { get; private set; }
        [field: SerializeField] public float baseChangePerMin { get; private set; }
        [SerializeField] private float hpDamangeWhenEmptyPerMin;
        [SerializeField] private bool drainLessInRV;

        [SerializeField] private float drainDuringTimeSkip;
        [field: SerializeField] public float current { get; private set; }

        [SerializeField] private bool displayInLog = false;

        public virtual void setUpEvents() {
            if (OnValueChanged != null) OnValueChanged.OnEvent += changeStat;
        }

        public virtual void removeEvent() {
            if (OnValueChanged != null) OnValueChanged.OnEvent -= changeStat;
        }

        public void reset() {
            current = max;
        }

        public virtual void OnGameMin_OnEvent(int minOfTheDay) {
            /* Commented out to prevent errors
            if (TimeManager.Instance.isFastForwarding == true )
            {
                changeStat(-drainDuringTimeSkip);
            }
            */

            if (baseChangePerMin != 0) {
                if (drainLessInRV == true && (GameStateManager.Instance.CurrentPlayerState == PlayerState.RV || GameStateManager.Instance.CurrentPlayerState == PlayerState.First)) {
                    changeStat(-baseChangePerMin / 2);
                }
                changeStat(-baseChangePerMin);
            }

        }

        public void broadCastChanges() {
            if (max == 0) {
                max = 1;
            }

            OnUpdateChanges?.RaiseEvent(Mathf.Clamp(current / max, 0, 1));
        }

        public virtual void changeStat(float change) {
            float changeInStat = current + change;

            if (displayInLog == true) {
                Debug.Log(current);
            }

            if (changeInStat < 0) {
                OnStatChangeWhenEmpty?.RaiseEvent(-hpDamangeWhenEmptyPerMin);
            }

            current = Mathf.Clamp(current + change, 0, max);

            broadCastChanges();
        }

    }
}