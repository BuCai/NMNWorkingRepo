namespace SurvivalTemplatePro.InventorySystem
{
    public interface IItemProperty
    {
        string PropertyName { get; }
        int PropertyId { get; }
        ItemPropertyType PropertyType { get; }

        bool Boolean { get; set; }
        int Integer { get; set; }
        float Float { get; set; }
        int ItemId { get; set; }

        event PropertyChangedCallback onChanged;
    }

    public delegate void PropertyChangedCallback(IItemProperty property);
}