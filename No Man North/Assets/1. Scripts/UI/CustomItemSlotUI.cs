using SurvivalTemplatePro.InventorySystem;
using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem {
    public class CustomItemSlotUI : ItemSlotUI {

        [Title("Item Wheel Slot")]
        [SerializeField] private Image slotImage;
        [SerializeField] private Sprite slotSprite;
        [SerializeField] private Sprite selectionSprite;

        //Overrides the slot ui code directly
        protected override void RefreshState(State state) {
            m_State = state;
            if (state == State.Highlighted || state == State.Pressed) {
                slotImage.sprite = selectionSprite;
                slotImage.SetNativeSize();
            } else if (state == State.Normal) {
                slotImage.sprite = slotSprite;
                slotImage.SetNativeSize();
            }
            if (m_Selected) {
                slotImage.sprite = selectionSprite;
                slotImage.SetNativeSize();
            }
            InvokeOSC();
        }

        protected override void OnValidate() {
            FindRenderer();
        }
    }
}
