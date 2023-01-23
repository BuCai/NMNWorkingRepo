namespace SurvivalTemplatePro
{
    public interface IProjectile
	{
		float DamageMod { get; set; }

		void Launch(ICharacter launcher);
	}
}