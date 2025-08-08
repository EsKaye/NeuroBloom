using UdonSharp;
using UnityEngine;

/// <summary>
/// Simple example orb that rotates at a constant speed.
/// Demonstrates UdonSharp usage for VRChat worlds.
/// </summary>
[UdonBehaviourSyncMode(BehaviourSyncMode.None)]
public class GeminiOrb : UdonSharpBehaviour
{
    // Degrees per second; exposed in Unity inspector for tuning.
    public float RotationSpeed = 45f;

    private void Update()
    {
        // Rotate the orb around its Y axis every frame.
        transform.Rotate(Vector3.up * (RotationSpeed * Time.deltaTime), Space.Self);
    }
}
