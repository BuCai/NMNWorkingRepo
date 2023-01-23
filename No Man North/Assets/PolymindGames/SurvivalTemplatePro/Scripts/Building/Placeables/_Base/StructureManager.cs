using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.BuildingSystem
{
    public class StructureManager : MonoBehaviour, ISaveableComponent
    {
        #region Internal
        [Serializable]
        private struct BuildableData
        {
            public int Id;
            public Vector3 Position;
            public Quaternion Rotation;
            public SocketState[] Sockets;
            public BuildableActivationState State;
        }

        [Serializable]
        private struct SocketState
        {
            public SocketType OccupiedSpaces;

            public SocketState(SocketType occupiedSpaces)
            {
                OccupiedSpaces = occupiedSpaces;
            }
        }
        #endregion

        public List<Buildable> Buildables => m_Buildables;

        public event UnityAction<Buildable> onPartAdded;
        public event UnityAction<Buildable> onPartRemoved;

        [SerializeField]
        private SoundPlayer m_BuildAudio;

        [SerializeField]
        private LayerMask m_BuildableMask;

        private readonly List<Buildable> m_Buildables = new List<Buildable>();
        private BuildableActivationState m_ActivationState = BuildableActivationState.Preview;


		public bool HasCollider(Collider col)
		{
            for (int i = 0; i < m_Buildables.Count; i++)
            {
                if (m_Buildables[i].HasCollider(col))
                    return true;
            }

			return false;
		}

        public void PlayBuildEffects()
        {
            m_BuildAudio.Play2D();
        }

		public void AddPart(Buildable buildable, bool raiseAddEvent = true)
		{
			if (!m_Buildables.Contains(buildable))
			{
				m_Buildables.Add(buildable);
         
                buildable.SetActivationState(BuildableActivationState.Preview);

                if (raiseAddEvent)
                    onPartAdded?.Invoke(buildable);
            }
		}

        public void RemovePart(Buildable buildable, bool raiseRemoveEvent = true)
        {
            if (m_Buildables.Remove(buildable))
            {
                if (raiseRemoveEvent)
                    onPartRemoved?.Invoke(buildable);

                RemoveBuildableFromSocket(buildable);

                Destroy(buildable.gameObject);
            }
        }

        private void RemoveBuildableFromSocket(Buildable buildable)
        {
            if (buildable.OccupiedSocketPosition == Vector3.zero)
                return;

            Collider[] overlappingStuff = Physics.OverlapSphere(buildable.OccupiedSocketPosition, 0.2f, m_BuildableMask, QueryTriggerInteraction.Collide);

            foreach (var collider in overlappingStuff)
            {
                if (collider.TryGetComponent<Socket>(out var socket))
                {
                    // If removed then return.
                    if (socket.UnoccupySpaces(buildable))
                        return;
                }
            }
        }

        #region Save & Load
        public void LoadMembers(object[] members)
        {
            var buildableData = members[0] as BuildableData[];

            // Load buildables into structure.
            foreach (BuildableData data in buildableData)
            {
                Buildable buildablePrefab = PlaceableDatabase.GetPlaceableById(data.Id) as Buildable;
                Buildable buildable = null;

                if (buildablePrefab != null)
                {
                    buildable = Instantiate(buildablePrefab, data.Position, data.Rotation, transform);
                    buildable.ParentStructure = this;

                    for (int i = 0; i < buildable.Sockets.Length; i++)
                        buildable.Sockets[i].OccupiedSpaces = data.Sockets[i].OccupiedSpaces;

                    buildable.SetActivationState(data.State, false);
                }

                if (!m_Buildables.Contains(buildable))
                    m_Buildables.Add(buildable);
            }      

            // Activation state
            m_ActivationState = (BuildableActivationState)members[1];
        }

        public object[] SaveMembers()
        {
            BuildableData[] buildableStates = new BuildableData[m_Buildables.Count];

            // Save buildables data.
            for (int i = 0; i < m_Buildables.Count; i++)
            {
                var buildable = m_Buildables[i];
                var buildableSockets = m_Buildables[i].Sockets;

                BuildableData state = new BuildableData()
                {
                    Id = buildable.PlaceableID,
                    Position = buildable.transform.position,
                    Rotation = buildable.transform.rotation,
                    Sockets = new SocketState[buildableSockets.Length],
                    State = buildable.ActivationState,
                };

                for (int j = 0; j < buildableSockets.Length; j++)
                    state.Sockets[j] = new SocketState(buildableSockets[j].OccupiedSpaces);

                buildableStates[i] = state;
            }

            object[] members = new object[]
            {
                buildableStates,
                m_ActivationState
            };

            return members;
        }
        #endregion
    }
}
