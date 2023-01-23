using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [RequireComponent(typeof(Wieldable))]
    [AddComponentMenu("Wieldables/Utilities/Item Reference")]
    public sealed class STPWieldableItemReference : WieldableItemReference
    {
        [SerializeField]
        private ItemReference m_ItemReference;
        

        public override int GetItemId() => m_ItemReference;
        public override string GetItemName() => m_ItemReference.ToString();
    }
}