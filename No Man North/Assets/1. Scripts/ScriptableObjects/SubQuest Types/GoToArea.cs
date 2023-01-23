using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[CreateAssetMenu(fileName = "GoToAreaSQ", menuName = "Quests/New Subquest/Go To Area", order = 2)]
public class GoToArea : SubQuest {

    [SerializeField] private string tagToTrack = "Player";
    [SerializeField] private Vector3 areaPosition = Vector3.zero;
    [SerializeField] private float radius = 5;

    private GameObject objToTrack;

    public override void Activate() {
        base.Activate();
        objToTrack = GameObject.FindGameObjectWithTag(tagToTrack);
    }
}