using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioZone : MonoBehaviour {
    [Range(0, 1)]
    public float ambientVolume = 1f;
    [Range(0, 1)]
    public float weatherVolume = 1f;
    [Range(0, 1)]
    public float thunderVolume = 1f;
}
