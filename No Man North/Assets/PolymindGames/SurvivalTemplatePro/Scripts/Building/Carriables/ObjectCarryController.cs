using UnityEngine;
using UnityEngine.Events;

namespace SurvivalTemplatePro.BuildingSystem
{
    /// <summary>
    /// Handles everything regarding object carrying except the visuals.
    /// </summary>
    [HelpURL("https://polymindgames.gitbook.io/welcome-to-gitbook/qgUktTCVlUDA7CAODZfe/player/modules-and-behaviours/object-carry#object-carry-controller-module")]
    public class ObjectCarryController : ObjectDropHandler, IObjectCarryController, ISaveableComponent
    {
        public int CarriedObjectsCount
        {
            get => m_CarriedObjectsCount;
            set
            {
                int clampedValue = Mathf.Clamp(value, 0, 24);

                if (value != m_CarriedObjectsCount && clampedValue != m_CarriedObjectsCount)
                {
                    m_CarriedObjectsCount = clampedValue;
                    onCarriedCountChanged?.Invoke(m_CarriedObjectsCount);
                }
            }
        }

        public CarriableDefinition CarriedObject => m_CarriedObject;

        public event UnityAction onObjectCarryStart;
        public event UnityAction onObjectCarryEnd;
        public event UnityAction<int> onCarriedCountChanged;

        [Space, SerializeField]
        private UnityEvent m_OnCarryStart;

        [SerializeField]
        private UnityEvent m_OnCarryEnd;

        private int m_CarriedObjectsCount = 0;
        private CarriableDefinition m_CarriedObject;

        private IStructureDetector m_StructureDetector;
        private IMotionController m_MotionController;


        public override void OnInitialized()
        {
            GetModule(out m_StructureDetector);
            GetModule(out m_MotionController);
        }

        public bool TryCarryObject(CarriableDefinition definition)
        {
            bool canCarry = false;

            if (definition != null)
            {
                if (m_CarriedObjectsCount == 0)
                {
                    m_CarriedObject = definition;

                    onObjectCarryStart?.Invoke();
                    m_OnCarryStart?.Invoke();

                    CarriedObjectsCount = 1;

                    canCarry = true;
                }
                else if (m_CarriedObject == definition && m_CarriedObjectsCount < definition.MaxCarryCount)
                {
                    CarriedObjectsCount++;
                    canCarry = true;
                }

                if (canCarry)
                    definition.CarrySound.Play2D();
            }

            return canCarry;
        }

        public void UseCarriedObject()
        {
            if (m_CarriedObjectsCount <= 0)
                return;

            var structureInView = m_StructureDetector.StructureInView;
            var buildingMaterial = GetBuildingMaterialInfo(m_CarriedObject);

            if (structureInView != null && structureInView.TryAddBuildingMaterial(buildingMaterial))
                RemoveCarriable(1);

            TryEndObjectCarrying();
        }

        public void DropCarriedObjects(int amount)
        {
            if (m_CarriedObjectsCount <= 0 || m_CarriedObject == null)
                return;

            float dropHeightMod = m_MotionController.ActiveStateType == MotionStateType.Crouch ? 0.5f : 1f;

            for (int i = 0; i < amount; i++)
                DropObject(m_CarriedObject.DropSettings, m_CarriedObject.TargetCarriable, dropHeightMod);

            RemoveCarriable(amount);
        }

        private void RemoveCarriable(int amount) 
        {
            if (m_CarriedObjectsCount <= 0)
                return;

            CarriedObjectsCount -= amount;
            TryEndObjectCarrying();
        }

        private void TryEndObjectCarrying()
        {
            if (m_CarriedObjectsCount == 0)
            {
                onObjectCarryEnd?.Invoke();
                m_OnCarryEnd?.Invoke();
            }
        }

        private BuildingMaterialInfo GetBuildingMaterialInfo(CarriableDefinition definition)
        {
            return BuildMaterialsDatabase.GetBuildingMaterialById(definition.BuildMaterial);
        }

        #region Save & Load
        public void LoadMembers(object[] members)
        {
            m_CarriedObject = CarriableDefinition.GetCarriableWithId((int)members[0]);
            int carriedCount = (int)members[1];

            if (m_CarriedObject != null)
            {
                for (int i = 0; i < carriedCount; i++)
                    TryCarryObject(m_CarriedObject);
            }
        }

        public object[] SaveMembers()
        {
            int carriableId = m_CarriedObject != null ? m_CarriedObject.CarriableId : -1;

            var members = new object[]
            {
                carriableId,
                m_CarriedObjectsCount
            };

            return members;
        }
        #endregion
    }
}