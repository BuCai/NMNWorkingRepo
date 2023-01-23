using System;
using System.Collections;
using System.Collections.Generic;
using MLC.NoManNorth.Eric;
using UnityEngine;
using Random = UnityEngine.Random;

[RequireComponent(typeof(AnimalAI))]
[RequireComponent(typeof(Animator))]
public class AnimalIdleBehaviour : MonoBehaviour
{
    private GameObject gameTime;
    private AnimalAI _animalAI;
    private TimeManager _timeManager;
    private Animator _animator;

    [Header("Rest and Sleep Times")]
    [SerializeField]
    private Vector2 sleepFromTo;
    [SerializeField] private float restRatio = 0.1f;
    [SerializeField] private bool neverSleep;

    [Header("Idle Behaviour")] [SerializeField] private bool hasIdleBehaviour = true;
    [SerializeField] private float idleRatio = 0.1f;
    [SerializeField] private Vector2 changeStateEveryFromTo;
    [SerializeField] private Vector2 changeDestinationEveryFromTo;

    [Header("Roaming")] [SerializeField] private Transform home;
    [SerializeField] private float roamingRadius = 10.0f;
    
    [Header("Debug")]
    [SerializeField] private bool enableGizmos;

    private float _changeState;
    private float _changeDestination;


    private bool _isResting;
    private bool _isSleeping;
    private bool _isIdling;
    private bool _isWalking;


    private static readonly int RestAnimation = Animator.StringToHash("rest");
    private static readonly int SleepAnimation = Animator.StringToHash("sleep");
    private static readonly int Idle = Animator.StringToHash("idle");

    private void Awake()
    {
        _animalAI = GetComponent<AnimalAI>();
        _animator = GetComponent<Animator>();
    }

    void Start()
    {
        gameTime = GameObject.FindGameObjectWithTag("TimeManager");
        if (gameTime == null)
        {
            Debug.LogError("TimeManager is null for animal behaviour!");
        }
        else
        {
            _timeManager = gameTime.GetComponent<TimeManager>();
        }
    }

    void Update()
    {
        if (_timeManager == null) return;
        if (_animalAI.IsIdling)
        {
            if ((_timeManager.GetCurrentHour() >= sleepFromTo.x || _timeManager.GetCurrentHour() < sleepFromTo.y) && !neverSleep)
            {
                _isResting = true;
                _isSleeping = true;
                _isIdling = false;
            }
            else
                _isSleeping = false;

            _animator.SetBool(RestAnimation, _isResting);
            _animator.SetBool(SleepAnimation, _isSleeping);

            if (_isSleeping) return;

            _changeDestination -= Time.deltaTime;

            if (_changeDestination <= 0.0f && !_isResting)
                ChangeDestination();
            
            _animalAI.GoToDestination();
            
            _changeState -= Time.deltaTime;
            if (_changeState <= 0.0f)
                GetNewState();

            if (!hasIdleBehaviour) return;
            
            _animator.SetBool(Idle, _isIdling);

        }
        else
        {
            _isSleeping = false;
            _isResting = false;
            _isIdling = false;
            
            _animator.SetBool(RestAnimation, _isResting);
            _animator.SetBool(SleepAnimation, _isSleeping);
            _animator.SetBool(Idle, _isIdling);
        }
    }

    private void GetNewState()
    {
        _changeState = Random.Range(changeStateEveryFromTo.x, changeStateEveryFromTo.y);
        var rest = Random.Range(0.0f, 1.0f);
        _isResting = rest < restRatio;
        if (rest < restRatio || !hasIdleBehaviour) return; 

        _isIdling = Random.Range(0.0f, 1.0f) < idleRatio;
    }

    private void ChangeDestination()
    {
        _changeDestination = Random.Range(changeDestinationEveryFromTo.x, changeDestinationEveryFromTo.y);
        // Get new destination within roaming radius
        _animalAI.Destination = home.position + new Vector3(Random.Range(-roamingRadius, roamingRadius), 0,
            Random.Range(-roamingRadius, roamingRadius));

    }

    private void OnDrawGizmos()
    {
        if (!enableGizmos) return;
        
        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(home.position, roamingRadius);
    }
}