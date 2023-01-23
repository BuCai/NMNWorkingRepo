using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

[System.Serializable]
public abstract class SubQuest : ScriptableObject {
    public string title;
    public SubquestState state { get; private set; }
    public UnityEvent onActivate;
    public UnityEvent onComplete;

    public virtual void Initialize(bool activate) {
        if (activate) {
            Activate();
        }
        //Any non-active initialization logic goes here
    }

    public virtual void Activate() {
        if (state != SubquestState.Pending) {
            return;
        }
        state = SubquestState.Active;
        onActivate.Invoke();
    }

    //If this is set to return true, the subquest type can run it's own coroutine when event-based logic falls short.
    //Done as coroutine so update intervals can be customized based on needs
    public virtual bool useCoroutine { get { return false; } }

    public virtual IEnumerator SQCoroutine() {
        yield return null;
    }
}
