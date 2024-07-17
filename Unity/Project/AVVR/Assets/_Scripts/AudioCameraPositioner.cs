using UnityEngine;
using System.Collections.Generic;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class AudioCameraPositioner : MonoBehaviour
{
    public Camera mainCamera;
    public List<AudioSource> audioSources = new List<AudioSource>();
    public GameObject modelWrapper;

    [System.Serializable]
    public class PositionSetting
    {
        public string name;
        public Vector3 position;
    }

    public PositionSetting cameraPosition = new PositionSetting { name = "Camera" };
    public List<PositionSetting> audioSourcePositions = new List<PositionSetting>();

    private Vector3 roomSize;
    private Vector3 roomCenter;
    private Vector3 roomMinPoint;


    public void PositionCamera()
    {
        if (mainCamera == null)
        {
            Debug.LogError("Main camera is not assigned!");
            return;
        }

        mainCamera.transform.position = cameraPosition.position;
        Debug.Log($"Camera positioned at: {cameraPosition.position}");
    }

    public void PositionAudioSources()
    {
        for (int i = 0; i < audioSources.Count && i < audioSourcePositions.Count; i++)
        {
            if (audioSources[i] == null)
            {
                Debug.LogWarning($"Audio source at index {i} is not assigned!");
                continue;
            }

            audioSources[i].transform.position = audioSourcePositions[i].position;
            Debug.Log($"Audio source '{audioSourcePositions[i].name}' positioned at: {audioSourcePositions[i].position}");
        }
    }

    public void PositionAll()
    {
        PositionCamera();
        PositionAudioSources();
    }

    public void CalculateRoomDimensions()
    {
        if (modelWrapper == null)
        {
            Debug.LogError("ModelWrapper is not assigned!");
            return;
        }

        Bounds bounds = new Bounds(modelWrapper.transform.position, Vector3.zero);
        Renderer[] renderers = modelWrapper.GetComponentsInChildren<Renderer>();
        
        if (renderers.Length == 0)
        {
            Debug.LogError("No Renderer components found in the ModelWrapper's children!");
            return;
        }

        foreach (Renderer renderer in renderers)
        {
            bounds.Encapsulate(renderer.bounds);
        }

        roomSize = bounds.size;
        roomCenter = bounds.center;
        roomMinPoint = bounds.min;

        Debug.Log($"Room size: {roomSize}");
        Debug.Log($"Room center: {roomCenter}");
        Debug.Log($"Room min point: {roomMinPoint}");
    }

    public void AlignRoomCorner(int cornerIndex)
    {
        if (modelWrapper == null)
        {
            Debug.LogError("ModelWrapper is not assigned!");
            return;
        }

        CalculateRoomDimensions();

        // First, rotate the mesh
        Quaternion rotation = Quaternion.Euler(0, 90 * cornerIndex, 0);
        modelWrapper.transform.rotation = rotation;

        // Recalculate dimensions after rotation
        CalculateRoomDimensions();

        // Now, move the corner to (0, 0, 0)
        Vector3 translation = -roomMinPoint;
        modelWrapper.transform.position += translation;

        Debug.Log($"Room aligned to corner {cornerIndex}. Position: {modelWrapper.transform.position}, Rotation: {modelWrapper.transform.rotation.eulerAngles}");
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(AudioCameraPositioner))]
public class AudioCameraPositionerEditor : Editor
{
    private SerializedProperty mainCameraProperty;
    private SerializedProperty audioSourcesProperty;
    private SerializedProperty modelWrapperProperty;
    private SerializedProperty cameraPositionProperty;
    private SerializedProperty audioSourcePositionsProperty;

    private void OnEnable()
    {
        mainCameraProperty = serializedObject.FindProperty("mainCamera");
        audioSourcesProperty = serializedObject.FindProperty("audioSources");
        modelWrapperProperty = serializedObject.FindProperty("modelWrapper");
        cameraPositionProperty = serializedObject.FindProperty("cameraPosition");
        audioSourcePositionsProperty = serializedObject.FindProperty("audioSourcePositions");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.PropertyField(mainCameraProperty);
        EditorGUILayout.PropertyField(audioSourcesProperty, true);
        EditorGUILayout.PropertyField(modelWrapperProperty);

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Camera Position", EditorStyles.boldLabel);
        EditorGUILayout.PropertyField(cameraPositionProperty);

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Audio Source Positions", EditorStyles.boldLabel);
        EditorGUILayout.PropertyField(audioSourcePositionsProperty, true);

        EditorGUILayout.Space();

        AudioCameraPositioner positioner = (AudioCameraPositioner)target;

        if (GUILayout.Button("Position Camera"))
        {
            positioner.PositionCamera();
        }

        if (GUILayout.Button("Position Audio Sources"))
        {
            positioner.PositionAudioSources();
        }

        if (GUILayout.Button("Position All"))
        {
            positioner.PositionAll();
        }

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Room Alignment", EditorStyles.boldLabel);

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Align Corner 0"))
        {
            positioner.AlignRoomCorner(0);
        }
        if (GUILayout.Button("Align Corner 1"))
        {
            positioner.AlignRoomCorner(1);
        }
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Align Corner 2"))
        {
            positioner.AlignRoomCorner(2);
        }
        if (GUILayout.Button("Align Corner 3"))
        {
            positioner.AlignRoomCorner(3);
        }
        GUILayout.EndHorizontal();

        if (GUI.changed)
        {
            serializedObject.ApplyModifiedProperties();
        }
    }
}
#endif