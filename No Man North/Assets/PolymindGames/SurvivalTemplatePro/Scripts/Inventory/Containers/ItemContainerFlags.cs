using System;

namespace SurvivalTemplatePro.InventorySystem
{
    [Flags]
    public enum ItemContainerFlags
    {
        Nothing = 0,
        Everything = Storage | Equipment | Holster | External,
        Storage = 1,
        Equipment = 2,
        Holster = 4,
        External = 8, 
    }

    public static class ItemContainerFlagExtensions
    {
        /// <summary>
        /// 
        /// </summary>
        public static bool Has(this ItemContainerFlags thisFlags, ItemContainerFlags flag)
        {
            return ((thisFlags & flag) == flag) || (flag == ItemContainerFlags.Everything);
        }
    }
}
