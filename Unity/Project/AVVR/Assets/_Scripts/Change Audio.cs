using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[ExecuteInEditMode]
public class ChangeAudio : MonoBehaviour
{
    [UnityEditor.MenuItem("AVVR/Change Audio")]
    public static void SelectAudio()
    {
        // opens focused inspector audio property window, allowing for sound source etc. to be changed
        AudioSource audioSource = GameObject.Find("Audio Source").GetComponent<AudioSource>();
        EditorUtility.OpenPropertyEditor(audioSource);
    }
}
