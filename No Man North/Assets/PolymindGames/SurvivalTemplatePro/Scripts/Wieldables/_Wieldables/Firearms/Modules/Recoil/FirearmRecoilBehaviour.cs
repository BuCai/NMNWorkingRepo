namespace SurvivalTemplatePro.WieldableSystem
{
    public abstract class FirearmRecoilBehaviour : FirearmAttachmentBehaviour, IFirearmRecoil
    {
        public abstract float RecoilForce { get; }


        protected virtual void OnEnable() => Firearm.SetRecoil(this);
        protected virtual void OnDisable() { }
    }
}