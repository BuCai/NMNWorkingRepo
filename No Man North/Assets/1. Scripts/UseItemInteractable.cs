using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SurvivalTemplatePro;
using SurvivalTemplatePro.InventorySystem;

//Custom interactable that is only enabled when the player is holding a specific item id
//Can also check if the item has a specific property with a float over 0
//Inherit off of this to add functionality 
public class UseItemInteractable : Interactable {

    [SerializeField] private int requiredItemId;
    [SerializeField] private string requiredPropertyName = ""; //Leave empty if no property is required
    [SerializeField] private string containerName;

    private ICharacter character;
    protected IInventory inventory;
    protected IWieldableSelectionHandler selectionHandler;
    protected IItemContainer container;
    private int propertyId;
    protected IItem item;
    protected bool loaded = false;

    protected void Awake() {
        LevelManager.onGameLoaded += StartLoad;
    }

    private void StartLoad() {
        StartCoroutine(Load());
    }

    private IEnumerator Load() {
        yield return new WaitForSeconds(0.3f);
        character = GameObject.FindGameObjectWithTag("Player").GetComponentInChildren<ICharacter>();
        if (character == null) {
            Debug.Log("Player character module not found");
            yield break;
        }
        character.TryGetModule(out inventory);
        character.TryGetModule(out selectionHandler);
        container = inventory.GetContainerWithName(containerName);
        if (inventory == null || selectionHandler == null || container == null) {
            Debug.LogError("Inventory/Wieldable modules not found or container name invalid");
            yield break;
        }
        if (requiredPropertyName != "") {
            propertyId = ItemDatabase.GetPropertyByName(requiredPropertyName).Id;
        }
        loaded = true;
        UpdateInteractionStatus(selectionHandler.SelectedIndex);
        selectionHandler.onSelectedChanged += UpdateInteractionStatus;
    }

    public void UpdateInteractionStatus(int selectedIndex) {
        if (!loaded) {
            return;
        }
        if (selectedIndex < 0 || !container.Slots[selectedIndex].HasItem || (requiredPropertyName != "" && (!container.Slots[selectedIndex].Item.HasProperty(propertyId) || container.Slots[selectedIndex].Item.GetProperty(propertyId).Float <= 0.01f))) {
            InteractionEnabled = false;
            item = null;
            return;
        }
        if (container.Slots[selectionHandler.SelectedIndex].Item.Id == requiredItemId) {
            InteractionEnabled = true;
        } else {
            InteractionEnabled = false;
            item = null;
        }
    }

    public override void OnInteract(ICharacter _character) {
        if (character == _character) {
            int selectedIndex = selectionHandler.SelectedIndex;
            if (selectedIndex < 0 || !container.Slots[selectedIndex].HasItem || container.Slots[selectedIndex].Item.Id != requiredItemId || (requiredPropertyName != "" && (!container.Slots[selectedIndex].Item.HasProperty(propertyId) || container.Slots[selectedIndex].Item.GetProperty(propertyId).Float <= 0.01f))) {
                return;
            }
            base.OnInteract(character);
            item = container.Slots[selectionHandler.SelectedIndex].Item;
        } else {
            Debug.LogError("Characters do not match");
        }
    }
}
