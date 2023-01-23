using System.Collections;
using System.Collections.Generic;
using SurvivalTemplatePro;
using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

public class AnimalInteractable : Interactable
{
    [SerializeField] private InventoryStartupItemsInfo.ItemContainerStartupItems lootItems;
    public override void OnInteract(ICharacter character)
    {
        var randomIndex = Random.Range(0, lootItems.StartupItems.Length);
        var randomLootItem = lootItems.StartupItems[randomIndex];
        character.Inventory.AddItem(randomLootItem.GenerateItem(), ItemContainerFlags.Storage);
    }
}
