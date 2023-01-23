using System;
using UnityEngine;
using Random = UnityEngine.Random;

[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(Rigidbody))]
public class BirdAI : MonoBehaviour
{
    [Header("Movement")] [SerializeField] private float idleSpeed = 15.0f;

    [SerializeField] private float turnSpeed = 60.0f;

    // Time taken to go from old speed to new speed. Effectively acceleration in reverse.
    [SerializeField] private float switchTime = 1.0f;

    // Ratio of idle and flapping animation.
    [SerializeField] private float idleRatio = 0.1f;

    // Smaller min and max radii condense the flock of birds into a smaller area.
    [SerializeField] private Vector2 radiusMinMax = new(30.0f, 160.0f);

    // Flying floor and ceiling.
    [SerializeField] private Vector2 heightMinMax = new(30.0f, 80.0f);

    [Header("Animations")]
    // How rapidly the bird flaps.
    [SerializeField]
    private Vector2 animSpeedMinMax = new(1.0f, 3.0f);

    [SerializeField] private Vector2 moveSpeedMinMax = new(15.0f, 20.0f);

    // Min and max animation change intervals.
    [SerializeField] private Vector2 changeAnimaEveryFromTo = new(3.0f, 5.0f);

    // Home location, where the bird "lands".
    [Header("Targets")] [SerializeField] private Transform home;

    // Target the the bird loosely follows.
    [SerializeField] private Transform target;

    // How often the bird recalculates the target.
    [SerializeField] private Vector2 changeTargetEveryFromTo = new(0.5f, 1.5f);

    [SerializeField] private bool returnToBase;
    [SerializeField] private float randomOffset = 5.0f;
    [SerializeField] private float delayStart;

    [Header("Debug")] [SerializeField] private bool enableGizmos;

    private Animator _animator;
    private Rigidbody _rigidbody;

    private float _changeTarget,
        _changeAnim,
        _timeSinceAnim,
        _currentAnim,
        _prevSpeed,
        _speed,
        _zTurn,
        _prevZ,
        _turnSpeedBackup;

    private Vector3 _rotateTarget, _position, _direction, _velocity, _randomisedBase;
    private Quaternion _lookRotation;
    private float _distanceFromBase, _distanceFromTarget;

    private static readonly int Speed = Animator.StringToHash("speed");

    void Start()
    {
        _animator = GetComponent<Animator>();
        _rigidbody = GetComponent<Rigidbody>();
        _turnSpeedBackup = turnSpeed;
        _direction = Quaternion.Euler(transform.eulerAngles) * Vector3.forward;
        if (delayStart >= 0.0f) _rigidbody.velocity = idleSpeed * _direction;
    }

    // Update is called once per frame
    private void FixedUpdate()
    {
        if (delayStart > 0.0f)
        {
            delayStart -= Time.fixedDeltaTime;
            return;
        }

        _distanceFromBase = Vector3.Magnitude(_randomisedBase - _rigidbody.position);
        _distanceFromTarget = Vector3.Magnitude(target.position - _rigidbody.position);

        if (returnToBase && _distanceFromBase < 10.0f)
        {
            if (Math.Abs(turnSpeed - 300.0f) > 0.01f && _rigidbody.velocity.magnitude != 0.0f)
            {
                _turnSpeedBackup = turnSpeed;
                turnSpeed = 300.0f;
            }
            else if (_distanceFromBase <= 2.0f)
            {
                _rigidbody.velocity = Vector3.zero;
                turnSpeed = _turnSpeedBackup;
                return;
            }
        }

        if (_changeAnim < 0.0f)
        {
            ChangeAnim();
        }

        if (_changeTarget < 0.0f)
        {
            _rotateTarget = ChangeDirection(_rigidbody.transform.position);
            _changeTarget = returnToBase ? 0.2f : Random.Range(changeTargetEveryFromTo.x, changeTargetEveryFromTo.y);
        }

        // Turn when approaching height limits.
        if (_rigidbody.transform.position.y < heightMinMax.x + 10.0f ||
            _rigidbody.transform.position.y > heightMinMax.y - 10.0f)
            _rotateTarget.y = _rigidbody.transform.position.y < heightMinMax.x + 10.0f ? 1.0f : -1;

        // Clamp bird rotation so it doesn't fly upside down.
        _zTurn = Mathf.Clamp(Vector3.SignedAngle(_rotateTarget, _direction, Vector3.up), -45.0f, 45.0f);

        // De/increment timers.
        _changeAnim -= Time.fixedDeltaTime;
        _changeTarget -= Time.fixedDeltaTime;
        _timeSinceAnim += Time.fixedDeltaTime;

        // Rotate towards target.
        if (_rotateTarget != Vector3.zero)
            _lookRotation = Quaternion.LookRotation(_rotateTarget, Vector3.up);
        Vector3 rotation = Quaternion.RotateTowards(_rigidbody.rotation, _lookRotation, turnSpeed * Time.fixedDeltaTime)
            .eulerAngles;
        _rigidbody.transform.eulerAngles = rotation;

        // Roll into the turn
        var temp = _prevZ;
        if (_prevZ < _zTurn) _prevZ += Mathf.Min(turnSpeed * Time.fixedDeltaTime, _zTurn - _prevZ);
        else if (_prevZ >= _zTurn) _prevZ -= Mathf.Min(turnSpeed * Time.fixedDeltaTime, _prevZ - _zTurn);
        // Clamp roll so the bird doesn't fly upside down.
        _prevZ = Mathf.Clamp(_prevZ, -45.0f, 45.0f);
        _rigidbody.transform.Rotate(0, 0, _prevZ - temp, Space.Self);

        // Fly!
        _direction = Quaternion.Euler(transform.eulerAngles) * Vector3.forward;
        if (returnToBase && _distanceFromBase < idleSpeed)
            _rigidbody.velocity = Mathf.Min(idleSpeed, _distanceFromBase) * _direction;
        else
            _rigidbody.velocity = Mathf.Lerp(_prevSpeed, _speed, Mathf.Clamp(_timeSinceAnim / switchTime, 0.0f, 1.0f)) *
                                  _direction;

        // Hard clamp bird altitude to its height limits, just in case.
        // ReSharper disable once InvertIf
        if (_rigidbody.transform.position.y < heightMinMax.x || _rigidbody.transform.position.y > heightMinMax.y)
        {
            _position = _rigidbody.transform.position;
            _position.y = Mathf.Clamp(_position.y, heightMinMax.x, heightMinMax.y);
            _rigidbody.transform.position = _position;
        }
    }

