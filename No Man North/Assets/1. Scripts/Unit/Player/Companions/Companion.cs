using System;
using System.Collections;
using System.Collections.Generic;
using SurvivalTemplatePro;
using SurvivalTemplatePro.CompanionSystem;
using UnityEngine;
using UnityEngine.AI;
using Action = SurvivalTemplatePro.CompanionSystem.Action;

[RequireComponent(typeof(Rigidbody))]
[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(NavMeshAgent))]
[RequireComponent(typeof(BoxCollider))]
public class Companion : Interactable, ICompanion
{
    public string Name => name;
    public bool IsActive => _isActive;
    public bool IsInVan { get; private set; }
    public ICharacter Player => _player;
    public Action[] Actions => actions;
    public Transform PlayerPosition => _player.transform;
    public bool IsStaying => _isStaying;

    // This is true when the companion is not doing any actions. While it's true, we check if the player is too far away
    // and if so, we forget about the player.
    protected bool _isStaying = true;
    private bool _isActive;
    protected ICharacter _player;
    private IActions _actionsModule;

    protected NavMeshAgent agent;
    protected Animator animator;
    private Rigidbody rigidbody;
    private BoxCollider boxCollider;

    [SerializeField] protected string name;
    [SerializeField] protected float followDistance = 10f;
    [SerializeField] protected float forgetAboutPlayerDistance = 200f;
    [SerializeField] protected float walkSpeed = 3.0f;
    [SerializeField] protected float runSpeed = 8.0f;
    [SerializeField] protected bool debug;

    [SerializeField] private Action[] actions;
    protected static readonly int Forward = Animator.StringToHash("Forward");


    public override void OnInteract(ICharacter character)
    {
        if (character.TryGetModule(out IPlayerCompanionHandler playerCompanionHandler))
        {
            base.OnInteract(character);
            if (playerCompanionHandler.AddCompanion(this) && character.TryGetModule(out IActions actionsModule))
            {
                _actionsModule = actionsModule;
                SetActive(character);
            }
        }
    }

    public void ForgetAboutPlayer()
    {
        StopAllCoroutines();
        _player.TryGetModule(out IPlayerCompanionHandler playerCompanionHandler);
        playerCompanionHandler.RemoveCompanion(this);
        foreach (var action in actions)
        {
            _actionsModule.RemoveAction(action);
        }

        _isActive = false;
        _player = null;
        InteractionEnabled = true;
    }

    public virtual void SetActive(ICharacter character)
    {
        _player = character;
        _isActive = true;
        InteractionEnabled = false;
        foreach (var action in actions)
        {
            _actionsModule.AddAction(action);
        }
    }

    protected virtual IEnumerator StayCoroutine()
    {
        animator.SetFloat(Forward, 0);
        // NOTE: This is spooky. Consider something else.
        while (true)
        {
            var position = transform.position;
            var player = PlayerPosition.position;
            var distance = Vector3.Distance(position, player);
            if (distance > forgetAboutPlayerDistance)
                ForgetAboutPlayer();
            yield return new WaitForSeconds(5f);
        }
    }

    public virtual void Stay()
    {
        StopAllCoroutines();
        _isStaying = true;
        StartCoroutine(StayCoroutine());
    }

    public virtual void Follow()
    {
        StopAllCoroutines();
        _isStaying = false;
        StartCoroutine(FollowCoroutine());
    }

    protected virtual IEnumerator FollowCoroutine()
    {
        // NOTE: This is also spooky. Consider something else.
        while (true)
        {
            var position = transform.position;
            var player = PlayerPosition.position;
            var distanceVector = position - player;
            var destination = player + distanceVector.normalized * followDistance;
            var remainingDistance = destination - position;
            var speed = GetApproachSpeed(remainingDistance.magnitude, followDistance * 5);
            if (distanceVector.magnitude > followDistance)
            {
                animator.SetFloat(Forward, GetAnimationForwardSpeed(remainingDistance.magnitude,
                    followDistance * 5), 0.1f, Time.deltaTime);
                agent.speed = speed;
                agent.SetDestination(destination);
            }
            else
            {
                // transform.LookAt(player, Vector3.up);
                animator.SetFloat(Forward, 0.0f);
            }

            yield return new WaitForSeconds(0.1f);
        }
    }

    /*
     * This is a simple remapping function that takes takes a value between remaining and total distance and remaps
     * it to a value between walk speed and run speed.
     */
    protected float GetApproachSpeed(float remainingDistance, float totalDistance)
    {
        return Mathf.Lerp(walkSpeed, runSpeed, Mathf.InverseLerp(2, totalDistance, remainingDistance));
    }

    protected float GetAnimationForwardSpeed(float remainingDistance, float totalDistance)
    {
        return Mathf.Lerp(0, runSpeed, Mathf.InverseLerp(0, totalDistance, remainingDistance));
    }

    public virtual void GetInTheVan(Transform seat)
    {
        if (_isStaying || IsInVan) return;
        IsInVan = true;
        StopAllCoroutines();
        var pos = transform;
        boxCollider.enabled = false;
        agent.enabled = false;
        pos.SetParent(seat);
        pos.localPosition = Vector3.zero;
        pos.localRotation = Quaternion.identity;
    }

    public virtual void GetOutOfTheVan()
    {
        if (!IsInVan) return;
        var pos = transform;
        IsInVan = false;
        pos.SetParent(null);
        pos.position = PlayerPosition.position + PlayerPosition.forward * -2;
        boxCollider.enabled = true;
        agent.enabled = true;
    }

    private void Awake()
    {
        agent = GetComponent<NavMeshAgent>();
        animator = GetComponent<Animator>();
        rigidbody = GetComponent<Rigidbody>();
        boxCollider = GetComponent<BoxCollider>();
        foreach (var action in actions)
        {
            action.Companion = this;
        }
    }


    private void OnDrawGizmosSelected()
    {
        // ReSharper disable once InvertIf
        if (debug)
        {
            var position = transform.position;
            Gizmos.color = Color.red;
            var playerPosition = PlayerPosition.position;
            Gizmos.DrawLine(position, playerPosition);
            Gizmos.color = Color.blue;
            Gizmos.DrawWireSphere(playerPosition, followDistance);
            var target = (position - playerPosition).normalized * followDistance;
            Gizmos.color = Color.green;
            Gizmos.DrawSphere(playerPosition + target, 0.5f);
            Gizmos.DrawLine(position, playerPosition + target);
        }
    }
}