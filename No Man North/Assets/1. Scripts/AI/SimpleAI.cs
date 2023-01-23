using MLC.NoManNorth.Eric;
using UnityEngine;
using UnityEngine.AI;
using Random = UnityEngine.Random;

public class SimpleAI : MonoBehaviour
{
    // Navigation and targeting
    public NavMeshAgent agent;
    public Transform target;
    public LayerMask ground, player;

    // Attacking
    public GameObject projectile;
    public float attackDelay = 1.0f;
    private bool _attack;

    
    // Perception
    public float attackRange = 10f;
    public float sightRange = 10f;
    private bool _isPlayerInSight;
    private bool _isPlayerInAttackRange;

    // Patrol
    private Vector3 _patrolPoint;
    private bool _patrol;
    public float patrolRadius = 10.0f;

    // Debug
    public bool enableGizmos;
    
    private void Awake()
    {
        target = GameObject.Find("NMN_AV_JamesHeresy_V1").transform;
        agent = GetComponent<NavMeshAgent>();
    }

    private void Update()
    {
        var position = transform.position;
        _isPlayerInSight = Physics.CheckSphere(position, sightRange, player);
        _isPlayerInAttackRange = Physics.CheckSphere(position, attackRange, player);
        
        if (!_isPlayerInSight && !_isPlayerInAttackRange) Patrol();
        else if (_isPlayerInSight && !_isPlayerInAttackRange) Chase();
        else if (_isPlayerInAttackRange) Attack();
    }

    private void Patrol()
    {
        if (!_patrol) GetNewPatrolPoint();
        else agent.SetDestination(_patrolPoint);

        Vector3 distance = transform.position - _patrolPoint;

        if (distance.magnitude < 1.0)
            _patrol = false;
    }
    
    private void GetNewPatrolPoint()
    {
        var position = transform.position;
        float x = Random.Range(-patrolRadius, patrolRadius);
        float z = Random.Range(-patrolRadius, patrolRadius);

        _patrolPoint = new Vector3(position.x + x, position.y, position.z + z);
        if (Physics.Raycast(_patrolPoint, -transform.up, ground)) _patrol = true;
    }

    private void Chase()
    {
        agent.SetDestination(target.position);
    }

    private void Attack()
    {
        var position = transform.position;
        agent.SetDestination(position);
        transform.LookAt(target);

        if (_attack) return;
        
        Rigidbody bullet = Instantiate(projectile, transform.position + new Vector3(0, 1.6f, 0), transform.rotation)
            .GetComponent<Rigidbody>();
        const float bulletSpeed = 32.0f;
        bullet.AddForce(transform.forward * bulletSpeed, ForceMode.Impulse);
        if (bullet.TryGetComponent(out HitDetection spawnedProjectile))
        {
            spawnedProjectile.setUpHitData(UNIT_TEAM.ENEMY, gameObject, 10.0f, MeleeAttackType.Ranged);
        }
            
        _attack = true;
        Invoke(nameof(ResetAttack), attackDelay);
    }

    private void ResetAttack()
    {
        _attack = false;
    }

    private void OnDrawGizmosSelected()
    {
        // ReSharper disable once InvertIf
        if (enableGizmos)
        {
            var position = transform.position;
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(position, sightRange);
            Gizmos.color = Color.blue;
            Gizmos.DrawWireSphere(position, attackRange);
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(position, patrolRadius);
        }
    }
}
