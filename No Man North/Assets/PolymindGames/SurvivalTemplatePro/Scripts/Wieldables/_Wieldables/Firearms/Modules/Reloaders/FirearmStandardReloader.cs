using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Firearms/Reloaders/Standard Reloader")]
    public class FirearmStandardReloader : FirearmBasicReloader
    {
        [Space]

        [SerializeField, Range(0.01f, 15f)]
        private float m_EmptyReloadDuration = 3f;

        [SerializeField]
        private DelayedSoundRandom[] m_EmptyReloadSounds;

        [SerializeField]
        private WieldableObjectSpawnEffect m_EmptyReloadEffect;

        [SerializeField, HideInInspector]
        private STPEventReference m_EmptyReloadEvent = new STPEventReference("On Empty Reload");


        public override bool TryStartReload(IFirearmAmmo ammoModule)
        {
            if (!IsMagazineEmpty)
            {
                base.TryStartReload(ammoModule);
                return false;
            }

            if (IsReloading || IsMagazineFull)
                return false;

            m_AmmoToLoad = ammoModule.RemoveAmmo(MagazineSize - AmmoInMagazine);

            // Empty Reload
            m_ReloadEndTime = Time.time + m_EmptyReloadDuration;

            // Play Empty reload audio
            Firearm.AudioPlayer.PlaySounds(m_EmptyReloadSounds);

            // Do Reload Effect
            if (m_EmptyReloadEffect != null)
                m_EmptyReloadEffect.DoEffect(Firearm.Character);

            // Events
            Firearm.EventHandler.TriggerAction(m_EmptyReloadEvent, 1f);

            IsReloading = true;

            return true;
        }
    }
}