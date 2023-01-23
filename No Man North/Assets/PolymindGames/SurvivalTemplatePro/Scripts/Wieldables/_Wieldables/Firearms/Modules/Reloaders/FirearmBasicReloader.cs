using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Firearms/Reloaders/Basic Reloader")]
    public class FirearmBasicReloader : FirearmReloaderBehaviour
	{
        public override int MagazineSize => m_MagazineSize;
        public override int AmmoToLoad => m_AmmoToLoad;

        [Title("Settings")]

        [SerializeField, Range(0,500)]
        private int m_MagazineSize;

        [SerializeField, Range(0.01f, 15f)]
        private float m_ReloadDuration;

        [SpaceArea]

        [SerializeField, ReorderableList(elementLabel:"Sound", Foldable = true)]
        private DelayedSoundRandom[] m_ReloadSounds;

        [SerializeField, HideInInspector]
        private STPEventReference m_ReloadEvent = new STPEventReference("On Reload");

        protected float m_ReloadEndTime;
        protected int m_AmmoToLoad = 0;


        public override bool TryUseAmmo(int amount)
        {
            if (IsMagazineEmpty || AmmoInMagazine < amount)
                return false;

            AmmoInMagazine -= amount;

            return true;
        }

        public override void CancelReload(IFirearmAmmo ammoModule)
        {
            if (!IsReloading)
                return;

            ammoModule.AddAmmo(m_AmmoToLoad);
            IsReloading = false;
        }

        public override bool TryStartReload(IFirearmAmmo ammoModule)
		{
            if (IsReloading || IsMagazineFull)
                return false;

            m_AmmoToLoad = ammoModule.RemoveAmmo(MagazineSize - AmmoInMagazine);

            if (m_AmmoToLoad > 0)
            {
                m_ReloadEndTime = Time.time + m_ReloadDuration;

                // Audio
                Firearm.AudioPlayer.PlaySounds(m_ReloadSounds);

                // Events
                Firearm.EventHandler.TriggerAction(m_ReloadEvent, 1f);

                IsReloading = true;

                return true;
            }

            return false;
		}

        protected virtual void Update()
		{
			if (IsReloading) 
			{
				if (Time.time > m_ReloadEndTime)
				{
					AmmoInMagazine += m_AmmoToLoad;

					IsReloading = false;
				}
			}
		}
    }
}