using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using SurvivalTemplatePro.BuildingSystem;
using SurvivalTemplatePro.InventorySystem;

namespace SurvivalTemplatePro.UISystem {
    public class OvenUI : PlayerUIBehaviour, IObjectInspector {
        public System.Type InspectableType => typeof(Oven);

        [Title("References")]
        [SerializeField] private PanelUI m_Panel;
        [SerializeField] private ItemContainerUI m_ItemContainer;
        [SerializeField] private Text m_propaneLeftText;


        private Oven m_Oven = null;
        private ICustomActionManager m_CustomAction;

        public void Inspect(IInteractable inspectableObject) {
            m_Oven = inspectableObject as Oven;
            m_Panel.Show(true);

            m_ItemContainer.AttachToContainer(m_Oven.ItemContainer);
        }

        public void EndInspection() {
            m_Panel.Show(false);
            m_ItemContainer.DetachFromContainer();
            m_Oven = null;
        }

        private void Update() {
            if (m_Oven == null) {
                return;
            }
            m_propaneLeftText.text = "Propane Tank: " + m_Oven.resources.propaneLeft.ToString("F1") + "L/" + m_Oven.resources.propaneCapacity.ToString("F1") + "L";
        }

        public override void OnAttachment() {
            GetModule(out m_CustomAction);
        }
    }
}
