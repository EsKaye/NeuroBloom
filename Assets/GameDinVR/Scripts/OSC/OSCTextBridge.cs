using UnityEngine;

/// <summary>
/// Placeholder component for future OSC hook.
/// External services (e.g., Serafina bot) can set text in-world via OSC.
/// </summary>
public class OSCTextBridge : MonoBehaviour {
    public TextMesh Target;

    /// <summary>
    /// Set the text of the assigned TextMesh.
    /// </summary>
    public void SetText(string s){
        if (Target) Target.text = s;
    }
}
