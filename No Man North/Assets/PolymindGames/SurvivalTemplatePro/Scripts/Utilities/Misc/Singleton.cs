using UnityEngine;

namespace SurvivalTemplatePro
{
    /// <summary>
    /// Basic Singleton
    /// </summary>
    public abstract class Singleton<T> : MonoBehaviour where T : MonoBehaviour 
	{
		public static T Instance 
		{ 
			get
			{
				if (m_Instance == null)
					m_Instance = FindObjectOfType<T>();

				return m_Instance;
			}
		}

		private static T m_Instance;


		private void Awake()
		{
			if (Instance != null && Instance != this)
			{
				Destroy(gameObject);
				return;
			}

			OnAwake();
		}

		protected virtual void OnAwake() { }
	}
}
