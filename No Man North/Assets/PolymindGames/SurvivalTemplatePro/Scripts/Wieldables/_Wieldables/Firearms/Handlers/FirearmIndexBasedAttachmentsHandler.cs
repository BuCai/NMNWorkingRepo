using SurvivalTemplatePro.InventorySystem;
using System;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Firearms/Handlers/Index-Based Attachments")]
    [RequireComponent(typeof(IFirearm))]
    public class FirearmIndexBasedAttachmentsHandler : MonoBehaviour, ISTPEventReferenceHandler
    {
        #region
        [Serializable]
        public class AttachmentIndexConfiguration
        {
            public string AttachmentName => m_AttachmentName;

            [SerializeField]
            private string m_AttachmentName;

            [SerializeField]
            private FirearmAttachmentBehaviour m_Attachment;


            public void Attach() => m_Attachment.Attach();
        }
        #endregion

        public AttachmentIndexConfiguration[] Configurations => m_Configurations;
        public string CurrentModeName => m_Configurations != null && m_Configurations.Length > 0 ? m_Configurations[m_SelectedIndex].AttachmentName : "";

        public event UnityAction onModeChanged;

        [SerializeField]
        private ItemPropertyReference m_AttachmentIndexProperty;

        [SerializeField, ReorderableList(elementLabel: "Attachment Configuration")]
        private AttachmentIndexConfiguration[] m_Configurations;

        [Title("Settings")]

        [SerializeField]
        private InputActionReference m_SwapInput;

        [SerializeField, Range(0f, 10f)]
        private float m_SwapCooldown;

        [Title("Audio")]

        [SerializeField]
        private StandardSound m_AttachmentSwapSound;

        [SerializeField, HideInInspector]
        private STPEventReference m_SwitchAttachmentEvent = new STPEventReference("On Switch Attachment");

        private int m_SelectedIndex;
        private IFirearm m_Firearm;
        private IItem m_AttachedItem;
        private IItemProperty m_AttachedProperty;
        private float m_NextTimeCanSwap;


        private void Awake()
        {
            m_Firearm = GetComponent<IFirearm>();

            m_Firearm.onEquippingStarted += OnEquipped;
            m_Firearm.onHolsteringStarted += OnHolster;
        }

        private void OnEquipped()
        {
            m_AttachedItem = m_Firearm.AttachedItem;

            if (m_AttachedItem == null)
                return;

            m_AttachedProperty = m_AttachedItem.GetProperty(m_AttachmentIndexProperty);

            if (m_AttachedProperty == null)
                return;

            AttachToItem(m_AttachedItem);

            m_SwapInput.action.Enable();
            m_SwapInput.action.started += OnSwapActionPerfomed;
        }

        private void OnHolster(float holsterSpeed)
        {
            if (m_AttachedItem == null)
                return;

            DetachFromItem(m_AttachedItem);

            m_SwapInput.action.Disable();
            m_SwapInput.action.started -= OnSwapActionPerfomed;
        }

        private void OnDestroy() => OnHolster(1f);

        private void OnSwapActionPerfomed(InputAction.CallbackContext context)
        {
            if (Time.time < m_NextTimeCanSwap)
                return;

            int lastIndex = m_AttachedProperty.Integer;
            m_AttachedProperty.Integer = (int)Mathf.Repeat(m_AttachedProperty.Integer + 1, (m_Configurations.Length - 1) + 0.01f);

            if (m_AttachedProperty.Integer != lastIndex)
            {
                // Trigger switch attachment event
                m_Firearm.AudioPlayer.PlaySound(m_AttachmentSwapSound);
                m_Firearm.EventHandler.TriggerAction(m_SwitchAttachmentEvent, 1f);

                onModeChanged?.Invoke();
            }

            m_NextTimeCanSwap = Time.time + m_SwapCooldown;
        }

        public void AttachToItem(IItem item)
        {
            if (item.TryGetProperty(m_AttachmentIndexProperty, out var property))
            {
                AttachConfigurationWithIndex(m_AttachedProperty.Integer);

                property.onChanged += OnPropertyChanged;
            }
        }

        public void AttachConfigurationWithIndex(int index)
        {
            for (int i = 0; i < m_Configurations.Length; i++)
            {
                if (i == index || i == m_Configurations.Length - 1)
                {
                    m_SelectedIndex = i;

                    m_Configurations[m_SelectedIndex].Attach();

                    return;
                }
            }
        }

        public void DetachFromItem(IItem item)
        {
            if (item.TryGetProperty(m_AttachmentIndexProperty, out var property))
                property.onChanged -= OnPropertyChanged;
        }

        private void OnPropertyChanged(IItemProperty property)
        {
            AttachConfigurationWithIndex(property.Integer);
        }

        public Component GetEventReferencesSource() => this;
    }
}