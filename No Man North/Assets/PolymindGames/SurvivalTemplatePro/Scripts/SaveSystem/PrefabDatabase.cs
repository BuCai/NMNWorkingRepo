using System;
using UnityEngine;

namespace SurvivalTemplatePro.SaveSystem
{
	[CreateAssetMenu(menuName = "Survival Template Pro/Save System/Prefab Database")]
	public class PrefabDatabase : ScriptableObject
	{
		public static event Action Enabled;

		public static PrefabDatabase Default
		{
			get 
			{
				if (m_Default == null)
				{
					var allDatabases = Resources.LoadAll<PrefabDatabase>("");
				
					if (allDatabases != null && allDatabases.Length > 0)
						m_Default = allDatabases[0];
				}

				return m_Default;
			}
		}

		public SaveableObject[] Prefabs { get { return m_Prefabs; } set { m_Prefabs = value; } }

		private static PrefabDatabase m_Default;

		[SerializeField]
		private SaveableObject[] m_Prefabs;


		private void OnEnable() 
		{
			m_Default = this;
            Enabled?.Invoke();
		}
	}
}