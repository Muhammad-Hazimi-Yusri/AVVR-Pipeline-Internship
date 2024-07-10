using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SoundClickToggle : MonoBehaviour
{
    void Start()
    {
        // set default settings on editor start
        GameObject audioSourceObj = GameObject.Find("Audio Source");
        audioSourceObj.GetComponent<PlaySoundOnClick>().enabled = false;

        AudioSource audioSource = audioSourceObj.GetComponent<AudioSource>();
        audioSource.playOnAwake = true;
        audioSource.loop = true;
    }

    [UnityEditor.MenuItem("AVVR/Toggle Manual Sound Mode")]
    public static void ToggleScript()
    {
        // get audio source object and toggle play on click script
        GameObject audioSourceObj = GameObject.Find("Audio Source");
        audioSourceObj.GetComponent<PlaySoundOnClick>().enabled = !audioSourceObj.GetComponent<PlaySoundOnClick>().enabled;

        // toggle play on awake and loop on/off
        AudioSource audioSource = audioSourceObj.GetComponent<AudioSource>();
        audioSource.playOnAwake = !audioSource.playOnAwake;
        audioSource.loop = !audioSource.loop;

        // notify user of current mode
        string dialog = audioSource.playOnAwake ? "Audio will play automatically." : "Audio will play on button press.";
        UnityEditor.EditorUtility.DisplayDialog("Audio Mode Set!", dialog, "OK");
    }
}
