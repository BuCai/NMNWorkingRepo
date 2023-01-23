using SurvivalTemplatePro.InventorySystem;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.WieldableSystem
{
    public interface IWieldable
    {
        ICharacter Character { get; }
        IAudioPlayer AudioPlayer { get; set; }
        IRayGenerator RayGenerator { get; set; }
        ISTPEventHandler EventHandler { get; }

        IItem AttachedItem { get; }
        IItemProperty ItemDurability { get; }

        bool IsVisible { get; } 

        float EquipDuration { get; }
        float HolsterDuration { get; }

        event UnityAction onEquippingStarted;
        event UnityAction<float> onHolsteringStarted;


        void SetVisibility(bool visible);
        void AttachItem(IItem item);
        void SetWielder(ICharacter wielder);
        void OnEquip();
        void OnHolster(float holsterSpeed);

        #region Monobehaviour
        GameObject gameObject { get; }
        Transform transform { get; }
        #endregion
    }
}