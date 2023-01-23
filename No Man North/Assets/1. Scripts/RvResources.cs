using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SurvivalTemplatePro;

//Handles the gas and electricity resources of the rv
public class RvResources : MonoBehaviour {
    private int propanePropertyId;
    private int propaneCapacityPropertyId;
    [SerializeField] private StorageStation ptSlot; //Propane tank slot

    public float propaneLeft {
        get {
            if (ptSlot.ItemContainer.Slots[0].HasItem) {
                return ptSlot.ItemContainer.Slots[0].Item.GetProperty(propanePropertyId).Float;
            } else {
                return 0;
            }
        }
        set {
            if (ptSlot.ItemContainer.Slots[0].HasItem) {
                ptSlot.ItemContainer.Slots[0].Item.GetProperty(propanePropertyId).Float =
                    Mathf.Clamp(value, 0, propaneCapacity);
            } else {
                return;
            }
        }
    }

    public float propaneCapacity {
        get {
            if (ptSlot.ItemContainer.Slots[0].HasItem) {
                return ptSlot.ItemContainer.Slots[0].Item.GetProperty(propaneCapacityPropertyId).Float;
            } else {
                return 0;
            }
        }
    }

    private void Awake() {
        propanePropertyId = ItemDatabase.GetPropertyByName("Gas").Id;
        propaneCapacityPropertyId = ItemDatabase.GetPropertyByName("GasCapacity").Id;
    }
}
