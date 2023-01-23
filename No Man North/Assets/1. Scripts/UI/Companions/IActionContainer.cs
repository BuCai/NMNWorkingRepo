using System.Collections;
using Unity.VisualScripting;

namespace SurvivalTemplatePro.CompanionSystem
{
    public interface IActionContainer : IEnumerable
    {
        IActionSlot this[int i] { get; set; }
        
        /// <summary>Slot count.</summary>
        int Count { get; }
        IActionSlot[] Slots { get; }

        bool CanAddAction { get; set; }
        bool CanRemoveAction { get; set; }

        string Name { get; }

        event ActionContainerChangedCallback onContainerChanged;

        void OnLoad();
        
        /// <summary>
        /// Adds an item to this container
        /// </summary>
        /// <returns> Stack added count. </returns>
        bool AddAction(IAction action);

        bool RemoveAction(int id);
        bool RemoveAction(IAction action);

        bool ContainsAction(IAction action);
        
        int GetSlotIndex(IActionSlot actionSlot);
    }

    public delegate void ActionContainerChangedCallback(IActionSlot actionSlot);
}