using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//Script to provide a function to set animator bool parameter
[RequireComponent(typeof(Animator))]
public class SetAnimatorParameter : MonoBehaviour {

    private Animator anim;

    [SerializeField] private string parameterName = "";

    private void Awake() {
        anim = GetComponent<Animator>();
    }
    public void SetOpen(bool value) {
        anim.SetBool(parameterName, value);
    }
    public void ToggleOpen() {
        anim.SetBool(parameterName, !anim.GetBool(parameterName));
    }
}
