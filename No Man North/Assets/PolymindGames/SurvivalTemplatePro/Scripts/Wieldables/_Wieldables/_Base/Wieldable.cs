using SurvivalTemplatePro.InventorySystem;
using System;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.WieldableSystem
{
    [AddComponentMenu("Wieldables/Wieldable")]
    public class Wieldable : MonoBehaviour, ISTPEventReferenceHandler, IWieldable, ICrosshairHandler, IWeightHandler
    {
        #region Internal
        [Serializable]
        private class VisibilityChangeSettings
        {
            [Range(0f, 5f)]
            public float Duration = 0.5f;

            [SpaceArea]

            [ReorderableList(elementLabel: "Sound")]
            public DelayedSound[] Sounds;

            public UnityEvent Event;
        }
        #endregion

        public IAudioPlayer AudioPlayer { get; set; }
        public IRayGenerator RayGenerator { get; set; }
        public ICharacter Character => m_Character ?? GetComponentInParent<ICharacter>();
        public ISTPEventHandler EventHandler => m_EventHandler ?? GetComponent<ISTPEventHandler>();

        public bool IsVisible { get; private set; }

        public IItem AttachedItem { get; private set; }
        public IItemProperty ItemDurability { get; private set; }

        public float EquipDuration => m_Equipping.Duration;
        public float HolsterDuration => m_Holstering.Duration;
        protected float LastEquipOrHolsterTime { get; set; }

        public event UnityAction onEquippingStarted;
        public event UnityAction<float> onHolsteringStarted;

        [Title("General Settings")]

        [SerializeField, Suffix(" KG")]
        private float m_BaseWeight;

        [SerializeField, Suffix("-1 to 100")]
        [Tooltip("Crosshair index for this wieldable, -1 or lower will result in no crosshair")]
        private int m_BaseCrosshair;

        [Title("Equip & Holster")]

        [SerializeField]
        private VisibilityChangeSettings m_Equipping;

        [SerializeField]
        private VisibilityChangeSettings m_Holstering;

        [SerializeField, HideInInspector]
        private STPEventReference m_EquipEvent = new STPEventReference("On Equip", true);

        [SerializeField, HideInInspector]
        private STPEventReference m_HolsterEvent = new STPEventReference("On Holster", true);

        private ICharacter m_Character;
        private ISTPEventHandler m_EventHandler;


        public virtual void SetVisibility(bool visible)
        {
            IsVisible = visible;
            gameObject.SetActive(visible);
        }

        public virtual void SetWielder(ICharacter wielder)
        {
            if (wielder != m_Character)
                m_Character = wielder;
        }

        public virtual void AttachItem(IItem itemToAttach)
        {
            AttachedItem = itemToAttach;

            if (itemToAttach != null)
                ItemDurability = itemToAttach.GetProperty("Durability");
        }

        protected virtual void DetachItem() => AttachedItem = null;

        public virtual void OnEquip()
        {
            AudioPlayer.PlaySounds(m_Equipping.Sounds);

            onEquippingStarted?.Invoke();
            m_Equipping.Event?.Invoke();

            if (m_EventHandler != null)
                EventHandler.TriggerAction(m_EquipEvent);

            LastEquipOrHolsterTime = Time.time;
        }

        public virtual void OnHolster(float holsterSpeed)
        {
            DetachItem();

            AudioPlayer.ClearAllQueuedSounds();
            AudioPlayer.PlaySounds(m_Holstering.Sounds);

            onHolsteringStarted?.Invoke(holsterSpeed);
            m_Holstering.Event?.Invoke();

            if (m_EventHandler != null)
                EventHandler.TriggerAction(m_HolsterEvent);

            LastEquipOrHolsterTime = Time.time;
        }

        #region Initialization
        protected virtual void Awake() 
        {
            m_EventHandler = GetComponent<ISTPEventHandler>();

            m_CurrentCrosshairIndex = m_BaseCrosshair;
            m_CurrentWeight = m_BaseWeight;

        }
        #endregion

        #region Crosshair Handling
        public int CrosshairIndex
        {
            get => m_CurrentCrosshairIndex;
            set 
            {
                if (m_CurrentCrosshairIndex != value)
                {
                    m_CurrentCrosshairIndex = value;
                    onCrosshairIndexChanged?.Invoke(value);
                }
            }
        }

        public event UnityAction<int> onCrosshairIndexChanged;

        private int m_CurrentCrosshairIndex;


        public void ResetCrosshair() => CrosshairIndex = m_BaseCrosshair;
        public virtual float GetCrosshairAccuracy() => RayGenerator.GetRaySpread();
        #endregion

        #region Weight Handling
        public float TotalWeight
        {
            get => m_CurrentWeight;
            set
            {
                if (m_CurrentWeight != value)
                {
                    m_CurrentWeight = value;
                    onWeightChanged?.Invoke();
                }
            }
        }

        public event UnityAction onWeightChanged;

        private float m_CurrentWeight;


        public void AddWeight(float weight) => TotalWeight += weight;
        public void RemoveWeight(float weight) => TotalWeight -= weight;
        #endregion

        #region Editor Only
        public Component GetEventReferencesSource() => this;
        #endregion
    }
}
