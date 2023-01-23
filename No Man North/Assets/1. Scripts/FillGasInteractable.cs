using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MLC.NoManNorth.Eric;
using SurvivalTemplatePro;
using SurvivalTemplatePro.InventorySystem;

public class FillGasInteractable : UseItemInteractable {
    [SerializeField] private RVIntergrationsToNWH rvIntegrations;
    private int fuelPropertyId;

    private void Awake() {
        base.Awake();
        fuelPropertyId = ItemDatabase.GetPropertyByName("Fuel").Id;
    }

    public override void OnInteract(ICharacter _character) {
        base.OnInteract(_character);
        if (item.HasProperty(fuelPropertyId)) {
            float fuelAmount = item.GetProperty(fuelPropertyId).Float;
            item.GetProperty(fuelPropertyId).Float -= rvIntegrations.FillUpGas(item.GetProperty(fuelPropertyId).Float);
            base.UpdateInteractionStatus(base.selectionHandler.SelectedIndex);
        }
    }
}
