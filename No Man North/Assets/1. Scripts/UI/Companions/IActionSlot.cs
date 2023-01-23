namespace SurvivalTemplatePro.CompanionSystem
{
    public interface IActionSlot
    {
        bool HasAction { get; }
        IAction Action { get; }

        event ActionSlotChangedCallback onChanged;

        void SetAction(IAction action);
    }
    

    public delegate void ActionSlotChangedCallback(IActionSlot actionSlot);
}