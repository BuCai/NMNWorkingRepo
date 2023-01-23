using SurvivalTemplatePro.CompanionSystem;
using System.Collections.Generic;

namespace SurvivalTemplatePro
{
    public interface IActions : ICharacterModule
    {
        IList<IActionContainer> Containers { get; }

        event ActionSlotChangedCallback onActionsChanged;

        /// <summary>
        /// Adds a container to the container list.
        /// </summary>
        void AddContainer(IActionContainer actionContainer, bool add);

        /// <summary>
        /// Returns a container with the given name.
        /// </summary>
        IActionContainer GetContainerWithName(string name);


        /// <summary>
        /// Adds an action on a container.
        /// </summary>
        /// <param name="item"></param>
		/// <returns> stack Added Count. </returns>
        bool AddAction(IAction item);

        /// <summary>
        /// Removes an action from a container.
        /// </summary>
        bool RemoveAction(IAction action);

        /// <summary>
        /// Returns true if the action is found.
        /// </summary>
        bool ContainsAction(IAction action);
    }
}