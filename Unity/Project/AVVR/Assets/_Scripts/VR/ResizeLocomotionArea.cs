using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class ResizeLocomotionArea : MonoBehaviour
{
    public void Resize()
    {
        GameObject modelWrapper = GameObject.Find("ModelWrapper");
        if (modelWrapper == null || modelWrapper.transform.childCount == 0)
        {
            Debug.LogWarning("ModelWrapper not found or has no children.");
            return;
        }

        GameObject targetObject = modelWrapper.transform.GetChild(0).gameObject;
        if (targetObject != null)
        {
            SetQuadVertices(GetMeshBoundVertices(targetObject));
        }
        else
        {
            Debug.LogWarning("Target object not found in ModelWrapper.");
        }
    }

    Vector3[] GetMeshBoundVertices(GameObject targetObject)
    {
        MeshFilter[] meshFilters = targetObject.GetComponentsInChildren<MeshFilter>();
        if (meshFilters.Length == 0)
        {
            Debug.LogWarning("No MeshFilters found in target object.");
            return new Vector3[4]; // Return default vertices
        }

        Bounds combinedBounds = new Bounds(meshFilters[0].transform.position, Vector3.zero);
        foreach (MeshFilter meshFilter in meshFilters)
        {
            if (meshFilter.sharedMesh != null)
            {
                combinedBounds.Encapsulate(meshFilter.sharedMesh.bounds);
            }
        }

        Vector3 bottomLeft = targetObject.transform.TransformPoint(new Vector3(combinedBounds.min.x, 0f, combinedBounds.min.z));
        Vector3 bottomRight = targetObject.transform.TransformPoint(new Vector3(combinedBounds.min.x, 0f, combinedBounds.max.z));
        Vector3 topLeft = targetObject.transform.TransformPoint(new Vector3(combinedBounds.max.x, 0f, combinedBounds.min.z));
        Vector3 topRight = targetObject.transform.TransformPoint(new Vector3(combinedBounds.max.x, 0f, combinedBounds.max.z));

        return new Vector3[] { bottomLeft, bottomRight, topLeft, topRight };
    }

    void SetQuadVertices(Vector3[] newVertices)
    {
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        if (meshFilter == null || meshFilter.sharedMesh == null)
        {
            Debug.LogWarning("MeshFilter or sharedMesh is null on ResizeLocomotionArea.");
            return;
        }

        Mesh quadMesh = meshFilter.sharedMesh;
        quadMesh.vertices = newVertices;
        quadMesh.RecalculateNormals();
        quadMesh.RecalculateBounds();
        quadMesh.RecalculateTangents();

        MeshCollider meshCollider = GetComponent<MeshCollider>();
        if (meshCollider != null)
        {
            meshCollider.sharedMesh = null;
            meshCollider.sharedMesh = quadMesh;
        }
        else
        {
            Debug.LogWarning("MeshCollider not found on ResizeLocomotionArea.");
        }
    }
}