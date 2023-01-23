using SurvivalTemplatePro.InventorySystem;
using System;
using UnityEngine;

namespace SurvivalTemplatePro
{
    public class ItemPickupWithAttachments : ItemPickup
    {
        #region Internal
        [Serializable]
        public class AttachmentItemConfigurations
        {
            [SerializeField]
            private ItemPropertyReference m_AttachmentTypeProperty;

            [SerializeField]
            private AttachmentItemConfiguration[] m_Configurations;


            public void AttachToItem(IItem item)
            {
                if (item.TryGetProperty(m_AttachmentTypeProperty, out var property))
                    EnableConfigurationWithID(property.ItemId);
            }

            public void EnableConfigurationWithID(int id)
            {
                for (int i = 0; i < m_Configurations.Length; i++)
                {
                    bool enable = m_Configurations[i].Item == id;
                    m_Configurations[i].Object.SetActive(enable);
                }
            }
        }

        [Serializable]
        public class AttachmentItemConfiguration
        {
            public ItemReference Item => m_Item;
            public GameObject Object => m_Object;

            [SerializeField]
            private ItemReference m_Item;

            [SerializeField]
            private GameObject m_Object;
        }
        #endregion

        [SerializeField, Space]
        private AttachmentItemConfigurations[] m_Configurations;


        public override void LinkWithItem(IItem item)
        {
            base.LinkWithItem(item);

            foreach (var config in m_Configurations)
                config.AttachToItem(Item);
        }

#if UNITY_EDITOR
        // TODO: Take the attachment position and rotation offsets from the corresponding wieldable.
        public void CalculateAttachmentPositions()
        {

        }
#endif
    }
}