using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections;

public class AudioRecorder : EditorWindow
{
    private int recordingLength = 25; // Default recording length in seconds
    private string fileName = "RecordedAudio"; // Default file name
    private string savePath; // Path to save the recorded audio
    private bool isRecording = false;
    private AudioClip recordedClip;
    private float startTime;
    private AudioCapture audioCapture;
    private EditorCoroutine recordingCoroutine;

    [MenuItem("Window/Audio Recorder")]
    public static void ShowWindow()
    {
        GetWindow<AudioRecorder>("Audio Recorder");
    }

    private void OnEnable()
    {
        savePath = Path.Combine(Application.dataPath, "Recordings");
        if (!Directory.Exists(savePath))
        {
            Directory.CreateDirectory(savePath);
        }
    }

    private void OnGUI()
    {
        GUILayout.Label("Audio Recorder Settings", EditorStyles.boldLabel);

        recordingLength = EditorGUILayout.IntField("Recording Length (seconds)", recordingLength);
        fileName = EditorGUILayout.TextField("File Name", fileName);

        EditorGUILayout.Space();

        if (!isRecording)
        {
            if (GUILayout.Button("Start Recording"))
            {
                StartRecording();
            }
        }
        else
        {
            EditorGUILayout.LabelField($"Recording in progress... {Time.realtimeSinceStartup - startTime:F1}s / {recordingLength}s");
            if (GUILayout.Button("Stop Recording"))
            {
                StopRecording();
            }
        }

        EditorGUILayout.Space();

        if (recordedClip != null)
        {
            EditorGUILayout.LabelField("Recorded Audio Clip", EditorStyles.boldLabel);
            EditorGUILayout.ObjectField(recordedClip, typeof(AudioClip), false);

            if (GUILayout.Button("Save as WAV"))
            {
                SaveRecordingAsWav();
            }
        }

        if (isRecording)
        {
            Repaint();
        }
    }

    private void StartRecording()
    {
        audioCapture = FindObjectOfType<AudioCapture>();
        if (audioCapture == null)
        {
            AudioListener listener = FindObjectOfType<AudioListener>();
            if (listener == null)
            {
                Debug.LogError("No AudioListener found in the scene. Please add one to your camera.");
                return;
            }
            audioCapture = listener.gameObject.AddComponent<AudioCapture>();
        }

        audioCapture.StartCapturing();
        isRecording = true;
        startTime = Time.realtimeSinceStartup;
        recordingCoroutine = EditorCoroutine.StartCoroutine(RecordingCoroutine());
    }

    private IEnumerator RecordingCoroutine()
    {
        while (Time.realtimeSinceStartup - startTime < recordingLength)
        {
            yield return null;
        }
        StopRecording();
    }

    private void StopRecording()
    {
        if (!isRecording) return;

        isRecording = false;
        if (recordingCoroutine != null)
        {
            recordingCoroutine.Stop();
            recordingCoroutine = null;
        }

        float[] samples = audioCapture.StopCapturingAndGetData();
        int sampleRate = audioCapture.capturedSampleRate;
        int channelCount = audioCapture.channelCount;

        // Calculate the expected number of samples
        int expectedSamples = sampleRate * recordingLength * channelCount;

        // Adjust the samples array to match the expected length
        if (samples.Length > expectedSamples)
        {
            Array.Resize(ref samples, expectedSamples);
        }
        else if (samples.Length < expectedSamples)
        {
            float[] paddedSamples = new float[expectedSamples];
            Array.Copy(samples, paddedSamples, samples.Length);
            samples = paddedSamples;
        }

        // Create AudioClip from recorded samples
        recordedClip = AudioClip.Create("RecordedAudio", expectedSamples / channelCount, channelCount, sampleRate, false);
        recordedClip.SetData(samples, 0);

        Debug.Log($"Recording stopped. Captured {samples.Length} samples ({(float)samples.Length / sampleRate / channelCount:F2} seconds at {sampleRate}Hz).");
    }

    private void SaveRecordingAsWav()
    {
        if (recordedClip != null)
        {
            string filePath = EditorUtility.SaveFilePanel("Save Audio", savePath, fileName, "wav");
            if (!string.IsNullOrEmpty(filePath))
            {
                SavWav.Save(filePath, recordedClip);
                Debug.Log($"Audio saved to: {filePath}. Duration: {recordedClip.length} seconds.");
            }
        }
        else
        {
            Debug.LogWarning("No audio recorded to save.");
        }
    }

