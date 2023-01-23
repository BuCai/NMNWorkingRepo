using SurvivalTemplatePro.InventorySystem;
using UnityEngine;

namespace SurvivalTemplatePro.BuildingSystem
{
    /// <summary>
    /// TODO: Remove/Refactor
    /// Acts as a wrapper for adding inventory based materials (e.g. sticks, rope etc.) to a structure.
    /// </summary>
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/inventory#inventory-materials-handler-module")]
    public class InventoryMaterialsHandler : CharacterBehaviour, IInventoryMaterialsHandler
    {
        private IObjectCarryController m_ObjectCarryController;
        private IInventory m_Inventory;


        public override void OnInitialized()
        {
            GetModule(out m_Inventory);
            GetModule(out m_ObjectCarryController);
        }

        public void AddMaterial(BuildablePreview preview)
        {
            if (m_ObjectCarryController.CarriedObjectsCount > 0)
                return;

            if (preview != null)
            {
                foreach (var buildRequirement in preview.GetAllBuildRequirements())
                {
                    if (buildRequirement.IsCompleted())
                        continue;

                    var materialInfo = BuildMaterialsDatabase.GetBuildingMaterialById(buildRequirement.BuildingMaterialId);

                    if (materialInfo != null)
                    {
                        if (m_Inventory.RemoveItems(materialInfo.Item, 1, ItemContainerFlags.Storage) > 0)
                            preview.TryAddBuildingMaterial(materialInfo);
                    }
                }
            }
        }
    }
}