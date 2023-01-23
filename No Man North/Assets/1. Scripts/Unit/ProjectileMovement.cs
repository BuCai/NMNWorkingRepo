using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class ProjectileMovement : MonoBehaviour
{
	[SerializeField] private LayerMask Hitables;

	[SerializeField] private float moveSpeed = 1;

	private Vector3 prevPosition;

    // Start is called before the first frame update
    void Start()
    {
		prevPosition = this.transform.position;
    }

	public void setUp(float moveSpeedIn)
    {
		moveSpeed = moveSpeedIn;
    }

	private void cleanUp()
	{
		this.gameObject.SetActive(false);
	}

    // Update is called once per frame
    void Update()
    {
		Move();
	}

	private void Move()
	{
		prevPosition = this.transform.position;
		this.transform.Translate( GetNextMoveValue() );
	}

	private  Vector3 GetNextMoveValue()
	{
		return Vector3.forward * Time.deltaTime	* (moveSpeed);
	}

}