using UnityEngine;

namespace SurvivalTemplatePro
{
    public class CraftStation : Interactable
    {
        public int[] CraftableLevels => m_CraftableLevels;

        [Title("Settings (Craft Station)")]

        [SerializeField, ReorderableList(elementLabel: "level")]
        [Tooltip("Limits the items that can be crafted to only the ones that have a craft level between the minimum and maximum craft level range.")]
        private int[] m_CraftableLevels;
    }
}