﻿using SurvivalTemplatePro.WorldManagement;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    public interface ISleepHandler : ICharacterModule
    {
        bool SleepActive { get; }

        /// <summary> Used for respawning when dying, if the position is (0, 0, 0),
        /// the character will be respawned through other methods. </summary>
        Vector3 LastSleepPosition { get; }
        Quaternion LastSleepRotation { get; }

        /// <summary>
        /// GameTime: Time to sleep
        /// </summary>
        event UnityAction<GameTime> onSleepStart;

        /// <summary>
        /// GameTime: Time slept
        /// </summary>
        event UnityAction<GameTime> onSleepEnd;

        void Sleep(ISleepingPlace sleepingPlace);
    }
}