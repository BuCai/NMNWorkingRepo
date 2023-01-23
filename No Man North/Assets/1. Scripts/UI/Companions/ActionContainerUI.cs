using SurvivalTemplatePro.CompanionSystem;
using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public class ActionContainerUI : ContainerUI<ActionSlotUI>
    {
        #region Internal

        public enum SlotLinkMethod
        {
            GenerateAndLinkSlots,
            LinkChildSlots
        }

        #endregion

        public IActionContainer ActionContainer
        {
            get
            {
                if (m_ActionContainer != null)
                    return m_ActionContainer;
                else
                {
                    Debug.LogError("There's no item container linked. Can't retrieve any!");

                    return null;
                }
            }
        }

        [Header("Item Container")]

        [SerializeField]
        private bool m_IsPlayerContainer = true;

        [SerializeField]
        private string m_ContainerName;

        [SerializeField]
        private SlotLinkMethod m_SlotLinkMethod = SlotLinkMethod.GenerateAndLinkSlots;

        private IActionContainer m_ActionContainer;


        public override void OnAttachment()
        {
            if (m_IsPlayerContainer)
            {
                IActionContainer itemContainer = PlayerActions.GetContainerWithName(m_ContainerName);

                if (itemContainer != null)
                    AttachToContainer(itemContainer);
            }
        }

        public void AttachToContainer(IActionContainer container)
        {
            if (m_SlotLinkMethod == SlotLinkMethod.LinkChildSlots)
            {
                m_SlotInterfaces = GetComponentsInChildren<ActionSlotUI>();
            }
            else if (m_SlotLinkMethod == SlotLinkMethod.GenerateAndLinkSlots)
            {
                GenerateSlots(container.Count);
            }

            for (int i = 0;i < container.Count;i++)
                m_SlotInterfaces[i].LinkToSlot(container[i]);

            m_ActionContainer = container;
        }

        public void DetachFromContainer()
        {
            for (int i = 0;i < m_SlotInterfaces.Length;i++)
                m_SlotInterfaces[i].UnlinkFromSlot();
        }
    }
}