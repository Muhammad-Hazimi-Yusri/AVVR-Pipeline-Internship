using UnityEngine;
using System.Collections;
using UnityEditor;

public class DelayedAudioPlay : MonoBehaviour
{
    public float delayTime = 2f; // Delay in seconds
    private AudioSource audioSource;
    private AudioRecorder audioRecorder;

    private void Start()
    {
        audioSource = GetComponent<AudioSource>();
        audioRecorder = EditorWindow.GetWindow<AudioRecorder>();

        if (audioSource == null)
        {
            Debug.LogError("No AudioSource found on this GameObject.");
            return;
        }

        if (audioRecorder == null)
        {
            Debug.LogError("Audio Recorder window is not open. Please open it from Window > Audio Recorder.");
            return;
        }

        StartCoroutine(PlayAudioAfterDelay());
    }

    private IEnumerator PlayAudioAfterDelay()
    {
        yield return new WaitForSeconds(delayTime);

        audioRecorder.StartRecording();
        audioSource.Play();
        Debug.Log($"Playing audio source: {audioSource.name}");
    }
}