    private void OnDisable()
    {
        if (isRecording)
        {
            StopRecording();
        }
    }
}


// Helper class to save AudioClip as WAV file
// Updated SavWav class
public static class SavWav
{
    const int HEADER_SIZE = 44;

    public static bool Save(string filename, AudioClip clip)
    {
        if (!filename.ToLower().EndsWith(".wav"))
        {
            filename += ".wav";
        }

        Debug.Log($"Saving AudioClip. Samples: {clip.samples}, Channels: {clip.channels}, Frequency: {clip.frequency}");

        using (var fileStream = CreateEmpty(filename))
        {
            ConvertAndWrite(fileStream, clip);
            WriteHeader(fileStream, clip);
        }

        return true;
    }

    static FileStream CreateEmpty(string filepath)
    {
        var fileStream = new FileStream(filepath, FileMode.Create);
        byte emptyByte = new byte();

        for (int i = 0; i < HEADER_SIZE; i++)
        {
            fileStream.WriteByte(emptyByte);
        }

        return fileStream;
    }

    static void ConvertAndWrite(FileStream fileStream, AudioClip clip)
    {
        var samples = new float[clip.samples * clip.channels];
        clip.GetData(samples, 0);

        Int16[] intData = new Int16[samples.Length];

        Byte[] bytesData = new Byte[samples.Length * 2];

        for (int i = 0; i < samples.Length; i++)
        {
            intData[i] = (short)(samples[i] * 32767);
            BitConverter.GetBytes(intData[i]).CopyTo(bytesData, i * 2);
        }

        fileStream.Write(bytesData, 0, bytesData.Length);
    }

    static void WriteHeader(FileStream fileStream, AudioClip clip)
    {
        var hz = clip.frequency;
        var channels = clip.channels;
        var samples = clip.samples;

        fileStream.Seek(0, SeekOrigin.Begin);

        Byte[] riff = System.Text.Encoding.UTF8.GetBytes("RIFF");
        fileStream.Write(riff, 0, 4);

        Byte[] chunkSize = BitConverter.GetBytes(fileStream.Length - 8);
        fileStream.Write(chunkSize, 0, 4);

        Byte[] wave = System.Text.Encoding.UTF8.GetBytes("WAVE");
        fileStream.Write(wave, 0, 4);

        Byte[] fmt = System.Text.Encoding.UTF8.GetBytes("fmt ");
        fileStream.Write(fmt, 0, 4);

        Byte[] subChunk1 = BitConverter.GetBytes(16);
        fileStream.Write(subChunk1, 0, 4);

        UInt16 two = 2;
        UInt16 one = 1;

        Byte[] audioFormat = BitConverter.GetBytes(one);
        fileStream.Write(audioFormat, 0, 2);

        Byte[] numChannels = BitConverter.GetBytes(channels);
        fileStream.Write(numChannels, 0, 2);

        Byte[] sampleRate = BitConverter.GetBytes(hz);
        fileStream.Write(sampleRate, 0, 4);

        Byte[] byteRate = BitConverter.GetBytes(hz * channels * 2); // sampleRate * bytesPerSample*number of channels
        fileStream.Write(byteRate, 0, 4);

        UInt16 blockAlign = (ushort)(channels * 2);
        fileStream.Write(BitConverter.GetBytes(blockAlign), 0, 2);

        UInt16 bps = 16;
        Byte[] bitsPerSample = BitConverter.GetBytes(bps);
        fileStream.Write(bitsPerSample, 0, 2);

        Byte[] datastring = System.Text.Encoding.UTF8.GetBytes("data");
        fileStream.Write(datastring, 0, 4);

        Byte[] subChunk2 = BitConverter.GetBytes(samples * channels * 2);
        fileStream.Write(subChunk2, 0, 4);
    }
}

// Simple EditorCoroutine implementation
public class EditorCoroutine
{
    public static EditorCoroutine StartCoroutine(IEnumerator routine)
    {
        EditorCoroutine coroutine = new EditorCoroutine(routine);
        coroutine.Start();
        return coroutine;
    }

    readonly IEnumerator routine;
    EditorCoroutine(IEnumerator routine)
    {
        this.routine = routine;
    }

    void Start()
    {
        EditorApplication.update += Update;
    }
    public void Stop()
    {
        EditorApplication.update -= Update;
    }

    void Update()
    {
        if (!routine.MoveNext())
        {
            Stop();
        }
    }
}