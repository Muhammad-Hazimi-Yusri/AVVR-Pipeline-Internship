using UnityEngine;
using System.Collections;

public class DelayedAudioPlay : MonoBehaviour
{
    public float delayTime = 2f; // Delay in seconds
    public AudioSource[] audioSources; // Array of AudioSources to play

    private void Start()
    {
        // If audioSources is empty, try to get all AudioSources from this GameObject
        if (audioSources.Length == 0)
        {
            audioSources = GetComponents<AudioSource>();
        }

        // Start the coroutine to play audio after delay
        StartCoroutine(PlayAudioAfterDelay());
    }

    private IEnumerator PlayAudioAfterDelay()
    {
        // Wait for the specified delay time
        yield return new WaitForSeconds(delayTime);

        // Play all audio sources
        foreach (AudioSource source in audioSources)
        {
            if (source != null)
            {
                source.Play();
                Debug.Log($"Playing audio source: {source.name}");
            }
        }
    }
}