    private void ChangeAnim()
    {
        _currentAnim = GetNewAnimState(_currentAnim);
        _changeAnim = Random.Range(changeAnimaEveryFromTo.x, changeAnimaEveryFromTo.y);
        _timeSinceAnim = 0;

        if (_currentAnim == 0)
            _speed = idleSpeed;
        else
            _speed = Mathf.Lerp(moveSpeedMinMax.x, moveSpeedMinMax.y,
                (_currentAnim - animSpeedMinMax.x) / (animSpeedMinMax.y - animSpeedMinMax.x));
    }

    private Vector3 ChangeDirection(Vector3 currentPosition)
    {
        Vector3 newDir;

        if (returnToBase)
        {
            _randomisedBase = home.position;
            _randomisedBase.y += Random.Range(-randomOffset, randomOffset);
            newDir = _randomisedBase - currentPosition;
        }
        // If birb's target left its radius, fly towards target.
        else if (_distanceFromTarget > radiusMinMax.y)
            newDir = target.position - currentPosition;
        // If birb's target is too close, fly away from target.
        else if (_distanceFromTarget < radiusMinMax.x)
            newDir = currentPosition - target.position;
        // If neither, fly wherever.
        else
        {
            // 360 degree freedom of choice in the horizontal plane to choose the next destination.
            var angleXZ = Random.Range((float) -Math.PI, (float) Math.PI);
            // Limit max angle of attack in the vertical plane. 50.0f is an arbitrary number, the smaller it is, the steeper the birb can fly.
            var angleY = Random.Range((float) -Math.PI / 50.0f, (float) Math.PI / 50.0f);
            newDir = MathF.Sin(angleXZ) * Vector3.forward + MathF.Cos(angleXZ) * Vector3.right +
                     MathF.Sin(angleY) * Vector3.up;
        }

        return newDir.normalized;
    }

    private float GetNewAnimState(float currentAnim)
    {
        var newState = Random.Range(0.0f, 1.0f) < idleRatio
            ? 0.0f
            : Random.Range(animSpeedMinMax.x, animSpeedMinMax.y);

        if (Math.Abs(newState - currentAnim) > 0.01f)
        {
            _animator.SetFloat(Speed, newState);
            _animator.speed = newState == 0 ? 1.0f : newState;
        }

        return newState;
    }

    private void OnDrawGizmos()
    {
        if (!enableGizmos) return;

        Gizmos.color = Color.red;
        Gizmos.DrawSphere(target.position, 1.0f);
        Gizmos.color = Color.magenta;
        var position = transform.position;
        Gizmos.DrawWireSphere(position, radiusMinMax.x);
        Gizmos.DrawWireSphere(position, radiusMinMax.y);
        Gizmos.color = Color.blue;
        Gizmos.DrawLine(position, new Vector3(position.x, heightMinMax.x, position.z));
        Gizmos.DrawLine(position, new Vector3(position.x, heightMinMax.y, position.z));
    }
}