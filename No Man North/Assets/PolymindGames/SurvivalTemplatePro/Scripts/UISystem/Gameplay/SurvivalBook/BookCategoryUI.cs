using UnityEngine;
using UnityEngine.UI;

namespace SurvivalTemplatePro.UISystem
{
    public class BookCategoryUI : SelectableUI, IBookCategoryUI
    {
        protected ICharacter Player { get; private set; }

        [Space]

        [SerializeField]
        private Text m_CategoryNameText;

        [SerializeField]
        private RectTransform m_CorrepondingContent;

        [SerializeField, Range(0, 100)]
        private int m_SelectedFontSize = 15;

        [SerializeField]
        private Color m_SelectedTextColor = Color.white;

        private int m_OriginalFontSize;
        private Color m_OriginalTextColor;
        private FontStyle m_OriginalFontStyle;
        private bool m_IsNameTextInitialized;


        public virtual void AttachToPlayer(ICharacter player) => Player = player;

        public override void Select()
        {
            base.Select();

            m_CategoryNameText.fontStyle = FontStyle.Bold;
            m_CategoryNameText.fontSize = m_SelectedFontSize;
            m_CategoryNameText.color = m_SelectedTextColor;

            m_CorrepondingContent.gameObject.SetActive(true);
        }

        public override void Deselect()
        {
            base.Deselect();

            if (!m_IsNameTextInitialized)
                InitializeNameText();

            m_CategoryNameText.fontStyle = m_OriginalFontStyle;
            m_CategoryNameText.fontSize = m_OriginalFontSize;
            m_CategoryNameText.color = m_OriginalTextColor;

            m_CorrepondingContent.gameObject.SetActive(false);
        }

        protected override void Awake()
        {
            base.Awake();

            if (!m_IsNameTextInitialized)
                InitializeNameText();
        }

        private void InitializeNameText() 
        {
            m_OriginalFontSize = m_CategoryNameText.fontSize;
            m_OriginalTextColor = m_CategoryNameText.color;
            m_OriginalFontStyle = m_CategoryNameText.fontStyle;

            m_IsNameTextInitialized = true;
        }
    }
}
