using SurvivalTemplatePro.WieldableSystem;
using System;
using System.Reflection;
using UnityEngine;

namespace SurvivalTemplatePro.BuildingSystem
{
    [CreateAssetMenu(menuName = "Survival Template Pro/Building/Carriable Definition")]
    public class CarriableDefinition : ScriptableObject
    {
        public int CarriableId => m_Id;
        public int BuildMaterial => m_BuildMaterial;
        public int MaxCarryCount => m_MaxCarryCount;
        public IWieldable TargetWieldable => m_Wieldable;
        public GameObject TargetCarriable => m_Carriable;
        public ObjectDropSettings DropSettings => m_DropSettings;
        public SoundPlayer CarrySound => m_CarrySound;

        private static CarriableDefinition[] Definitions
        {
            get
            {
                if (s_Definitions == null)
                    s_Definitions = Resources.LoadAll<CarriableDefinition>("");

                return s_Definitions;
            }
        }

        [SerializeField, ReadOnly]
        private int m_Id;

        [Space]

        [SerializeField]
        private BuildMaterialReference m_BuildMaterial;

        [SerializeField]
        private int m_MaxCarryCount;

        [Space]

        [SerializeField]
        [InfoBox("Corresponding Wieldable")]
        private Wieldable m_Wieldable;

        [SerializeField]
        [InfoBox("Corresponding Carriable")]
        private GameObject m_Carriable;

        [Space]

        [SerializeField]
        private ObjectDropSettings m_DropSettings;

        [SerializeField]
        private SoundPlayer m_CarrySound;

        private static CarriableDefinition[] s_Definitions;


        public static CarriableDefinition GetCarriableWithId(int id) 
        {
            for (int i = 0; i < Definitions.Length; i++)
            {
                if (Definitions[i].CarriableId == id)
                    return Definitions[i];
            }

            return null;
        }

#if UNITY_EDITOR
        private void OnValidate()
        {
			RefreshCarriableIDs();
		}

		private void RefreshCarriableIDs()
		{
			foreach (var carriable in Definitions)
			{
                if (carriable.CarriableId == 0)
                {
                    int assignedId = IdGenerator.GenerateIntegerId();
                    AssignIdToCarriable(carriable, assignedId);
                }
			}
		}

		private void AssignIdToCarriable(CarriableDefinition carriable, int id)
		{
			Type itemInfoType = typeof(CarriableDefinition);
			FieldInfo idField = itemInfoType.GetField("m_Id", BindingFlags.NonPublic | BindingFlags.Instance);

			idField.SetValue(carriable, id);
		}
#endif
	}
}