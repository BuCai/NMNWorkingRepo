using Malee;
using SurvivalTemplatePro.InventorySystem;
using System;
using UnityEngine;

namespace SurvivalTemplatePro
{
    [Serializable]
    public class StringList : ReorderableArray<string> { }

    [Serializable]
    public class AudioClipList : ReorderableArray<AudioClip> { }

#if SURVIVAL_TEMPLATE_PRO
    [Serializable]
    public class CraftRequirementList : ReorderableArray<CraftRequirement> { }

    [Serializable]
    public class ItemPropertyDefinitionList : ReorderableArray<InventorySystem.ItemPropertyDefinition> { }

    [Serializable]
    public class ItemPropertyInfoList : ReorderableArray<ItemPropertyInfo> { }
#endif
}