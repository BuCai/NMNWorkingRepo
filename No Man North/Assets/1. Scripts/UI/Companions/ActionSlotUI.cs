using SurvivalTemplatePro.CompanionSystem;
using SurvivalTemplatePro.InventorySystem;
using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class ActionSlotUI : SlotUI
	{
		public IActionSlot ItemSlot
		{
			get
			{
				if (m_ActionSlot != null)
					return m_ActionSlot;

				Debug.LogError("No item slot is linked to this interface.");
				return null;
			}
		}

		public bool HasAction => m_ActionSlot is {HasAction: true};
		public IAction Action => m_ActionSlot?.Action;

		public Image BackgroundIcon { get => m_BackgroundIcon; set => m_BackgroundIcon = value; }

		public ItemContainerUI Parent { get; private set; }

		[Title("Icon")]

		[SerializeField]
		private Image m_Icon;

		[SerializeField]
		private Image m_BackgroundIcon;

		

		private IActionSlot m_ActionSlot;


		public void LinkToSlot(IActionSlot actionSlot)
		{
			if (m_ActionSlot != null)
				m_ActionSlot.onChanged -= OnSlotChanged;

			m_ActionSlot = actionSlot;
			m_ActionSlot.onChanged += OnSlotChanged;

			DoRefresh();
		}

		public void UnlinkFromSlot()
		{
			if (m_ActionSlot == null)
				return;

			m_ActionSlot.onChanged -= OnSlotChanged;
		}

		protected override void OnDestroy()
		{
			base.OnDestroy();

			if (m_ActionSlot != null)
				m_ActionSlot.onChanged -= OnSlotChanged;
		}

		public void DoRefresh()
		{
			bool hasItem = HasAction;

			m_Icon.enabled = hasItem;
			
			// FIXME: Add info properties to actions!
			// if (hasItem)
			// 	m_Icon.sprite = Action.Info.Icon;

			if (m_BackgroundIcon != null)
				m_BackgroundIcon.enabled = !hasItem;
			
		}
			
		/// <summary>
		/// Will return a clone of this slot, without the background.
		/// </summary>
		public RectTransform GetItemUI(IAction action, float alpha)
		{
			ActionSlotUI itemUI = Instantiate(this);

			// Disable the slot UI
			itemUI.enabled = false;
			itemUI._Graphic.enabled = false;

			// Set up the icon
			itemUI.m_Icon.enabled = true;
			// FIXME: Again, add action info properties!
			// itemUI.m_Icon.sprite = action.Info.Icon;

			// NOTE: Leaving this commented out, because we could use the durability bar for a cooldown bar.
			// Set up the durability bar
			// itemUI.m_DurabilityBar.SetActive(action.HasProperty(m_DurabilityProperty));


			// Add a CanvasGroup so we can set a global alpha value
			var group = itemUI.gameObject.AddComponent<CanvasGroup>();
			group.alpha = alpha;
			group.interactable = false;

			return itemUI.GetComponent<RectTransform>();
		}

		protected override void Awake()
		{
			Parent = GetComponentInParent<ItemContainerUI>();
		}

		private void OnSlotChanged(IActionSlot actionSlot) => DoRefresh();



#if UNITY_EDITOR
		protected override void OnValidate()
        {
            base.OnValidate();

			if (Application.isPlaying || m_Icon == null)
				return;

			m_Icon.enabled = m_Icon.sprite != null;

			if (m_BackgroundIcon != null)
				m_BackgroundIcon.enabled = m_BackgroundIcon.sprite != null;
		}
#endif
	}
}