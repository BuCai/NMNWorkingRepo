using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MLC.NoManNorth.Eric {
    /// <summary>
    /// Handles the player stats.
    /// Each stat lisens to EventChannelInt Float Change to try changing values
    /// Each stat broad casts EventChannelFloatFloat to update others of current and max
    /// </summary>

    //LEFT FROM PRE-STP VERSIONS, DO NOT USE
    //Not deleted because some old used scripts still reference it
    public class PlayerStatManager : MonoBehaviour {
        public static PlayerStatManager Instance { get; private set; }


        #region Variables
        [SerializeField] private EventChannelInt OnGameMin;

        [field: SerializeField] public StatBlock hp { private set; get; }
        [field: SerializeField] public StatBlockStamina stamina { private set; get; }

        [field: SerializeField] public StatBlock hunger { private set; get; }
        [field: SerializeField] public StatBlock thirst { private set; get; }

        [field: SerializeField] public StatBlock fatigue { private set; get; }

        [field: SerializeField] public StatBlock frost { private set; get; }

        #endregion

        #region Unity Methods

        private void Awake() {
            if (Instance != null && Instance != this) {
                Destroy(this);
            } else {
                Instance = this;
            }

            if (OnGameMin != null) OnGameMin.OnEvent += OnGameMin_OnEvent;

            setUpStats();


            void setUpStats() {
                hp.setUpEvents();
                stamina.setUpEvents();
                hunger.setUpEvents();
                thirst.setUpEvents();
                fatigue.setUpEvents();
                frost.setUpEvents();

                hp.reset();
                stamina.reset();
                hunger.reset();
                thirst.reset();
                fatigue.reset();
                frost.reset();
            }
        }

        private void Start() {
            hp.broadCastChanges();
            stamina.broadCastChanges();
            hunger.broadCastChanges();
            thirst.broadCastChanges();
            fatigue.broadCastChanges();
            frost.broadCastChanges();
        }
        private void OnDestroy() {
            if (OnGameMin != null) OnGameMin.OnEvent -= OnGameMin_OnEvent;

            removeStatEvents();

            void removeStatEvents() {
                hp.removeEvent();
                stamina.removeEvent();
                hunger.removeEvent();
                thirst.removeEvent();
                fatigue.removeEvent();
                frost.removeEvent();
            }
        }
        #endregion

        #region Methods

        private void OnGameMin_OnEvent(int obj) {
            hp.OnGameMin_OnEvent(obj);
            stamina.OnGameMin_OnEvent(obj);
            hunger.OnGameMin_OnEvent(obj);
            thirst.OnGameMin_OnEvent(obj);
            fatigue.OnGameMin_OnEvent(obj);
            frost.OnGameMin_OnEvent(obj);
        }

        public float getMaxStamPercentage() {
            return ((frost.current + hunger.current + thirst.current + fatigue.current) / (frost.max + hunger.max + thirst.max + fatigue.max));
        }

        #endregion
    }
}