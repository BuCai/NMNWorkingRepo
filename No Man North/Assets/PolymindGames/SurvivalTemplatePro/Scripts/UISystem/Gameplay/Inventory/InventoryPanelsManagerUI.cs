using System;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.UISystem
{
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/user-interface/behaviours/ui_inventory#inventory-panels-manager")]
    public class InventoryPanelsManagerUI : PlayerUIBehaviour
	{
        #region Internal
        [Serializable]
        public class PanelActivator
        {
            public InventoryInspectState ActivationStates;
            public PanelUI Panel;
        }
        #endregion

        public PanelActivator[] PanelActivators => m_PanelsToShowOnInspection;

        [SerializeField, LabelByChild("Panel"), ReorderableList(Foldable = true)]
        private PanelActivator[] m_PanelsToShowOnInspection;

        [Space]

        [SerializeField]
        private UnityEvent m_InventoryOpenUnityEvent;

        [SerializeField]
        private UnityEvent m_InventoryCloseUnityEvent;

		private PanelUI[] m_Panels;
        private IInventoryInspectManager m_InventoryInspector;


        public override void OnAttachment()
        {
            if (TryGetModule(out m_InventoryInspector))
            {
                m_InventoryInspector.onInspectStarted += OnInventoryInspectStart;
                m_InventoryInspector.onInspectEnded += OnInventoryInspectEnd;
            }
        }

        private void OnInventoryInspectStart(InventoryInspectState inspectState)
        {
            foreach (var panel in m_PanelsToShowOnInspection)
            {
                if (panel.ActivationStates.Has(inspectState))
                    panel.Panel.Show(true);
            }

            m_InventoryOpenUnityEvent.Invoke();
        }

        private void OnInventoryInspectEnd()
        {
            foreach (PanelUI panel in m_Panels)
                panel.Show(false);

            m_InventoryCloseUnityEvent.Invoke();
        }

        private void Awake()
        {
            m_Panels = GetComponentsInChildren<PanelUI>(true);
        }
    }
}
