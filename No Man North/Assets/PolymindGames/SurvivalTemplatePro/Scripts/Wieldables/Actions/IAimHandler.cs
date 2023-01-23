using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.WieldableSystem
{
    public interface IAimHandler
    {
        bool IsAiming { get; }

        void StartAiming();
        void EndAiming();

        void RegisterAimBlocker(Object blocker);
        void UnregisterAimBlocker(Object blocker);
    }
}
