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
}

#if UNITY_EDITOR
[CustomEditor(typeof(MeshDimensionCalculator))]
public class MeshDimensionCalculatorEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

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
    }
}
#endif