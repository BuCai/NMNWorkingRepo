using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using Random = UnityEngine.Random;

[RequireComponent(typeof(AnimalHealth))]
[RequireComponent(typeof(Rigidbody))]
[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(NavMeshAgent))]
public class AnimalAI : MonoBehaviour
{
    public enum Behaviour
    {
        Ignore,
        Flee,
        Attack,
        Approach,
        PlayDead
    }

    private NavMeshAgent _agent;
    private Animator _animator;
    private AnimalHealth _animalHealth;
    public Vector3 Destination { get; set; }

    private bool _isFleeing;
    private bool _isAttacking = false;
    private bool _isApproaching = false;
    private bool _isDead = false;
    private bool _isBeingAttacked;
    public bool IsIdling { get; set; }


    [Header("Animal Settings")] public LayerMask groundMask, playerMask;
    public Behaviour approachedBehaviour;
    public Behaviour attackedBehaviour;
    public GameObject player;

    // Speed
    [Header("Speed")] public float walkSpeed = 3.0f;
    public float runSpeed = 8.0f;

    // Wandering
    [Header("Idle")] public float wanderRadius = 10.0f;

    // Perception
    [Header("Perception")] public float sightDistance = 10.0f;
    public float sightAngle = 90.0f;

    private bool _isPlayerInSight;
    private bool _isPlayerInAttackRange = false;

    // Attack
    [Header("Attacking")] public float attackRange = 5.0f;
    public float attackCooldown = 1.0f;


    // Debug
    [Header("Debug")] public bool enableGizmos;
    private static readonly int Forward = Animator.StringToHash("forward");
    private static readonly int AttackAnim = Animator.StringToHash("attack");
    private bool _isplayerNotNull;


    private void Awake()
    {
        _agent = GetComponent<NavMeshAgent>();
        _animator = GetComponent<Animator>();
        _animalHealth = GetComponent<AnimalHealth>();
    }

    void Start()
    {
        player = GameObject.FindGameObjectWithTag("Player");
        _isplayerNotNull = player != null;
    }

    void Update()
    {
        if (!_animalHealth.IsAlive())
        {
            IsIdling = false;
            return;
        }

        var position = transform.position;
        // Check if player is in sight
        if (_isplayerNotNull)
        {
            var playerPosition = player.transform.position;
            var direction = playerPosition - position;
            var distance = direction.magnitude;
            var angle = Vector3.Angle(direction, transform.forward);
            _isPlayerInSight = distance < sightDistance && angle < sightAngle;
            _isPlayerInAttackRange = distance < attackRange;
            _isBeingAttacked = _isPlayerInAttackRange || _animalHealth.GETIsHit();
        }

        if (_isBeingAttacked || _isPlayerInAttackRange)
        {
            switch (attackedBehaviour)
            {
                case Behaviour.Ignore:
                    break;
                case Behaviour.Flee:
                    Flee(2.5f);
                    break;
                case Behaviour.Attack:
                    Attack();
                    break;
                case Behaviour.Approach:
                    Approach();
                    break;
            }
        }

        if (_isPlayerInSight && !_isBeingAttacked)
        {
            switch (approachedBehaviour)
            {
                case Behaviour.Ignore:
                    break;
                case Behaviour.Flee:
                    Flee();
                    break;
                case Behaviour.Attack:
                    Attack();
                    break;
                case Behaviour.Approach:
                    Approach();
                    break;
            }
        }

        if (_isFleeing)
        {
            IsIdling = false;
            GoToDestination(true);
            return;
        }

        if (_isApproaching)
        {
            IsIdling = false;
            GoToDestination();
            return;
        }

        IsIdling = !_isBeingAttacked && !_isPlayerInSight;
    }

    private void Flee(float modifier = 2)
    {
        // Get direction away from player
        var position = transform.position;
        var playerPosition = player.transform.position;
        var direction = position - playerPosition;

        // Run away by sight distance
        Destination = position + direction.normalized * (sightDistance * modifier);

        // Ensure that the destination is on the ground
        if (!Physics.Raycast(Destination, -transform.up, groundMask)) return;
        _isFleeing = true;
    }

    private void Attack()
    {
        // Set destination to the player
        Destination = player.transform.position;
        _isFleeing = true;


        if (_isAttacking || !_isPlayerInAttackRange) return;

        _animator.SetTrigger(AttackAnim);
        // TODO: Perform attack and damage player here

        _isAttacking = true;
        Invoke(nameof(ResetAttack), attackCooldown);
    }

    private void Approach()
    {
        Destination = player.transform.position;
        _isApproaching = true;
    }

    private void ResetAttack()
    {
        _isAttacking = false;
    }

    public void GoToDestination(bool isRunning = false)
    {
        var position = transform.position;
        var distanceVector = position - Destination;
        _agent.speed = isRunning ? GetApproachSpeed(distanceVector.magnitude, sightDistance) : walkSpeed;
        var target = Destination + distanceVector.normalized * attackRange;
        _agent.SetDestination(target);
        _animator.SetFloat(Forward, _agent.speed);
        if (_agent.remainingDistance < 0.5f)
        {
            _animator.SetFloat(Forward, 0);
            _isFleeing = false;
            _isApproaching = false;
        }
    }

    private float GetApproachSpeed(float remainingDistance, float totalDistance)
    {
        return Mathf.Lerp(walkSpeed, runSpeed, Mathf.InverseLerp(2, totalDistance, remainingDistance));
    }


    private void OnDrawGizmosSelected()
    {
        // ReSharper disable once InvertIf
        if (enableGizmos)
        {
            var position = transform.position;
            Gizmos.color = Color.red;
            // Draw gizmos cone
            var forward = transform.forward;
            Gizmos.DrawLine(position, position + forward * sightDistance);
            Gizmos.DrawLine(position, position + Quaternion.Euler(0, sightAngle, 0) * forward * sightDistance);
            Gizmos.DrawLine(position, position + Quaternion.Euler(0, -sightAngle, 0) * forward * sightDistance);

            Gizmos.color = Color.magenta;
            // Draw destination
            Gizmos.DrawLine(position, Destination);

            Gizmos.color = Color.blue;
            Gizmos.DrawWireSphere(position, attackRange);
        }
    }
}