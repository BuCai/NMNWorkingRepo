using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace SurvivalTemplatePro.WieldableSystem
{
    /// <summary>
    /// Controller responsible for equipping and holstering wieldables.
    /// </summary>
    [RequireComponent(typeof(IRayGenerator))]
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/wieldable#wieldables-controller-module")]
    public class WieldablesController : CharacterBehaviour, IWieldablesController
    {
        public IWieldable ActiveWieldable => m_ActiveWieldable;
        public bool IsEquipping => m_IsEquipping;

        public event WieldableEquipCallback onWieldableEquipped;
        public event WieldableEquipCallback onWieldableHolsterStart;

        [SerializeField]
        [Tooltip("The audio player that every wieldable will use.")]
        private AudioPlayer m_AudioPlayer;

        [Space]

        [SerializeField, InfoBox("The wieldable that will be equipped when equipping a NULL wieldable, can be left empty. (Tip: you can set it to an arms/unarmed wieldable).")]
        private Wieldable m_DefaultWieldable;

        private List<IWieldable> m_Wieldables = new List<IWieldable>();
        private IWieldable m_ActiveWieldable;

        private bool m_IsEquipping;


        public override void OnInitialized()
        {
            if (m_DefaultWieldable != null)
            {
                m_DefaultWieldable = SpawnWieldable(m_DefaultWieldable) as Wieldable;
                TryEquipWieldable(m_DefaultWieldable);
            }
        }

        public bool GetWieldableOfType<T>(out T wieldable) where T : IWieldable
        {
            if (m_Wieldables != null)
            {
                for (int i = 0; i < m_Wieldables.Count; i++)
                {
                    if (m_Wieldables[i].GetType() == typeof(T))
                    {
                        wieldable = (T)m_Wieldables[i];
                        return true;
                    }
                }
            }

            wieldable = default;

            return false;
        }

        public IWieldable SpawnWieldable(IWieldable wieldable)
        {
            IWieldable spawnedWieldable = Instantiate(wieldable.gameObject, transform.position, transform.rotation, transform).GetComponent<IWieldable>();
            spawnedWieldable.AudioPlayer = m_AudioPlayer;
            spawnedWieldable.RayGenerator = GetComponent<IRayGenerator>();

            m_Wieldables.Add(spawnedWieldable);
            spawnedWieldable.SetVisibility(false);
            spawnedWieldable.SetWielder(Character);

            return spawnedWieldable;
        }

        public bool DestroyWieldable(IWieldable wieldable)
        {
            if (HasWieldable(wieldable))
            {
                if (m_ActiveWieldable == wieldable)
                {
                    m_ActiveWieldable.OnHolster(10f);
                    m_ActiveWieldable.SetVisibility(false);
                }

                Destroy(wieldable.gameObject, 1f);

                return true;
            }

            return false;
        }

        public bool HasWieldable(IWieldable wieldable) => m_Wieldables.Contains(wieldable);

        public bool TryEquipWieldable(IWieldable wieldable, float holsterPreviousSpeedMod = 1f)
        {
            bool canEquip = !m_IsEquipping && (HasWieldable(wieldable) || wieldable == null);

            if (canEquip)
                StartCoroutine(C_EquipWieldable(wieldable, holsterPreviousSpeedMod));

            return canEquip;
        }

        // Holsters & Hides the active wieldable then enables and equips the given one.
        private IEnumerator C_EquipWieldable(IWieldable wieldableToEquip, float holsterPrevSpeedMod = 1f)
        {
            m_IsEquipping = true;

            onWieldableHolsterStart?.Invoke(m_ActiveWieldable);

            // Holster and disable previous wieldable variables.
            float disablePrevTime = 0f;

            if (m_ActiveWieldable != null)
            {
                holsterPrevSpeedMod = Mathf.Clamp(holsterPrevSpeedMod, 0.1f, 10f);
                disablePrevTime = m_ActiveWieldable.HolsterDuration / holsterPrevSpeedMod;
            }

            WaitForSeconds disablePrevSeconds = new WaitForSeconds(disablePrevTime);

            // Start holstering the previous wieldable.
            var wieldableToDisable = m_ActiveWieldable;

            if (wieldableToDisable != null)
                wieldableToDisable.OnHolster(holsterPrevSpeedMod);

            yield return disablePrevSeconds;

            // Hides the previous wieldable.
            if (wieldableToDisable != null)
                wieldableToDisable.SetVisibility(false);

            // Enables and equips the new wieldable.
            if (wieldableToEquip == null)
                wieldableToEquip = m_DefaultWieldable;

            if (wieldableToEquip != null)
            {
                wieldableToEquip.SetVisibility(true);
                wieldableToEquip.OnEquip();
            }

            m_ActiveWieldable = wieldableToEquip;
            onWieldableEquipped?.Invoke(m_ActiveWieldable);

            m_IsEquipping = false;
        }
    }
}