using SurvivalTemplatePro.InventorySystem;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.WieldableSystem
{
    [RequireComponent(typeof(STPEventHandler))]
    [AddComponentMenu("Wieldables/Firearms/Firearm")]
    public class Firearm : Wieldable, IFirearm, IUseHandler, IAimHandler, IReloadHandler
    {
        public IFirearmAimer Aimer => m_CurrentAimer;
        public IFirearmTrigger Trigger => m_CurrentTrigger;
        public IFirearmShooter Shooter => m_CurrentShooter;
        public IFirearmAmmo Ammo => m_CurrentAmmo;
        public IFirearmReloader Reloader => m_CurrentReloader;
        public IFirearmRecoil Recoil => m_CurrentRecoil;

        public bool IsReloading => m_CurrentReloader.IsReloading;
        public bool IsAiming => m_CurrentAimer.IsAiming;

        public event UnityAction<IFirearmAimer> onAimerChanged;
        public event UnityAction<IFirearmTrigger> onTriggerChanged;
        public event UnityAction<IFirearmShooter> onShooterChanged;
        public event UnityAction<IFirearmAmmo> onAmmoChanged;
        public event UnityAction<IFirearmReloader> onReloaderChanged;
        public event UnityAction<IFirearmRecoil> onRecoilChanged;

        public event UnityAction onUse;

        [Title("Aiming")]

        [SerializeField]
        private bool m_CancelAimOnShoot;

        [SerializeField]
        private bool m_CanAimWhileReloading;

        [SerializeField]
        private bool m_CanAimWhileDry = true;

        [Title("Ammo")]

        [SerializeField]
        [Tooltip("Ammo in magazine correponding property.")]
        private ItemPropertyReference m_AmmoProperty;

        [SerializeField]
        private SimpleSound m_DryFireSound;

        [Title("Reloading")]

        [SerializeField]
        private bool m_CancelReloadOnShoot;

        [SerializeField]
        private bool m_ReloadOnDryFire;

        [Title("Base Attachments")]

        [SerializeField]
        private FirearmAimerBehaviour m_BaseAimer;

        [SerializeField]
        private FirearmTriggerBehaviour m_BaseTrigger;

        [SerializeField]
        private FirearmShooterBehaviour m_BaseShooter;

        [SerializeField]
        private FirearmAmmoBehaviour m_BaseAmmo;

        [SerializeField]
        private FirearmReloaderBehaviour m_BaseReloader;

        [SerializeField]
        private FirearmRecoilBehaviour m_BaseRecoil;

#if UNITY_EDITOR
        [Title("Debug")]

        [SerializeField]
        private bool m_HasInfiniteAmmo;
#endif

        private IFirearmAimer m_CurrentAimer;
        private IFirearmTrigger m_CurrentTrigger;
        private IFirearmShooter m_CurrentShooter;
        private IFirearmAmmo m_CurrentAmmo;
        private IFirearmReloader m_CurrentReloader;
        private IFirearmRecoil m_CurrentRecoil;


        public override void AttachItem(IItem itemToAttach)
        {
            base.AttachItem(itemToAttach);

            // Item get attached
            if (itemToAttach != null)
            {
                // Load the current 'ammo in magazine count' that's saved in one of the properties on the given item.
                if (itemToAttach.TryGetProperty(m_AmmoProperty, out IItemProperty ammoProperty))
                    m_CurrentReloader.AmmoInMagazine = ammoProperty.Integer;
            }
        }

        protected override void DetachItem()
        {
            // Save the current 'ammo count in the magazine' to the item
            if (AttachedItem != null && AttachedItem.TryGetProperty(m_AmmoProperty, out IItemProperty ammoProperty))
                ammoProperty.Integer = m_CurrentReloader.AmmoInMagazine;

            base.DetachItem();
        }

        public override void OnHolster(float holsterSpeed)
        {
            base.OnHolster(holsterSpeed);

            // Release trigger if held
            if (m_CurrentTrigger.IsTriggerHeld)
                m_CurrentTrigger.ReleaseTrigger();

            // End aim if active
            EndAiming();

            // Cancel reload if active
            CancelReloading();
        }

        public Ray GetShootRay(float spreadMod)
        {
            float firearmSpread = (m_CurrentAimer.IsAiming ? m_CurrentAimer.AimShootSpread : m_CurrentAimer.HipShootSpread) * spreadMod;
            return RayGenerator.GenerateRay(firearmSpread);
        }

        private void Shoot(float triggerValue)
        {
            // Reload on dry fire
            if (m_ReloadOnDryFire && m_CurrentReloader.IsMagazineEmpty)
            {
                StartReloading();

                return;
            }

            // Cancel reload
            if (IsReloading)
            {
                if (m_CancelReloadOnShoot)
                    CancelReloading();

                LastEquipOrHolsterTime = Time.time;

                return;
            }

            bool canShoot = m_CurrentReloader.TryUseAmmo(m_CurrentShooter.AmmoPerShot);

#if UNITY_EDITOR
            if (m_HasInfiniteAmmo)
                canShoot = true;
#endif

            // If the firearm has enough ammo in the magazine, shoot
            if (canShoot)
            {
                if (m_CancelAimOnShoot && m_CurrentAimer.IsAiming)
                    EndAiming();

                float recoilValue = triggerValue * m_CurrentRecoil.RecoilForce;
                m_CurrentShooter.Shoot(recoilValue);

                onUse?.Invoke();
            }
        }

        #region Attachments

        public void SetTrigger(IFirearmTrigger trigger)
        {
            var prevTrigger = m_CurrentTrigger;
            m_CurrentTrigger = trigger ?? m_BaseTrigger;

            if (prevTrigger != m_CurrentTrigger)
            {
                onTriggerChanged?.Invoke(m_CurrentTrigger);

                if (prevTrigger != null)
                {
                    prevTrigger.onShoot -= Shoot;
                    prevTrigger.Detach();
                }

                m_CurrentTrigger.onShoot += Shoot;
                m_CurrentTrigger.Attach();
            }
        }

        public void SetReloader(IFirearmReloader reloader)
        {
            var prevReloader = m_CurrentReloader;
            m_CurrentReloader = reloader ?? m_BaseReloader;

            if (prevReloader != m_CurrentReloader)
            {
                onReloaderChanged?.Invoke(m_CurrentReloader);

                if (prevReloader != null)
                    prevReloader.Detach();

                m_CurrentReloader.Attach();
            }
        }

        public void SetAimer(IFirearmAimer aimer)
        {
            var prevAimer = m_CurrentAimer;
            m_CurrentAimer = aimer ?? m_BaseAimer;

            if (prevAimer != m_CurrentAimer)
            {
                onAimerChanged?.Invoke(m_CurrentAimer);

                if (prevAimer != null)
                    prevAimer.Detach();

                m_CurrentAimer.Attach();
            }
        }

        public void SetShooter(IFirearmShooter shooter)
        {
            var prevShooter = m_CurrentShooter;
            m_CurrentShooter = shooter ?? m_BaseShooter;

            if (prevShooter != m_CurrentShooter)
            {
                if (prevShooter != null)
                    prevShooter.Detach();

                onShooterChanged?.Invoke(m_CurrentShooter);
                m_CurrentShooter.Attach();
            }
        }

        public void SetAmmo(IFirearmAmmo ammo)
        {
            var prevAmmo = m_CurrentAmmo;
            m_CurrentAmmo = ammo ?? m_BaseAmmo;

            if (prevAmmo != m_CurrentAmmo)
            {
                if (prevAmmo != null)
                    prevAmmo.Detach();

                onAmmoChanged?.Invoke(m_CurrentAmmo);
                m_CurrentAmmo.Attach();
            }
        }

        public void SetRecoil(IFirearmRecoil recoil)
        {
            var prevRecoil = m_CurrentRecoil;
            m_CurrentRecoil = recoil ?? m_BaseRecoil;

            if (prevRecoil != m_CurrentRecoil)
            {
                if (prevRecoil != null)
                    prevRecoil.Detach();

                onRecoilChanged?.Invoke(m_CurrentRecoil);
                m_CurrentRecoil.Attach();
            }
        }

        #endregion

        #region Input Handling

        public void Use(UsePhase usePhase)
        {
            bool playDryFireSound = (usePhase == UsePhase.Start && m_CurrentReloader.IsMagazineEmpty);

#if UNITY_EDITOR
            playDryFireSound &= !m_HasInfiniteAmmo;
#endif

            // Play dry fire sound
            if (playDryFireSound)
            {
                AudioPlayer.PlaySound(m_DryFireSound);
                return;
            }

            bool canUse = (!m_IsUseActionBlocked) &&
                          (usePhase != UsePhase.End) &&
                          (Time.time > (LastEquipOrHolsterTime + HolsterDuration + 0.1f)) &&
                          (ItemDurability == null || ItemDurability.Float > 0f);
    
            if (canUse)
                m_CurrentTrigger.HoldTrigger();
            else
                m_CurrentTrigger.ReleaseTrigger();
        }

        public void StartAiming()
        {
            bool canAim = (!m_IsAimActionBlocked) &&
                          (Time.time > (LastEquipOrHolsterTime + HolsterDuration + 0.1f)) &&
                          (m_CanAimWhileReloading || !IsReloading) &&
                          (m_CanAimWhileDry || !m_CurrentReloader.IsMagazineEmpty);

            if (canAim)
                m_CurrentAimer.TryStartAim();
        }

        public void EndAiming() => m_CurrentAimer.TryEndAim();

        public void StartReloading()
        {
            bool canReload = (!m_IsReloadActionBlocked) &&
                             (Time.time > (LastEquipOrHolsterTime + HolsterDuration + 0.1f));

            if (canReload && m_CurrentReloader.TryStartReload(m_CurrentAmmo))
            {
                if (!m_CanAimWhileReloading && IsAiming)
                    EndAiming();
            }
        }

        public void CancelReloading() => m_CurrentReloader.CancelReload(m_CurrentAmmo);

        #endregion

        #region Crosshair

        public override float GetCrosshairAccuracy()
        {
            float firearmSpread = (m_CurrentAimer.IsAiming ? m_CurrentAimer.AimShootSpread : m_CurrentAimer.HipShootSpread);
            return RayGenerator.GetRaySpread() * firearmSpread;
        }

        #endregion

        #region Action Blocking

        private bool m_IsUseActionBlocked = false;
        private readonly List<Object> m_UseBlockers = new List<Object>();

        public void RegisterUseBlocker(Object blocker)
        {
            if (m_UseBlockers.Contains(blocker))
                return;

            m_UseBlockers.Add(blocker);
            m_IsUseActionBlocked = m_UseBlockers.Count > 0;
        }

        public void UnregisterUseBlocker(Object blocker)
        {
            if (!m_UseBlockers.Contains(blocker))
                return;

            m_UseBlockers.Remove(blocker);
            m_IsUseActionBlocked = m_UseBlockers.Count > 0;
        }


        private bool m_IsAimActionBlocked = false;
        private readonly List<Object> m_AimBlockers = new List<Object>();

        public void RegisterAimBlocker(Object blocker)
        {
            if (m_AimBlockers.Contains(blocker))
                return;

            m_AimBlockers.Add(blocker);
            m_IsAimActionBlocked = m_AimBlockers.Count > 0;

            if (m_IsAimActionBlocked && IsAiming)
                EndAiming();
        }

        public void UnregisterAimBlocker(Object blocker)
        {
            if (!m_AimBlockers.Contains(blocker))
                return;

            m_AimBlockers.Remove(blocker);
            m_IsAimActionBlocked = m_AimBlockers.Count > 0;
        }


        private bool m_IsReloadActionBlocked = false;
        private readonly List<Object> m_ReloadBlockers = new List<Object>();

        public void RegisterReloadBlocker(Object blocker)
        {
            if (m_ReloadBlockers.Contains(blocker))
                return;

            m_ReloadBlockers.Add(blocker);
            m_IsReloadActionBlocked = m_ReloadBlockers.Count > 0;

            if (m_IsReloadActionBlocked && IsReloading)
                CancelReloading();
        }

        public void UnregisterReloadBlocker(Object blocker)
        {
            if (!m_ReloadBlockers.Contains(blocker))
                return;

            m_ReloadBlockers.Remove(blocker);
            m_IsReloadActionBlocked = m_ReloadBlockers.Count > 0;
        }

        #endregion
    }
}
