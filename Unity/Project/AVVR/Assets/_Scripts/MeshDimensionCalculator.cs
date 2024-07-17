using UnityEngine;
using System.Collections.Generic;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class MeshDimensionCalculator : MonoBehaviour
{
    public GameObject targetObject;
    private Vector3 totalMin = Vector3.positiveInfinity;
    private Vector3 totalMax = Vector3.negativeInfinity;
    private Vector3 dimensions;
    private Vector3 center;

    [SerializeField] private Vector3 scaleFactors = Vector3.one;
    [SerializeField] private float uniformScaleFactor = 1f;
    public void CalculateDimensions()
    {
        if (targetObject == null)
        {
            Debug.LogError("Target object is not assigned!");
            return;
        }

        totalMin = Vector3.positiveInfinity;
        totalMax = Vector3.negativeInfinity;

        List<MeshFilter> meshFilters = new List<MeshFilter>();
        CollectMeshFilters(targetObject.transform, meshFilters);

        if (meshFilters.Count == 0)
        {
            Debug.LogError("No meshes found in the target object's hierarchy!");
            return;
        }

        foreach (MeshFilter meshFilter in meshFilters)
        {
            Mesh mesh = meshFilter.sharedMesh;
            if (mesh == null) continue;

            Vector3[] vertices = mesh.vertices;
            for (int i = 0; i < vertices.Length; i++)
            {
                Vector3 worldVertex = meshFilter.transform.TransformPoint(vertices[i]);
                totalMin = Vector3.Min(totalMin, worldVertex);
                totalMax = Vector3.Max(totalMax, worldVertex);
            }
        }

        dimensions = totalMax - totalMin;
        center = (totalMin + totalMax) / 2;

        Debug.Log($"Total Dimensions: {dimensions}");
        Debug.Log($"Center: {center}");
        Debug.Log($"Floor Y position: {totalMin.y}");
    }

    private void CollectMeshFilters(Transform parent, List<MeshFilter> meshFilters)
    {
        MeshFilter meshFilter = parent.GetComponent<MeshFilter>();
        if (meshFilter != null)
        {
            meshFilters.Add(meshFilter);
        }

        for (int i = 0; i < parent.childCount; i++)
        {
            CollectMeshFilters(parent.GetChild(i), meshFilters);
        }
    }

    public void ResetToOrigin()
    {
        if (targetObject == null)
        {
            Debug.LogError("Target object is not assigned!");
            return;
        }

        targetObject.transform.position = Vector3.zero;
        Debug.Log("Target object has been reset to (0,0,0).");
    }

    public void ResetFloorToZero()
    {
        if (targetObject == null)
        {
            Debug.LogError("Target object is not assigned!");
            return;
        }

        if (totalMin.y == Mathf.Infinity)
        {
            Debug.LogWarning("Please calculate dimensions first!");
            return;
        }

        Vector3 currentPosition = targetObject.transform.position;
        targetObject.transform.position = new Vector3(currentPosition.x, -totalMin.y, currentPosition.z);
        Debug.Log($"Target object floor has been reset to Y = 0. New position: {targetObject.transform.position}");
    }

    public void ScaleObject()
    {
        if (targetObject == null)
        {
            Debug.LogError("Target object is not assigned!");
            return;
        }

        Vector3 currentScale = targetObject.transform.localScale;
        Vector3 newScale = new Vector3(
            currentScale.x * scaleFactors.x,
            currentScale.y * scaleFactors.y,
            currentScale.z * scaleFactors.z
        );

        targetObject.transform.localScale = newScale;
        Debug.Log($"Target object scaled. New scale: {newScale}");
    }

    public void ScaleObjectUniform()
    {
        if (targetObject == null)
        {
            Debug.LogError("Target object is not assigned!");
            return;
        }

        Vector3 currentScale = targetObject.transform.localScale;
        Vector3 newScale = currentScale * uniformScaleFactor;

        targetObject.transform.localScale = newScale;
        Debug.Log($"Target object scaled uniformly. New scale: {newScale}");
    }

    public void ResetScale()
    {
        if (targetObject == null)
        {
            Debug.LogError("Target object is not assigned!");
            return;
        }

        targetObject.transform.localScale = Vector3.one;
        Debug.Log("Target object scale has been reset to (1, 1, 1).");
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(MeshDimensionCalculator))]
public class MeshDimensionCalculatorEditor : Editor
{
    SerializedProperty targetObjectProperty;
    SerializedProperty scaleFactorsProperty;
    SerializedProperty uniformScaleFactorProperty;

    private void OnEnable()
    {
        targetObjectProperty = serializedObject.FindProperty("targetObject");
        scaleFactorsProperty = serializedObject.FindProperty("scaleFactors");
        uniformScaleFactorProperty = serializedObject.FindProperty("uniformScaleFactor");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.PropertyField(targetObjectProperty);

        MeshDimensionCalculator calculator = (MeshDimensionCalculator)target;

        if (GUILayout.Button("Calculate Dimensions"))
        {
            calculator.CalculateDimensions();
        }

        if (GUILayout.Button("Reset to Origin (0,0,0)"))
        {
            calculator.ResetToOrigin();
        }

        if (GUILayout.Button("Reset Floor to Y = 0"))
        {
            calculator.ResetFloorToZero();
        }

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Scaling Options", EditorStyles.boldLabel);

        EditorGUILayout.PropertyField(scaleFactorsProperty, new GUIContent("Scale Factors (X, Y, Z)"));
        if (GUILayout.Button("Apply Scale (X, Y, Z)"))
        {
            calculator.ScaleObject();
        }

        EditorGUILayout.Space();

        EditorGUILayout.PropertyField(uniformScaleFactorProperty, new GUIContent("Uniform Scale Factor"));
        if (GUILayout.Button("Apply Uniform Scale"))
        {
            calculator.ScaleObjectUniform();
        }

        EditorGUILayout.Space();

        if (GUILayout.Button("Reset Scale to (1, 1, 1)"))
        {
            calculator.ResetScale();
        }

        serializedObject.ApplyModifiedProperties();
    }
}
#endif