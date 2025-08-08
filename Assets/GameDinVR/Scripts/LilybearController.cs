using UnityEngine;

/// <summary>
/// Lilybear: voice & operations hub. Routes commands and logs them.
/// This behaviour can be extended to bridge Discord traffic into the scene
/// via OSC or other networking later.
/// </summary>
public class LilybearController : GuardianBase {
    [TextArea] public string LastMessage;

    void Start(){
        GuardianName = "Lilybear";
        Role = "Voice & Operations";
    }

    public override void OnMessage(string from, string message){
        LastMessage = $"{from}: {message}";
        // Example: commands starting with '/route ' get broadcast to all guardians.
        if (message.StartsWith("/route ")){
            var payload = message.Substring(7); // strip '/route '
            Whisper("*", payload);
        }
    }

    /// <summary>
    /// Manual test hook visible in the Unity inspector.
    /// </summary>
    [ContextMenu("Test Whisper")]
    void TestWhisper(){
        Whisper("*", "The council is assembled.");
    }
}
