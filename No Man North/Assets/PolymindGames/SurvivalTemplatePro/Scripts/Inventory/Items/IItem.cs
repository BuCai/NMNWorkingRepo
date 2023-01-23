using UnityEngine.Events;

namespace SurvivalTemplatePro.InventorySystem {
    public interface IItem {
#if SURVIVAL_TEMPLATE_PRO
        ItemInfo Info { get; }
#endif
        IItemProperty[] Properties { get; }

        int Id { get; }
        string Name { get; }
        float TotalWeight { get; }
        int CurrentStackSize { get; set; }

        event PropertyChangedCallback onPropertyChanged;
        event UnityAction onStackChanged;


        bool HasProperty(int id);
        bool HasProperty(string name);

        /// <summary>
        /// Use this if you are sure the item has this property.
        /// </summary>
        IItemProperty GetProperty(int id);

        /// <summary>
        /// Use this if you are sure the item has this property.
        /// </summary>
        IItemProperty GetProperty(string name);

        /// <summary>
        /// Use this if you are NOT sure the item has this property.
        /// </summary>
        bool TryGetProperty(int id, out IItemProperty itemProperty);

        /// <summary>
        /// Use this if you are NOT sure the item has this property.
        /// </summary>
        bool TryGetProperty(string name, out IItemProperty itemProperty);

        /// <summary>
        /// Use this if you are sure the item has this property.
        /// </summary>
        IItemProperty[] GetAllPropertiesWithId(int id);

        /// <summary>
        /// Use this if you are sure the item has this property.
        /// </summary>
        IItemProperty[] GetAllPropertiesWithName(string name);
    }
}