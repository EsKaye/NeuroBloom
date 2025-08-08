using UnityEngine;

/// <summary>
/// Base class for all guardian behaviours. Handles subscription to the ops bus
/// and basic whisper routing so derived guardians only implement their own logic.
/// </summary>
public class GuardianBase : MonoBehaviour {
    [Header("Identity")]
    public string GuardianName = "Guardian";
    public string Role = "Undefined";

    protected virtual void OnEnable(){
        if (LilybearOpsBus.I != null)
            LilybearOpsBus.I.OnWhisper += HandleWhisper;
    }

    protected virtual void OnDisable(){
        if (LilybearOpsBus.I != null)
            LilybearOpsBus.I.OnWhisper -= HandleWhisper;
    }

    /// <summary>
    /// Called whenever the bus relays a message. Derived classes can override OnMessage
    /// to react to whispers addressed to them.
    /// </summary>
    protected virtual void HandleWhisper(string from, string to, string message){
        if (to == GuardianName || to == "*") {
            Debug.Log($"[{GuardianName}] received from {from}: {message}");
            OnMessage(from, message);
        }
    }

    /// <summary>
    /// Implement guardian-specific logic for incoming whispers.
    /// </summary>
    public virtual void OnMessage(string from, string message) {}

    /// <summary>
    /// Utility method for sending a whisper to another guardian or broadcast.
    /// </summary>
    protected void Whisper(string to, string message){
        LilybearOpsBus.I?.Say(GuardianName, to, message);
    }
}
