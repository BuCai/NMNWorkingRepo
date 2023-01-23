using System;
using UnityEngine.Events;

namespace SurvivalTemplatePro
{
    public interface IInventoryInspectManager : ICharacterModule
    {
        InventoryInspectState InspectState { get; }
        IExternalContainer ExternalContainer { get; }
        float LastInspectionTime { get; }

        event UnityAction<InventoryInspectState> onInspectStarted;
        event UnityAction onInspectEnded;

        bool TryInspect(InventoryInspectState inspectState, IExternalContainer container = null);
        bool TryStopInspecting(bool forceStop = false);
    }

    [Flags]
    public enum InventoryInspectState
    {
        None = 0,
        Everything = Default | External,
        Default = 1,
        External = 2
    }

    public static class InventoryInspectStateFlagExtensions
    {
        /// <summary>
        /// 
        /// </summary>
        public static bool Has(this InventoryInspectState thisFlags, InventoryInspectState flag)
        {
            return ((thisFlags & flag) == flag) || (flag == InventoryInspectState.Everything);
        }
    }
}