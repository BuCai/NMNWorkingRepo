using System;
using UnityEngine;

namespace SurvivalTemplatePro.CompanionSystem
{
    [Serializable]
	public class ActionSlot : IActionSlot
	{
		public bool HasAction => Action != null;
		
		public IAction Action => m_Action;

		[SerializeField]
		private Action m_Action;
		
		public event ActionSlotChangedCallback onChanged;


        public void SetAction(IAction action)
		{
			if (m_Action != action)
				m_Action = action as Action;
		}
	}
}
