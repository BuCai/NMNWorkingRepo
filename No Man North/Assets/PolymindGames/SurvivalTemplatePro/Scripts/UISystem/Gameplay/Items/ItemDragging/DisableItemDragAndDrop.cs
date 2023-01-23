using UnityEngine;

namespace SurvivalTemplatePro.UISystem
{
    public class DisableItemDragAndDrop : MonoBehaviour
    {
        public bool DisableDragging => m_DisableDragging;
        public bool DisableDropping => m_DisableDropping;

        [SerializeField]
        private bool m_DisableDragging;

        [SerializeField]
        private bool m_DisableDropping;
    }
}