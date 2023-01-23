using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class SelectableGroupUI : MonoBehaviour
	{
        public SelectableUI[] Selectables => m_Selectables;
        public SelectableUI ActiveSelectable => m_ActiveSelectable;

        public event UnityAction<SelectableUI> onSelected;

        [SerializeField]
		private bool m_FindChildrenAtStart = true;

        [SerializeField]
        private bool m_SelectFirstChildAtStart = true;

        [Space]

        [SerializeField]
        private RectTransform m_SelectionFrame;

        [SerializeField]
        private bool m_SetFrameColorToSelected;

        [Space]

        [SerializeField]
        private SoundPlayer m_SelectAudio;

		private SelectableUI[] m_Selectables;
		private SelectableUI m_ActiveSelectable;

        private Graphic m_SelectionFrameGraphic;

        private float m_NextTimeCanPlayAudio;


        public void SetSelectables(SelectableUI[] selectables)
		{
			if (m_Selectables != null)
			{
                for (int i = 0;i < m_Selectables.Length;i++)
                {
                    m_Selectables[i].onPointerDown -= SelectSelectable;
                    m_Selectables[i].onPointerUp -= SelectSelectable;
                }

				if (m_ActiveSelectable != null)
				{
					m_ActiveSelectable.Deselect();
					m_ActiveSelectable = null;
				}
			}

			if (selectables != null && selectables.Length > 0)
			{
				m_Selectables = selectables;

                for (int i = 0; i < m_Selectables.Length; i++)
                {
                    m_Selectables[i].onPointerDown += SelectSelectable;
                    m_Selectables[i].onPointerUp += SelectSelectable;

                    m_Selectables[i].Deselect();
                }
			}
		}

        public void SelectNextSelectable()
        {
            int indexToSelect = (int)Mathf.Repeat(GetIndexOfSelectable(m_ActiveSelectable) + 1, m_Selectables.Length - 1);

            if (indexToSelect < 0)
                return;

            SelectSelectable(m_Selectables[indexToSelect]);
        }

        public void SelectPreviousSelectable() 
        {
            int indexToSelect = (int)Mathf.Repeat(GetIndexOfSelectable(m_ActiveSelectable) - 1, m_Selectables.Length - 1);

            if (indexToSelect < 0)
                return;

            SelectSelectable(m_Selectables[indexToSelect]);
        }

		public void SelectSelectable(SelectableUI selectable)
		{
            if (m_ActiveSelectable == selectable)
                return;

			if (m_ActiveSelectable != null)
				m_ActiveSelectable.Deselect();

            m_ActiveSelectable = selectable;
            m_ActiveSelectable.Select();

            if (m_SelectionFrame != null)
            {
                if (!m_SelectionFrame.gameObject.activeSelf)
                    m_SelectionFrame.gameObject.SetActive(true);

                m_SelectionFrame.SetParent(selectable.transform);
                m_SelectionFrame.anchoredPosition = Vector2.zero;

                if (m_SetFrameColorToSelected)
                    m_SelectionFrameGraphic.color = m_ActiveSelectable.GetComponent<Graphic>().color;
            }

            // Play selection audio
            if (m_NextTimeCanPlayAudio < Time.time)
            {
                m_SelectAudio.Play2D();
                m_NextTimeCanPlayAudio = Time.time + 0.4f;
            }

            onSelected?.Invoke(m_ActiveSelectable);
        }

        public int GetIndexOfSelectable(SelectableUI selectable)
        {
            for (int i = 0; i < m_Selectables.Length; i++)
            {
                if (m_Selectables[i] == selectable)
                    return i;
            }

            return -1;
        }

        private void Awake()
        {
            if (m_SelectionFrame != null)
                m_SelectionFrameGraphic = m_SelectionFrame.GetComponentInChildren<Graphic>();

            if (m_FindChildrenAtStart)
            {
                SetSelectables(GetComponentsInChildren<SelectableUI>());

                if (m_SelectFirstChildAtStart && m_Selectables != null && m_Selectables.Length != 0)
                    SelectSelectable(m_Selectables[0]);
            }
        }
    }
}