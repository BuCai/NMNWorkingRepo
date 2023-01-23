namespace SurvivalTemplatePro.WieldableSystem
{
    public interface IFirearmRecoil : IFirearmAttachment
    {
        float RecoilForce { get; }
    }
}