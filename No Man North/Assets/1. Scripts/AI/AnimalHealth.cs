public class AnimalHealth : HealthController
{
    private bool isHit { get; set; }

    public bool GETIsHit()
    {
        return isHit;
    }

    public override void DealDamage(float damage)
    {
        if (animator)
        {
            animator.SetTrigger(Hit);
        }

        if (damage < health)
        {
            health -= damage;
            Alive = true;
            isHit = true;
            Invoke(nameof(ForgetAboutDamage), damageForgetTime);
            return;
        }

        health = 0;
        Die();
    }

    private void ForgetAboutDamage()
    {
        isHit = false;
    }
}