using SurvivalTemplatePro.MovementSystem;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [RequireComponent(typeof(Wieldable))]
    [AddComponentMenu("Wieldables/ActionBlockers/Reload Blocker")]
    public class CharacterReloadBlocker : CharacterActionBlocker
    {
        [SerializeField, Space]
        private bool m_ReloadWhileRunning;

        private IReloadHandler m_ReloadHandler;
        private IMotionController m_Motion;


        public override void OnInitialized()
        {
            m_ReloadHandler = GetComponent<IReloadHandler>();
            GetModule(out m_Motion);
        }

        protected override bool IsActionValid()
        {
            bool isValid = m_Motion.ActiveStateType != MotionStateType.Run || m_ReloadWhileRunning;

            return isValid;
        }

        protected override void BlockAction() => m_ReloadHandler.RegisterReloadBlocker(this);
        protected override void UnblockAction() => m_ReloadHandler.UnregisterReloadBlocker(this);
    }
}