using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    public class WieldableDropHandler : CharacterBehaviour, IWieldableDropHandler
    {
        [SerializeField, Range(0f, 10f)]
        private float m_WieldableDropDelay = 0.35f;

        private IWieldablesController m_Controller;
        private IItemDropHandler m_InventoryDropHandler;
        private IObjectCarryController m_ObjectCarryController;


        public override void OnInitialized()
        {
            GetModule(out m_Controller);
            GetModule(out m_InventoryDropHandler);
            GetModule(out m_ObjectCarryController);
        }

        public void DropWieldable()
        {
            if (m_Controller.IsEquipping)
                return;

            // Drop inventory wieldable.
            if (m_Controller.ActiveWieldable != null && m_Controller.ActiveWieldable.AttachedItem != null)
                m_InventoryDropHandler.DropItem(m_Controller.ActiveWieldable.AttachedItem, m_WieldableDropDelay);

            // Drop carriable.
            else if (m_ObjectCarryController.CarriedObjectsCount > 0)
                m_ObjectCarryController.DropCarriedObjects(1);
        }
    }
}