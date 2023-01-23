using System;
using UnityEngine;

namespace SurvivalTemplatePro.SaveSystem
{
    [ExecuteInEditMode]
	public class SaveableObject : GuidComponent
	{
		#region Internal
		[Serializable]
		public struct Data
		{
			public string PrefabID;
			public byte[] SceneID;
			public string Name;

			public TransformData Transform;
			public ChildTransformData[] ChildTransforms;
			public ComponentData[] Components;
		}

		[Serializable]
		public struct TransformData
		{
			public Vector3 Position;
			public Quaternion Rotation;
			public Vector3 LocalScale;

			
			public TransformData(Transform transform)
            {
				Position = transform.localPosition;
				Rotation = transform.localRotation;
				LocalScale = transform.localScale;
			}
		}

		[Serializable]
		public struct ChildTransformData
		{
			public string GameObjectPath;
			public TransformData TransformData;


			public ChildTransformData(string gameObjectPath, TransformData transformData)
			{
				GameObjectPath = gameObjectPath;
				TransformData = transformData;
			}
		}

		[Serializable]
		public struct ComponentData
		{
			public string GameObjectPath;
			public Type ComponentType;
			public object[] Members;


			public ComponentData(string gameObjectPath, Type componentType, object[] members)
			{
				Members = members;

				GameObjectPath = gameObjectPath;
				ComponentType = componentType;
			}
		}
		#endregion

		public string PrefabID { get => m_PrefabID; set => m_PrefabID = value; }

		[SerializeField, HideInInspector]
		private string m_PrefabID;

		[SerializeField]
		private bool m_SavePosition = true;

		[SerializeField]
		private bool m_SaveRotation = true;

		[SerializeField]
		private bool m_SaveScale;

		[Space]

		[SerializeField]
		private bool m_SaveChildTransforms;

		[SpaceArea]

		[SerializeField, ShowIf("m_SaveChildTransforms", true), ReorderableList]
		private Transform[] m_ChildrenToSave;


		public virtual Data Save()
		{
			Data data = new Data();

			data.PrefabID = m_PrefabID;
            data.SceneID = GetGuid().ToByteArray();
    
			data.Name = name;
			data.Transform = new TransformData(transform);

			// Save components
			ISaveableComponent[] savComponents = GetComponentsInChildren<ISaveableComponent>();

			data.Components = new ComponentData[savComponents.Length];
			for(int i = 0;i < savComponents.Length;i++)
			{
				GameObject gameObj = (savComponents[i] as Component).gameObject;
				string gameObjPath = CalculateTransformPath(transform, gameObj.transform);
				data.Components[i] = new ComponentData(gameObjPath, savComponents[i].GetType(), savComponents[i].SaveMembers());
			}

			// Save child transforms
			data.ChildTransforms = new ChildTransformData[m_ChildrenToSave.Length];
            for (int i = 0; i < m_ChildrenToSave.Length; i++)
            {
				Transform child = m_ChildrenToSave[i];
				string gameObjPath = CalculateTransformPath(transform, child);
				data.ChildTransforms[i] = new ChildTransformData(gameObjPath, new TransformData(child));
			}

            return data;
		}

		public virtual void Load(Data data)
		{
			gameObject.name = data.Name;
            SetGuid(data.SceneID);

			LoadTransform(transform, data.Transform);

			// Load components
			if (data.Components != null)
			{
				foreach (ComponentData compData in data.Components)
				{
					Transform obj = (compData.GameObjectPath != gameObject.name) ? transform.Find(compData.GameObjectPath) : transform;

					if (obj == null)
						continue;

					Component component = obj.GetComponent(compData.ComponentType);

					if (component == null)
					{
						component = obj.gameObject.AddComponent(compData.ComponentType);
					}

					ISaveableComponent savComponent = component as ISaveableComponent;

                    //try
                    //{
                        savComponent.LoadMembers(compData.Members);
                    //}

                    //catch
                    //{
                    //    Debug.LogErrorFormat("An error ocurred while trying to set members for component {0} on game object {1}", component.GetType(), obj.gameObject);
                    //}
                }
			}

			// Load child transforms
			if (data.ChildTransforms != null)
			{
				foreach (ChildTransformData childData in data.ChildTransforms)
				{
					Transform obj = (childData.GameObjectPath != gameObject.name) ? transform.Find(childData.GameObjectPath) : transform;

					if (obj == null)
						continue;

					LoadTransform(obj, childData.TransformData);
				}
			}
		}

		private void LoadTransform(Transform transform, TransformData data)
		{
			if (m_SavePosition)
				transform.localPosition = data.Position;

			if (m_SaveRotation)
				transform.localRotation = data.Rotation;

			if (m_SaveScale)
				transform.localScale = data.LocalScale;
		}

		protected override void Awake()
		{
            base.Awake();

            if (Application.isPlaying)
                LevelManager.Instance.RegisterSaveable(this);
		}

        public override void OnDestroy()
		{
            base.OnDestroy();

			if (LevelManager.Instance != null)
				LevelManager.Instance.UnregisterSaveable(this);
		}

		private string CalculateTransformPath(Transform root, Transform target)
		{
			string path = string.Empty;

			if (target != root)
			{
				path = target.name;
				Transform parent = target.parent;

				while (parent != null && parent != root)
				{
					path = parent.name + (path != string.Empty ? "/" : "") + path;
					parent = parent.parent;
				}
			}

			return path;
		}
    }
}