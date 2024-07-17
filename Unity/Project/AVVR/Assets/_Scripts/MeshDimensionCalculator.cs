using UnityEngine;
using System.Collections.Generic;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class MeshDimensionCalculator : MonoBehaviour
{
    public GameObject modelWrapper;
    private Vector3 totalMin = Vector3.positiveInfinity;
    private Vector3 totalMax = Vector3.negativeInfinity;
    private Vector3 dimensions;
    private Vector3 center;

    public void CalculateDimensions()
    {
        if (modelWrapper == null)
        {
            Debug.LogError("ModelWrapper is not assigned!");
            return;
        }

        totalMin = Vector3.positiveInfinity;
        totalMax = Vector3.negativeInfinity;

        Transform finalOutputSceneMesh = modelWrapper.transform.Find("final_output_scene_mesh");
        if (finalOutputSceneMesh == null)
        {
            Debug.LogError("final_output_scene_mesh not found!");
            return;
        }

        List<MeshFilter> meshFilters = new List<MeshFilter>();
        for (int i = 0; i < finalOutputSceneMesh.childCount; i++)
        {
            Transform child = finalOutputSceneMesh.GetChild(i);
            if (child.name.StartsWith("Input_prediction_mesh_mat"))
            {
                MeshFilter meshFilter = child.GetComponent<MeshFilter>();
                if (meshFilter != null)
                {
                    meshFilters.Add(meshFilter);
                }
            }
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

    public void ResetToOrigin()
    {
        if (modelWrapper == null)
        {
            Debug.LogError("ModelWrapper is not assigned!");
            return;
        }

        modelWrapper.transform.position = Vector3.zero;
        Debug.Log("ModelWrapper has been reset to (0,0,0).");
    }

    public void ResetFloorToZero()
    {
        if (modelWrapper == null)
        {
            Debug.LogError("ModelWrapper is not assigned!");
            return;
        }

        if (totalMin.y == Mathf.Infinity)
        {
            Debug.LogWarning("Please calculate dimensions first!");
            return;
        }

        Vector3 currentPosition = modelWrapper.transform.position;
        modelWrapper.transform.position = new Vector3(currentPosition.x, -totalMin.y, currentPosition.z);
        Debug.Log($"ModelWrapper floor has been reset to Y = 0. New position: {modelWrapper.transform.position}");
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