using SurvivalTemplatePro.InventorySystem;
using System;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Firearms/Handlers/Item-Based Attachments")]
    [RequireComponent(typeof(IFirearm))]
    public class FirearmItemBasedAttachmentsHandler : MonoBehaviour
    {
        #region Internal
        [Serializable]
        public class AttachmentItemConfigurations
        {
            public event UnityAction onAttachmentChanged;

            [SerializeField]
            private ItemPropertyReference m_AttachmentTypeProperty;

            [SerializeField]
            private AttachmentItemConfiguration[] m_Configurations;


            public void AttachToItem(IItem item)
            {
                if (item.TryGetProperty(m_AttachmentTypeProperty, out var property))
                {
                    AttachConfigurationWithID(property.ItemId);
                    property.onChanged += OnPropertyChanged;
                }
            }

            public void DetachFromItem(IItem item)
            {
                if (item.TryGetProperty(m_AttachmentTypeProperty, out var property))
                    property.onChanged -= OnPropertyChanged;
            }

            private void OnPropertyChanged(IItemProperty property)
            {
                AttachConfigurationWithID(property.ItemId);
                onAttachmentChanged?.Invoke();
            }

            private void AttachConfigurationWithID(int id)
            {
                for (int i = 0; i < m_Configurations.Length; i++)
                {
                    if (m_Configurations[i].CorrespondingItem == id)
                    {
                        m_Configurations[i].Attach();

                        return;
                    }
                }
            }
        }

        [Serializable]
        public class AttachmentItemConfiguration
        {
            public int CorrespondingItem => m_Item;

            [SerializeField]
            private ItemReference m_Item;

            [SerializeField]
            private FirearmAttachmentBehaviour m_Attachment;


            public void Attach() => m_Attachment.Attach();
        }
        #endregion

        [SerializeField, ReorderableList(elementLabel: "Attachment Configuration")]
        private AttachmentItemConfigurations[] m_Configurations;

        [Title("Audio")]

        [SerializeField]
        private StandardSound m_AttachmentSwapSound;

        [SerializeField, HideInInspector]
        private STPEventReference m_SwitchAttachmentEvent = new STPEventReference("On Switch Attachment");

        private IFirearm m_Firearm;
        private IItem m_AttachedItem;
        private bool m_Attached = false;


        private void Awake()
        {
            m_Firearm = GetComponent<IFirearm>();

            m_Firearm.onEquippingStarted += OnEquipped;
            m_Firearm.onHolsteringStarted += OnHolster;
        }

        private void OnEquipped()
        {
            m_AttachedItem = m_Firearm.AttachedItem;

            if (m_AttachedItem == null || m_Attached)
                return;

            foreach (var config in m_Configurations)
                config.AttachToItem(m_AttachedItem);

            foreach (var config in m_Configurations)
                config.onAttachmentChanged += OnAttachmentSwapped;

            m_Attached = true;
        }

        private void OnHolster(float holsterSpeed)
        {
            if (m_AttachedItem == null || !m_Attached)
                return;

            foreach (var config in m_Configurations)
                config.DetachFromItem(m_AttachedItem);

            foreach (var config in m_Configurations)
                config.onAttachmentChanged -= OnAttachmentSwapped;

            m_Attached = false;
        }

        private void OnAttachmentSwapped()
        {
            m_Firearm.AudioPlayer.PlaySound(m_AttachmentSwapSound);
            m_Firearm.EventHandler.TriggerAction(m_SwitchAttachmentEvent);
        }
    }
}