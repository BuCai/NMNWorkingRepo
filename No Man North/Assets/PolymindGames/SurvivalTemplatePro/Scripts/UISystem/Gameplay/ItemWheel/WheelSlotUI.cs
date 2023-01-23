using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem {
    public class WheelSlotUI : ItemSlotUI {
        public enum SelectionGraphicState { Normal, Highlighted }

        [Title("Item Wheel Slot")]
        [SerializeField] private Image slotImage;
        [SerializeField] private Sprite slotSprite;
        [SerializeField] private Sprite selectionSprite;



        public void SetSlotHighlights(SelectionGraphicState state) {
            if (state == SelectionGraphicState.Normal) {
                slotImage.sprite = slotSprite;
                slotImage.SetNativeSize();
            } else if (state == SelectionGraphicState.Highlighted) {
                slotImage.sprite = selectionSprite;
                slotImage.SetNativeSize();
            }
        }

        protected override void Awake() {
            base.Awake();
            slotImage.sprite = slotSprite;
        }
    }
}