using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Firearms/Ammo/Infinite Ammo")]
    public class FirearmInfiniteAmmo : FirearmAmmoBehaviour
    {
        public override int RemoveAmmo(int amount) => amount;
        public override int AddAmmo(int amount) => amount;
        public override int GetAmmoCount() => 1000;
    }
}