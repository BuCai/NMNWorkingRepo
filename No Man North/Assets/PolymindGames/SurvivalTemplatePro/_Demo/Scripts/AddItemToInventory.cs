using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.Demo
{
    public class AddItemToInventory : MonoBehaviour
    {
        [SerializeField, ReorderableListExposed]
        private ItemCategoryReference[] m_Categories;


        public void AddItemToCharacter(ICharacter character) 
        {
            var category = m_Categories.SelectRandom().GetItemCategory();
            Item itemToAdd = new Item(category.Items.SelectRandom());
            character.Inventory.AddItem(itemToAdd);
        }

        public void AddItemToCollider(Collider collider)
        {
            if (collider.TryGetComponent(out ICharacter character))
                AddItemToCharacter(character);
        }
    }
}