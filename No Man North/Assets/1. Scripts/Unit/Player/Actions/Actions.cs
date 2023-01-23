using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using Enumerable = System.Linq.Enumerable;

namespace SurvivalTemplatePro.CompanionSystem
{
    [DisallowMultipleComponent()]
    public class Actions : CharacterBehaviour, IActions, ISaveableComponent
    {
        // NOTE: This being a list suggests that we might have several action containers.
        //       For the purposes of the companion system, we merely have the one action wheel, but
        //       as this is a direct port of the inventory system I've left it as it is. It might
        //       be worth in the future to either change this to a simple variable, rather than
        //       a list, or if we expand the action system to contain more than companion actions,
        //       reimplement the flag system similar to that of the inventory one, because right now
        //       the add and remove action from container methods affect all containers in this list
        //       due to the lack of flags.
        public IList<IActionContainer> Containers
        {
            get
            {
                if (m_Containers == null)
                    GenerateCompanionWheel();

                return m_Containers;
            }
        }

        public event ActionSlotChangedCallback onActionsChanged;

        private IList<IActionContainer> m_Containers;


        #region Save & Load

        public void LoadMembers(object[] members)
        {
            m_Containers = members[0] as IList<IActionContainer>;

            foreach (var container in m_Containers)
            {
                container.OnLoad();
                AddListeners(container, true);
            }
        }

        public object[] SaveMembers()
        {
            return new object[]
            {
                m_Containers
            };
        }

        #endregion

        public void AddContainer(IActionContainer actionContainer, bool add)
        {
            if (add && !Containers.Contains(actionContainer))
            {
                Containers.Add(actionContainer);
                AddListeners(actionContainer, true);
            }
            else if (!add && Containers.Contains(actionContainer))
            {
                Containers.Remove(actionContainer);
                AddListeners(actionContainer, false);
            }
        }
        

        public IActionContainer GetContainerWithName(string name)
        {
            return Containers.FirstOrDefault(container => container.Name == name);
        }

        public bool AddAction(IAction action)
        {
            return Containers.Select(container => container.AddAction(action)).FirstOrDefault();
        }

        public bool RemoveAction(IAction action)
        {
            return Containers.Any(container => container.RemoveAction(action));
        }


        private void GenerateCompanionWheel()
        {
            m_Containers = new List<IActionContainer>();
            ActionContainer container = new ActionContainer("Companion Actions", 8);
            m_Containers.Add(container);

            AddListeners(container, true);
        }

        private void AddListeners(IActionContainer actionContainer, bool addListener)
        {
            foreach (var actionSlots in actionContainer.Slots)
            {
                if (addListener)
                    actionSlots.onChanged += OnSlotChanged;
                else
                    actionSlots.onChanged -= OnSlotChanged;
            }
        }

        private void OnSlotChanged(IActionSlot slot) => onActionsChanged?.Invoke(slot);

        public bool ContainsAction(IAction action)
        {
            return Enumerable.Any(Containers, container => container.ContainsAction(action));
        }
    }
}