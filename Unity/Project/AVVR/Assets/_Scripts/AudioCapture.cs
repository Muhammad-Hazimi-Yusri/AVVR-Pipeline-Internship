using UnityEngine;
using System.Collections.Generic;

[RequireComponent(typeof(AudioListener))]
public class AudioCapture : MonoBehaviour
{
    private List<float> capturedData = new List<float>();
    public bool isCapturing { get; private set; }
    public int capturedSampleRate { get; private set; }
    public int channelCount { get; private set; }

    public void StartCapturing()
    {
        capturedData.Clear();
        isCapturing = true;
        capturedSampleRate = AudioSettings.outputSampleRate;
        channelCount = AudioSettings.speakerMode == AudioSpeakerMode.Mono ? 1 : 2;
    }

    private void OnAudioFilterRead(float[] data, int channels)
    {
        if (isCapturing)
        {
            capturedData.AddRange(data);
        }
    }

    public float[] StopCapturingAndGetData()
    {
        isCapturing = false;
        return capturedData.ToArray();
    }
}