using System;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class SelectableUI : MonoBehaviour, IPointerEnterHandler, IPointerDownHandler, IPointerUpHandler, IPointerExitHandler
	{
		#region Internal
		public enum State
		{
			Normal,
			Highlighted,
			Pressed,
		}

		[Serializable]
		public class Transition
		{
			public Color NormalColor = Color.grey;
			public Color HighlightedColor = Color.grey;
			public Color PressedColor = Color.grey;

			[Range(0.01f, 1f)]
			public float FadeDuration = 0.1f;
		}
		#endregion

		public event UnityAction<SelectableUI> onPointerDown;
		public event UnityAction<SelectableUI> onPointerUp;

		[SerializeField]
		protected Graphic _Graphic;

		[SerializeField]
		protected Transition m_Transition;

		protected State m_State = State.Normal;

		protected bool m_Pressed;
		protected bool m_Selected;
		protected bool m_PointerHovering;
		protected CanvasRenderer m_Renderer;


		public virtual void Select()
		{
			m_Selected = true;
			RefreshState(m_State);
		}

		public virtual void Deselect()
		{
			m_Selected = false;
			RefreshState(m_PointerHovering ? State.Highlighted : State.Normal);
		}

		public virtual void OnPointerEnter(PointerEventData data)
		{
			m_PointerHovering = true;

			if (!m_Pressed)
				RefreshState(State.Highlighted);
		}

		public virtual void OnPointerDown(PointerEventData data)
		{
			if (data.button == PointerEventData.InputButton.Left)
			{
				m_Pressed = true;
				RefreshState(State.Pressed);
			}

			onPointerDown?.Invoke(this);
		}

		public virtual void OnPointerUp(PointerEventData data)
		{
			m_Pressed = false;
			RefreshState(State.Normal);

			onPointerUp?.Invoke(this);
		}

		public virtual void OnPointerExit(PointerEventData data)
		{
			m_PointerHovering = false;

			if (!m_Pressed)
				RefreshState(State.Normal);
			else
				RefreshState(State.Pressed);
		}

		protected virtual void Awake()
		{
			if (!Application.isPlaying)
				return;

			m_Renderer = GetComponent<CanvasRenderer>();
		}

		protected virtual void OnEnable()
		{
			if (_Graphic == null)
				_Graphic = GetComponent<Graphic>();

			if (m_Transition == null)
				m_Transition = new Transition();

			OnValidate();
		}

		protected virtual void OnDisable()
		{
			if (m_Renderer == null)
				m_Renderer = GetComponent<CanvasRenderer>();

			if (m_Renderer != null)
				m_Renderer.SetColor(Color.white);
		}

		protected virtual void OnDestroy()
		{
			if (m_Renderer == null)
				m_Renderer = GetComponent<CanvasRenderer>();

			if (m_Renderer != null)
				m_Renderer.SetColor(Color.white);
		}

		protected virtual void OnValidate()
		{
			if (m_Renderer == null)
				m_Renderer = GetComponent<CanvasRenderer>();

			if (m_Renderer != null)
				m_Renderer.SetColor(m_Transition.NormalColor);
		}

		private void RefreshState(State state)
		{
			Color color = m_Transition.NormalColor;

			if (state == State.Highlighted)
				color = m_Transition.HighlightedColor;
			else if (state == State.Pressed)
				color = m_Transition.PressedColor;

			if (m_Selected)
				color = m_Transition.HighlightedColor;

			_Graphic.CrossFadeColor(color, m_Transition.FadeDuration, true, true);
		}
	}
}