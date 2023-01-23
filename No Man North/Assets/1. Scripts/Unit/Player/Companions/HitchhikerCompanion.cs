using System;
using System.Collections;
using System.Collections.Generic;
using SurvivalTemplatePro;
using SurvivalTemplatePro.InventorySystem;
using UnityEngine;
using Random = UnityEngine.Random;

public class HitchhikerCompanion : Companion
{
    [SerializeField] private float CampRadius = 5f;
    [SerializeField] private InventoryStartupItemsInfo.ItemContainerStartupItems CookedFoodMenu;
    private static readonly int CookTrigger = Animator.StringToHash("Cook");
    private static readonly int Sit = Animator.StringToHash("Sit");

    public void LieLow()
    {
        _isStaying = true;
    }

    public void SetupCamp()
    {
        _isStaying = true;
    }

    public override void Follow()
    {
        base.Follow();
        animator.SetBool(CookTrigger, false);
        _isStaying = false;
        var driver = _player.GetModule<IVehicleHandler>();
        if (driver.IsDriving)
        {
            
            GetInTheVan(driver.HitchhikerSeatTransform);
        }
    }

    public override void Stay()
    {
        base.Stay();
        animator.SetBool(CookTrigger, false);
    }

    public void Cook()
    {
        StopAllCoroutines();
        _isStaying = true;
        GameObject[] campfire = GameObject.FindGameObjectsWithTag("Campfire");
        if (campfire.Length > 0)
        {
            foreach (GameObject fire in campfire)
            {
                if (Vector3.Distance(transform.position, fire.transform.position) < CampRadius)
                {
                    StartCoroutine(CookCoroutine(fire));
                    return;
                }
            }
        }
    }

    private IEnumerator CookCoroutine(GameObject campfire)
    {
        // FIXME: What if the hitchhiker can never get to the campfire?
        //        Reconsider while(true) loops
        while (true)
        {
            var position = transform.position;
            var fire = campfire.transform.position;
            var distanceVector = position - fire;
            var destination = fire + distanceVector.normalized * 0.8f;
            if (distanceVector.magnitude > 1.5f)
            {
                agent.speed = walkSpeed;
                animator.SetFloat(Forward, GetAnimationForwardSpeed(distanceVector.magnitude,
                    followDistance * 5), 0.1f, Time.deltaTime);
                agent.SetDestination(destination);
                Debug.Log("Moving to campfire " + distanceVector.magnitude);
                yield return new WaitForSeconds(0.5f);
                continue;
            }

            agent.speed = 0;
            agent.SetDestination(transform.position);
            animator.SetFloat(Forward, 0);
            Debug.Log("Ready to cook, chef!");

            animator.SetBool(CookTrigger, true);
            yield return new WaitForSeconds(23.0f);
            Debug.Log("Food is ready!");
            animator.SetBool(CookTrigger, false);
            // Get random cooked food from menu
            var randomIndex = Random.Range(0, CookedFoodMenu.StartupItems.Length);
            var randomFood = CookedFoodMenu.StartupItems[randomIndex];

            _player.Inventory.AddItem(randomFood.GenerateItem(), ItemContainerFlags.Storage);
            StopAllCoroutines();
            yield return null;
        }
    }

    public override void GetInTheVan(Transform seat)
    {
        if (_isStaying || IsInVan) return;
        base.GetInTheVan(seat);
        animator.SetBool(Sit, true);
        Debug.Log("Hitchhiker in the van");
    }

    public override void GetOutOfTheVan()
    {
        base.GetOutOfTheVan();
        animator.SetBool(Sit, false);
    }

    // gizmos
    private void OnDrawGizmosSelected()
    {
        if (!debug)
            return;
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireSphere(transform.position, CampRadius);
    }
}