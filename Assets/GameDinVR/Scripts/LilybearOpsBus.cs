using UnityEngine;
using System;
using System.Collections.Generic;

/// <summary>
/// Simple in-scene event bus so guardians can whisper to each other.
/// Acts as the nervous system for cross-script communication inside the VRChat scene.
/// </summary>
public class LilybearOpsBus : MonoBehaviour {
    /// Singleton-like access for other components.
    public static LilybearOpsBus I;

    void Awake(){ I = this; }

    /// Delegate signature for a guardian whisper.
    public delegate void Whisper(string from, string to, string message);
    /// Fired whenever any guardian broadcasts via Say().
    public event Whisper OnWhisper;

    /// <summary>
    /// Broadcast a message to a specific guardian or '*' for everyone.
    /// </summary>
    public void Say(string from, string to, string message){
        OnWhisper?.Invoke(from, to, message);
        Debug.Log($"[LilybearBus] {from} → {to}: {message}");
    }
}
