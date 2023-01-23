using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.WieldableSystem
{
    public interface IReloadHandler
    {
        bool IsReloading { get; }

        void StartReloading();
        void CancelReloading();

        void RegisterReloadBlocker(Object blocker);
        void UnregisterReloadBlocker(Object blocker);
    }
}