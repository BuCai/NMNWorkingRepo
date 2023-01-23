using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro.InventorySystem
{
    [DisallowMultipleComponent()]
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/inventory")]
    public class Inventory : CharacterBehaviour, IInventory, ISaveableComponent
    {
        public IList<IItemContainer> Containers
        {
            get
            {
                if (m_Containers == null)
                    GenerateContainers();

                return m_Containers;
            }
        }

        public ContainerGenerator[] StartupContainers => m_StartupContainers;

        public event ItemSlotChangedCallback onInventoryChanged;

        [SerializeField, ReorderableList]
        [Tooltip("The initial item containers")]
        private ContainerGenerator[] m_StartupContainers;

        private IList<IItemContainer> m_Containers;


        #region Save & Load
        public void LoadMembers(object[] members)
        {
            m_Containers = members[0] as IList<IItemContainer>;

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

        public void AddContainer(IItemContainer itemContainer, bool add)
        {
            if (add && !Containers.Contains(itemContainer))
            {
                Containers.Add(itemContainer);
                AddListeners(itemContainer, true);
            }
            else if (!add && Containers.Contains(itemContainer))
            {
                Containers.Remove(itemContainer);
                AddListeners(itemContainer, false);
            }
        }

        public bool HasContainerWithFlags(ItemContainerFlags flags)
        {
            for (int i = 0; i < Containers.Count; i++)
            {
                if (flags.Has(Containers[i].Flag))
                    return true;
            }

            return false;
        }

        public IItemContainer GetContainerWithFlags(ItemContainerFlags flags)
        {
            for (int i = 0; i < Containers.Count; i++)
            {
                if (flags.Has(Containers[i].Flag))
                    return Containers[i];
            }

            return null;
        }

        public IItemContainer GetContainerWithName(string name)
        {
            for (int i = 0; i < Containers.Count; i++)
            {
                if (Containers[i].Name == name)
                    return Containers[i];
            }

            return null;
        }

        public int AddItem(IItem item, ItemContainerFlags flags = ItemContainerFlags.Everything)
        {
            int addedInTotal = 0;

            for (int i = 0; i < Containers.Count; i++)
            {
                if (flags.Has(Containers[i].Flag))
                {
                    addedInTotal += Containers[i].AddItem(item);

                    if (addedInTotal >= item.CurrentStackSize)
                        break;
                }
            }

            return addedInTotal;
        }

        public bool AddOrSwap(IItemContainer slotParent, IItemSlot slot, ItemContainerFlags flags)
        {
            for (int i = 0; i < Containers.Count; i++)
            {
                if (flags.Has(Containers[i].Flag))
                {
                    bool addedOrSwapped = Containers[i].AddOrSwap(slotParent, slot);

                    if (addedOrSwapped)
                        return true;
                }
            }

            return false;
        }

        public int AddItems(string itemName, int amountToAdd, ItemContainerFlags flags)
        {
            int addedInTotal = 0;

            if (amountToAdd > 0)
            {
                for (int i = 0; i < Containers.Count; i++)
                {
                    if (flags.Has(Containers[i].Flag))
                    {
                        int added = Containers[i].AddItem(itemName, amountToAdd);
                        addedInTotal += added;

                        if (added == addedInTotal)
                            return addedInTotal;
                    }
                }
            }

            return addedInTotal;
        }

        public int AddItems(int itemId, int amountToAdd, ItemContainerFlags flags)
        {
            int addedInTotal = 0;

            if (amountToAdd > 0)
            {
                for (int i = 0; i < Containers.Count; i++)
                {
                    if (flags.Has(Containers[i].Flag))
                    {
                        int added = Containers[i].AddItem(itemId, amountToAdd);
                        addedInTotal += added;

                        if (added == addedInTotal)
                            return addedInTotal;
                    }
                }
            }

            return addedInTotal;
        }

        public bool RemoveItem(IItem item, ItemContainerFlags flags)
        {
            for (int i = 0; i < Containers.Count; i++)
            {
                if (flags.Has(Containers[i].Flag))
                {
                    if (Containers[i].RemoveItem(item))
                        return true;
                }
            }

            return false;
        }

        public int RemoveItems(string itemName, int amountToRemove, ItemContainerFlags flags)
        {
            int removedInTotal = 0;

            if (amountToRemove > 0)
            {
                for (int i = 0; i < Containers.Count; i++)
                {
                    if (flags.Has(Containers[i].Flag))
                    {
                        int removedNow = Containers[i].RemoveItem(itemName, amountToRemove);
                        removedInTotal += removedNow;

                        if (removedNow == removedInTotal)
                            return removedInTotal;
                    }
                }
            }

            return removedInTotal;
        }

        public int RemoveItems(int itemId, int amountToRemove, ItemContainerFlags flags)
        {
            int removedInTotal = 0;

            if (amountToRemove > 0)
            {
                for (int i = 0; i < Containers.Count; i++)
                {
                    if (flags.Has(Containers[i].Flag))
                    {
                        int removedNow = Containers[i].RemoveItem(itemId, amountToRemove);
                        removedInTotal += removedNow;

                        if (removedNow == removedInTotal)
                            return removedInTotal;
                    }
                }
            }

            return removedInTotal;
        }

        public int GetItemCount(string itemName, ItemContainerFlags flags)
        {
            int count = 0;

            for (int i = 0; i < Containers.Count; i++)
            {
                if (flags.Has(Containers[i].Flag))
                    count += Containers[i].GetItemCount(itemName);
            }

            return count;
        }

        public int GetItemCount(int itemId, ItemContainerFlags flags)
        {
            int count = 0;

            for (int i = 0; i < Containers.Count; i++)
            {
                if (flags.Has(Containers[i].Flag))
                    count += Containers[i].GetItemCount(itemId);
            }

            return count;
        }

        private void GenerateContainers() 
        {
            m_Containers = new List<IItemContainer>();

            for (int i = 0; i < m_StartupContainers.Length; i++)
            {
                ItemContainer container = m_StartupContainers[i].GenerateContainer();
                m_Containers.Add(container);

                AddListeners(container, true);
            }
        }

        private void AddListeners(IItemContainer itemContainer, bool addListener)
        {
            for (int i = 0; i < itemContainer.Slots.Length; i++)
            {
                if (addListener)
                    itemContainer.Slots[i].onChanged += OnSlotChanged;
                else
                    itemContainer.Slots[i].onChanged -= OnSlotChanged;
            }
        }

        private void OnSlotChanged(IItemSlot slot, ItemSlotChangeType changeType) => onInventoryChanged?.Invoke(slot, changeType);

        public bool ContainsItem(IItem item, ItemContainerFlags flags)
        {
            for (int i = 0; i < Containers.Count; i++)
            {
                if (flags.Has(Containers[i].Flag) && Containers[i].ContainsItem(item))
                    return true;
            }

            return false;
        }
    }
}