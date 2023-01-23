using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SurvivalTemplatePro;
using SurvivalTemplatePro.InventorySystem;

public class EnginePartInteractable : UseItemInteractable {
    [SerializeField] private int partIndex;
    [SerializeField] private string partItemName;
    [SerializeField] private RvEngineBay engineBay;

    public override void OnInteract(ICharacter _character) {
        base.OnInteract(_character);
        if (engineBay.parts[partIndex].isEnabled) {
            inventory.AddItems(partItemName, 1);
            engineBay.TogglePart(partIndex);
        } else {
            if (inventory.RemoveItems(partItemName, 1) != 0) {
                engineBay.TogglePart(partIndex);
            }
        }

    }
}
