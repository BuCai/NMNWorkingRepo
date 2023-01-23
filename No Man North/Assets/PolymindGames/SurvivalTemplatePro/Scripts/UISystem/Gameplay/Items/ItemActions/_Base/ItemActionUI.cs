using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public abstract class ItemActionUI : PlayerUIBehaviour
    {
        public string ActionName => m_ActionName;
        public Sprite ActionIcon => m_ActionIcon;

        [SerializeField]
        private string m_ActionName;

        [SerializeField]
        private Sprite m_ActionIcon;

        [SerializeField]
        private string m_ActionVerb;

        [SerializeField, Range(0f, 15f)]
        private float m_Duration = 0f;

        [Space]

        [SerializeField]
        private SoundPlayer m_ActionStartSound;

        [SerializeField]
        private SoundPlayer m_ActionEndSound;

        [SerializeField]
        private SoundPlayer m_ActionCanceledSound;

        private ItemSlotUI m_CurrentSlot;


        public abstract bool IsViableForItem(ItemSlotUI itemSlot);
        protected abstract void PerformAction(ItemSlotUI itemSlot);
        protected virtual void CancelAction(ItemSlotUI itemSlot) { }

        protected virtual float GetDuration(ItemSlotUI itemSlot) => m_Duration;

        public void StartAction(ItemSlotUI itemSlot)
        {
            m_CurrentSlot = itemSlot;
            m_ActionStartSound.Play2D(1f);

            if (GetDuration(m_CurrentSlot) > 0.01f && Player.TryGetModule(out ICustomActionManager customActionManager))
            {
                customActionManager.StartAction(new CustomActionParams(m_ActionName, m_ActionVerb + "...", m_Duration, true , StartPerformingAction, CancelPerformingAction));

                return;
            }

            StartPerformingAction();
        }

        private void StartPerformingAction()
        {
            m_ActionEndSound.Play2D(1f);
            PerformAction(m_CurrentSlot);
        }

        private void CancelPerformingAction() 
        {
            m_ActionCanceledSound.Play2D(1f);
            CancelAction(m_CurrentSlot);
        }

        private void OnValidate()
        {
            if (Application.isEditor && !Application.isPlaying)
                gameObject.name = this.GetType().Name;
        }
    }
}