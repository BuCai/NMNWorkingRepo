using UnityEngine;

[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(AnimalInteractable))]
public class HealthController : MonoBehaviour
{
    [SerializeField] protected float health = 100;
    [SerializeField] protected Animator animator;
    [SerializeField] protected float damageForgetTime = 60.0f;
    [SerializeField] protected float despawnEntityAfterTime;
    protected static readonly int Dead = Animator.StringToHash("dead");
    protected static readonly int Hit = Animator.StringToHash("hit");
    protected AnimalInteractable Interactable;

    protected bool Alive = true;

    public bool IsAlive() => Alive;

    public virtual void DealDamage(float damage)
    {
        if (animator)
        {
            animator.SetTrigger(Hit);
        }

        if (damage < health)
        {
            health -= damage;
            Alive = true;
            return;
        }

        health = 0;
        Die();
    }

    protected virtual void Die()
    {
        Alive = false;
        Interactable.InteractionEnabled = true;
        if (animator)
        {
            animator.SetBool(Dead, true);
        }
        Invoke(nameof(DestroyAfterDeath), despawnEntityAfterTime);
    }

    protected virtual void DestroyAfterDeath()
    {
        Destroy(gameObject);
    }

    // Start is called before the first frame update
    void Start()
    {
        Interactable = gameObject.GetComponent<AnimalInteractable>();
    }

    // Update is called once per frame
    void Update()
    {
    }
}