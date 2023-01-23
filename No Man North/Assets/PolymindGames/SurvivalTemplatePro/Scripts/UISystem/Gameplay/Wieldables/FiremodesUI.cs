using SurvivalTemplatePro.WieldableSystem;
using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class FiremodesUI : PlayerUIBehaviour
    {
        [SerializeField]
        [Tooltip("Reference to the animator used by the Firemode UI.")]
        private Animator m_Animator;

        [SerializeField]
        [Tooltip("A UI text component that's used for displaying the currently selected fire mode.")]
        private Text m_FiremodeNameText;

        private int m_HashedUpdateTrigger;
        private int m_HashedShowTrigger;
        private int m_HashedHideTrigger;

        private IWieldablesController m_WieldableController;
        private FirearmIndexBasedAttachmentsHandler m_IndexAttachments;


        public override void OnAttachment()
        {
            m_HashedUpdateTrigger = Animator.StringToHash("Update");
            m_HashedShowTrigger = Animator.StringToHash("Show");
            m_HashedHideTrigger = Animator.StringToHash("Hide");

            m_Animator.Play(m_HashedHideTrigger, 0, 1f);

            GetModule(out m_WieldableController);
            m_WieldableController.onWieldableEquipped += OnWieldableEquipped;
        }

        private void OnWieldableEquipped(IWieldable wieldable)
        {
            // Unsubscribe from previous index-based attachments handler
            if (m_IndexAttachments != null)
            {
                m_IndexAttachments.onModeChanged -= OnAttachmentIndexChanged;
                m_IndexAttachments = null;

                m_Animator.SetTrigger(m_HashedHideTrigger);
            }

            if (wieldable != null)
                m_IndexAttachments = wieldable.gameObject.GetComponent<FirearmIndexBasedAttachmentsHandler>();

            // Subscribe to current index-based attachments handler
            if (m_IndexAttachments != null)
            {
                m_IndexAttachments.onModeChanged += OnAttachmentIndexChanged;

                m_FiremodeNameText.text = m_IndexAttachments.CurrentModeName;
                m_Animator.SetTrigger(m_HashedShowTrigger);
            }
        }

        private void OnAttachmentIndexChanged() 
        {
            m_FiremodeNameText.text = m_IndexAttachments.CurrentModeName;
            m_Animator.SetTrigger(m_HashedUpdateTrigger);
        }
    }
}