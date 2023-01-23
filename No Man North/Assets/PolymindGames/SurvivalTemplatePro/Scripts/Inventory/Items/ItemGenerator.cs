using System;
using UnityEngine;
using Random = UnityEngine.Random;

namespace SurvivalTemplatePro.InventorySystem
{
    [Serializable]
    public class ItemGenerator
    {
        [SerializeField]
        private ItemGenerationMethod Method;

        [SerializeField]
        private ItemReference SpecificItem;

        [SerializeField, Range(0, 30)]
        private int MinCount = 1;

        [SerializeField, Range(0, 30)]
        private int MaxCount = 1;

        [SerializeField]
        private ItemCategoryReference Category;


        public Item GenerateItem() 
        {
            if (Method == ItemGenerationMethod.Specific)
            {
                return CreateItem(SpecificItem.GetItem());
            }
            else if (Method == ItemGenerationMethod.RandomFromCategory)
            {
                ItemInfo itemInfo = ItemDatabase.GetRandomItemFromCategory(Category);

                if (itemInfo != null)
                    return CreateItem(itemInfo);
            }
            else if (Method == ItemGenerationMethod.Random)
            {
                var category = ItemDatabase.GetRandomCategory();

                if (category != null)
                {
                    ItemInfo itemInfo = ItemDatabase.GetRandomItemFromCategory(category.Name);

                    if (itemInfo != null)
                        return CreateItem(itemInfo);
                }
            }

            return null;
        }

        public ItemInfo GetItemInfo() 
        {
            if (Method == ItemGenerationMethod.Specific)
            {
                return SpecificItem.GetItem();
            }
            else if (Method == ItemGenerationMethod.RandomFromCategory)
            {
                ItemInfo itemInfo = ItemDatabase.GetRandomItemFromCategory(Category);
                return itemInfo;
            }
            else if (Method == ItemGenerationMethod.Random)
            {
                var category = ItemDatabase.GetRandomCategory();

                if (category != null)
                {
                    ItemInfo itemInfo = ItemDatabase.GetRandomItemFromCategory(category.Name);
                    return itemInfo;
                }
            }

            return null;
        }
       
        private Item CreateItem(ItemInfo itemInfo) 
        {
            int itemCount = Random.Range(MinCount, MaxCount + 1);

            if (itemCount == 0)
                return null;

            return new Item(itemInfo, itemCount);
        }
    }

    public enum ItemGenerationMethod { Specific, Random, RandomFromCategory }
}