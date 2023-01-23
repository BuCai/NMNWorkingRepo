using System;
using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public class CraftingStationUI : PlayerUIBehaviour, IObjectInspector
    {
        public Type InspectableType => typeof(CraftStation);

        [SerializeField]
        private CraftingUI m_CraftingUI;

        private CraftStation m_CraftStation;


        public void Inspect(IInteractable inspectableObject)
        {
            m_CraftStation = inspectableObject as CraftStation;
            m_CraftingUI.SetAvailableCraftingLevels(m_CraftStation.CraftableLevels);
            m_CraftingUI.ShowPanel(true);
        }

        public void EndInspection()
        {
            m_CraftingUI.ResetCraftingLevel();
            m_CraftingUI.ShowPanel(false);
        }
    }
}
