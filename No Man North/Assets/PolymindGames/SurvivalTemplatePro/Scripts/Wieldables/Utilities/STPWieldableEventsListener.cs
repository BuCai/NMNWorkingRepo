using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    public abstract class STPWieldableEventsListener<T> : STPEventsListenerBehaviour where T : MonoBehaviour
    {
        public static T Instance => m_Instance;

        protected ICharacter Character => m_Character;
        protected IWieldable Wieldable => m_Wieldable;

        private ICharacter m_Character;
        private IWieldable m_Wieldable;

        private static T m_Instance;


        protected virtual void OnWieldableEquipped()
        {
            m_Instance = this as T;

            if (m_Character != m_Wieldable.Character)
            {
                OnInitialized(m_Wieldable.Character);
                m_Character = m_Wieldable.Character;
            }
        }

        protected virtual void OnWieldableHolstered(float holsterSpeed) { }
        protected virtual void OnInitialized(ICharacter character) { }

        protected override void Awake()
        {
            base.Awake();

            m_Wieldable = GetComponentInParent<IWieldable>();

            m_Wieldable.onEquippingStarted += OnWieldableEquipped;
            m_Wieldable.onHolsteringStarted += OnWieldableHolstered;
        }

        protected virtual void OnDestroy()
        {
            m_Instance = null;
        }
    }
}