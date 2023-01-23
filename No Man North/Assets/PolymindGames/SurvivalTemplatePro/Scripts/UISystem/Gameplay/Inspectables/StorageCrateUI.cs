using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class StorageCrateUI : PlayerUIBehaviour, IObjectInspector
    {
        public System.Type InspectableType => typeof(StorageStation);

        [SerializeField]
        private PanelUI m_Panel;

        [SerializeField]
        private ItemContainerUI m_ItemContainer;

        [SerializeField]
        private Text m_StationNameText;

        private StorageStation m_Storage;


        public void Inspect(IInteractable inspectableObject)
        {
            m_Panel.Show(true);
            m_Storage = inspectableObject as StorageStation;

            m_StationNameText.text = m_Storage.InteractionText.ToUpper();
            m_ItemContainer.AttachToContainer(m_Storage.ItemContainer);

            m_Storage.OpenStation();
        }

        public void EndInspection()
        {
            m_ItemContainer.DetachFromContainer();
            m_Storage.CloseStation();

            m_Panel.Show(false);
        }
    }
}