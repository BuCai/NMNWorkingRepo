using System;
using System.Collections;
using System.Linq;
using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.CompanionSystem
{
    [Serializable]
    public class ActionContainer : IActionContainer
    {
        public IActionSlot this[int i]
        {
            get => m_Slots[i];
            set => m_Slots[i] = value as ActionSlot;
        }

        /// <summary>Slot count.</summary>
        public int Count => m_Slots.Length;

        public IActionSlot[] Slots => m_Slots;

        public string Name => m_Name;

        [SerializeField] [Tooltip("The name of the item container.")]
        private string m_Name;


        [SerializeField] [Tooltip("Number of item slots that this container has (e.g. Holster 8, Backpack 25 etc.).")]
        private ActionSlot[] m_Slots;

        public bool CanAddAction { get; set; }
        public bool CanRemoveAction { get; set; }

        public event ActionContainerChangedCallback onContainerChanged;


        #region Initialization

        public void OnLoad()
        {
            foreach (var slot in m_Slots)
                slot.onChanged += OnSlotChanged;
        }

        public ActionContainer(string name, int size)
        {
            m_Name = name;
            m_Slots = new ActionSlot[size];

            for (int i = 0; i < m_Slots.Length; i++)
            {
                m_Slots[i] = new ActionSlot();
            }

            CanAddAction = true;
            CanRemoveAction = true;
        }

        IEnumerator IEnumerable.GetEnumerator() => m_Slots.GetEnumerator();

        private void OnSlotChanged(IActionSlot slot)
        {
            onContainerChanged?.Invoke(slot);
        }

        #endregion

        #region Add Items

        /// <summary>
        /// Adds an item to this container
        /// </summary>
        /// <param name="item"></param>
        /// <param name="flags"></param>
        /// <returns> Stack added count. </returns>
        public bool AddAction(IAction action)
        {
            // Try find an empty slot for it
            foreach (var slot in m_Slots)
            {
                if (!slot.HasAction)
                {
                    slot.SetAction(action);
                    Debug.Log("Added action to slot");
                    return true;
                }
            }
            Debug.Log("No empty slots");
            return false;
        }

        #endregion

        #region Remove Items

        public bool RemoveAction(int id)
        {
            foreach (var slot in m_Slots)
                if (slot.HasAction && slot.Action.Id == id)
                {
                    slot.SetAction(null);
                    return true;
                }

            return false;
        }

        public bool RemoveAction(IAction action)
        {
            foreach (var slot in m_Slots)
                if (slot.Action == action)
                {
                    slot.SetAction(null);
                    return true;
                }

            return false;
        }

        #endregion

        #region Item Checks

        public bool ContainsAction(IAction action)
        {
            return m_Slots.Any(slot => slot.Action == action);
        }

        public int GetSlotIndex(IActionSlot actionSlot)
        {
            for (var i = 0; i < m_Slots.Length; i++)
            {
                if (m_Slots[i] == actionSlot)
                    return i;
            }

            return -1;
        }

        #endregion
    }
}