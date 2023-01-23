using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    public abstract class WieldableItemReference : MonoBehaviour
    {
        public IWieldable Wieldable
        {
            get
            {
                if (m_Wieldable == null)
                    m_Wieldable = GetComponent<IWieldable>();

                return m_Wieldable;
            }
        }

        private IWieldable m_Wieldable;


        public abstract int GetItemId();
        public abstract string GetItemName();
    }
}