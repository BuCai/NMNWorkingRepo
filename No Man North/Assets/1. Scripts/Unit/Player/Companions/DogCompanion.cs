using System;
using System.Collections;
using System.Collections.Generic;
using SurvivalTemplatePro;
using UnityEngine;

public class DogCompanion : Companion
{
    private static readonly int Sit = Animator.StringToHash("Sit");
    private static readonly int Turn = Animator.StringToHash("Turn");

    private Vector3 _rotationLast;
    private Vector3 _angularVelocity;
    [SerializeField] private float enemyDetectionRadius;
    private static readonly int Bark = Animator.StringToHash("Bark");
    private static readonly int Sleep = Animator.StringToHash("Sleep");

    private void Start()
    {
        _rotationLast = transform.rotation.eulerAngles;
    }

    private void Update()
    {
        var rotation = transform.rotation.eulerAngles;
        _angularVelocity = rotation - _rotationLast;
        _rotationLast = rotation;
    }

    public override void SetActive(ICharacter character)
    {
        base.SetActive(character);
        Stay();
    }

    protected override IEnumerator StayCoroutine()
    {
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

    public override void Stay()
    {
        StopAllCoroutines();
        _isStaying = true;
        animator.SetFloat(Forward, 0);
        animator.SetBool(Sit, true);
        StartCoroutine(StayCoroutine());
        StartCoroutine(DetectEnemy());
    }

    public override void Follow()
    {
        StopAllCoroutines();
        _isStaying = false;
        var driver = _player.GetModule<IVehicleHandler>();
        if (driver.IsDriving)
        {
            GetInTheVan(driver.DogSeatTransform);
            return;
        }
        animator.SetBool(Sit, false);
        StartCoroutine(FollowCoroutine());
        StartCoroutine(DetectEnemy());
    }

    protected override IEnumerator FollowCoroutine()
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

            // The -2 and 2 are max "turn" values in the animator. -6.5 and 6.5 are experimentally found values for 
            // the largest reasonable angular velocity the dog can achieve.
            var rotationToTurn = Mathf.Lerp(-2, 2, Mathf.InverseLerp(-6.5f, 6.5f, _angularVelocity.y));
            animator.SetFloat(Turn, rotationToTurn);

            yield return new WaitForSeconds(0.1f);
        }
    }

    private IEnumerator DetectEnemy()
    {
        while (true)
        {
            var enemies = GameObject.FindGameObjectsWithTag("Enemy");
            if (enemies.Length > 0)
            {
                foreach (var enemy in enemies)
                {
                    if (!(Vector3.Distance(enemy.transform.position, transform.position) < enemyDetectionRadius))
                        continue;
                    animator.SetTrigger(Bark);
                    yield return new WaitForSeconds(4.0f);
                }
            }
            yield return new WaitForSeconds(10.0f);
        }
    }

    public override void GetInTheVan(Transform seat)
    {
        if (_isStaying) return;
        base.GetInTheVan(seat);
        animator.SetBool(Sleep, true);
        Debug.Log("Dog in the van");
    }
    
    public override void GetOutOfTheVan()
    {
        base.GetOutOfTheVan();
        animator.SetBool(Sleep, false);
    }
}