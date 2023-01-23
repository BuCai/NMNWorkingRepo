using System;
using UnityEngine;

namespace SurvivalTemplatePro.BuildingSystem
{
    [Serializable]
    public class BuildRequirement
    {
        public int BuildingMaterialId => m_BuildMaterialId;

        public int RequiredAmount
        {
            get => m_RequiredAmount;
            set
            {
                if (value != m_RequiredAmount)
                {
                    m_RequiredAmount = Mathf.Clamp(value, 0, 1000);

                    if (m_CurrentAmount > m_RequiredAmount)
                        CurrentAmount = m_RequiredAmount;
                }
            }
        }

        public int CurrentAmount 
        {
            get => m_CurrentAmount;
            set
            {
                if (value != m_CurrentAmount)
                    m_CurrentAmount = Mathf.Clamp(value, 0, m_RequiredAmount);
            }
        }

        [SerializeField]
        private int m_BuildMaterialId;

        [SerializeField]
        private int m_CurrentAmount;

        [SerializeField]
        private int m_RequiredAmount;


        public BuildRequirement(int buildingMaterialId, int requiredAmount, int currentAmount)
        {
            this.m_BuildMaterialId = buildingMaterialId;
            this.m_RequiredAmount = requiredAmount;
            this.m_CurrentAmount = currentAmount;
        }

        public BuildRequirement(BuildRequirementInfo buildRequirementInfo)
        {
            this.m_BuildMaterialId = buildRequirementInfo.BuildingMaterialId;
            this.m_RequiredAmount = buildRequirementInfo.RequiredAmount;
            this.m_CurrentAmount = 0;
        }

        public bool IsCompleted() => RequiredAmount == CurrentAmount;
    }

    [Serializable]
    public class BuildRequirementInfo
    {
        public int BuildingMaterialId => m_BuildMaterial;
        public int RequiredAmount => m_RequiredAmount;

        [SerializeField]
        private BuildMaterialReference m_BuildMaterial;

        [SerializeField, Range(1, 100)]
        private int m_RequiredAmount = 1;
    }
}