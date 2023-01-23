namespace SurvivalTemplatePro
{
    public class PlayerCompanionHandler : CharacterBehaviour, IPlayerCompanionHandler, ISaveableComponent
    {
        public DogCompanion DogCompanion => _dogCompanion;
        public HitchhikerCompanion HitchhikerCompanion => _hitchhikerCompanion;

        private DogCompanion _dogCompanion;
        private HitchhikerCompanion _hitchhikerCompanion;

        public bool AddCompanion(ICompanion companion)
        {
            switch (companion)
            {
                case DogCompanion dogCompanion when _dogCompanion == null:
                    _dogCompanion = dogCompanion;
                    return true;
                case HitchhikerCompanion hitchhikerCompanion when _hitchhikerCompanion == null:
                    _hitchhikerCompanion = hitchhikerCompanion;
                    return true;
                default:
                    return false;
            }
        }

        public bool RemoveCompanion(ICompanion companion)
        {
            switch (companion)
            {
                case DogCompanion dogCompanion when _dogCompanion == dogCompanion:
                    _dogCompanion = null;
                    return true;
                case HitchhikerCompanion hitchhikerCompanion when _hitchhikerCompanion == hitchhikerCompanion:
                    _hitchhikerCompanion = null;
                    return true;
                default:
                    return false;
            }
        }


        #region Save & Load

        public void LoadMembers(object[] members)
        {
        }

        public object[] SaveMembers()
        {
            return new object[]
            {
            };
        }

        #endregion
    }
}