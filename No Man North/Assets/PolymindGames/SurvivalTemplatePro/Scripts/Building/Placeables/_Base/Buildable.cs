using UnityEngine;

namespace SurvivalTemplatePro.BuildingSystem
{
    /// <summary>
    /// TODO: Rework
    /// </summary>
    public class Buildable : Placeable, ISaveableComponent
    {
		public StructureManager ParentStructure { get; set; }
		public BuildableActivationState ActivationState => m_ActivationState;

		public BuildableType BuildableType => m_BuildableType;
		public BuildRequirementInfo[] BuildRequirements => m_BuildRequirements;

		public SocketType NeededSpace => m_NeededSpace;
		public SocketType SpacesToOccupy => m_SpacesToOccupy;

		public bool RequiresSockets => m_RequiresSockets;
		public Socket[] Sockets => m_Sockets;
		public Vector3 OccupiedSocketPosition { get => m_OccupiedSocketPosition; set => m_OccupiedSocketPosition = value; }

		public MaterialChanger MaterialChanger => m_MaterialChanger;
		
		[Header("General (Buildable)")]

		[SerializeField]
		private BuildRequirementInfo[] m_BuildRequirements;

		[Space]

		[SerializeField]
		private BuildableType m_BuildableType;

		[SerializeField, EnableIf("m_BuildableType", (int)BuildableType.SocketBased)]
		private bool m_RequiresSockets;

		[SerializeField, EnableIf("m_BuildableType", (int)BuildableType.SocketBased)]
		private SocketType m_NeededSpace;

		[SerializeField, EnableIf("m_BuildableType", (int)BuildableType.SocketBased)]
		private SocketType m_SpacesToOccupy;

		[Space]

		[SerializeField]
		private MaterialChanger m_MaterialChanger;

		[Header("Effects (Buildable)")]

		[SerializeField]
		protected SoundPlayer m_BuildAudio;

		[SerializeField]
		protected GameObject m_BuildFX;

		private Vector3 m_OccupiedSocketPosition;
		private Socket[] m_Sockets = new Socket[0];
		private BuildableActivationState m_ActivationState = BuildableActivationState.Preview;

		private bool m_Initialized;


		public void SetActivationState(BuildableActivationState state, bool playEffects = true)
		{
			if (!m_Initialized)
				Awake();

			m_ActivationState = state;

			if (state == BuildableActivationState.Placed)
			{
				if (playEffects)
				{
					m_BuildAudio.Play2D();

					if (m_BuildFX != null)
						Instantiate(m_BuildFX, transform.position, Quaternion.identity, null);
				}

				gameObject.SetLayerRecursively(PlaceableDatabase.GetBuildableMask());
			}
			else
				gameObject.SetLayerRecursively(PlaceableDatabase.GetBuildablePreviewMask());

			bool enableSocketsAndColliders = state != BuildableActivationState.Disabled;

			foreach (var col in m_Colliders)
				col.enabled = enableSocketsAndColliders;

			foreach (var socket in m_Sockets)
				socket.gameObject.SetActive(enableSocketsAndColliders);

			if (m_MaterialChanger != null)
			{
				if (state == BuildableActivationState.Placed)
					m_MaterialChanger.SetDefaultMaterial();
				else
					m_MaterialChanger.SetOverrideMaterial(PlaceableDatabase.GetPlaceAllowedMaterial());
			}

			if (state == BuildableActivationState.Preview)
				Place();
		}

		protected override void Awake()
		{
			base.Awake();

			m_Sockets = GetComponentsInChildren<Socket>();
			m_Initialized = true;
		}

#if UNITY_EDITOR
		protected override void OnValidate()
		{
			if (m_MaterialChanger == null)
				m_MaterialChanger = GetComponentInChildren<MaterialChanger>();
		}
#endif

		#region Save & Load
		public void LoadMembers(object[] members)
		{
			m_OccupiedSocketPosition = (Vector3)members[0];
		}

		public object[] SaveMembers()
		{
			return new object[] { m_OccupiedSocketPosition };
		}
		#endregion
	}
}