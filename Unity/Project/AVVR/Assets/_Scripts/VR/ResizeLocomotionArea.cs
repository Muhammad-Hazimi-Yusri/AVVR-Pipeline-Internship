using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
public class ResizeLocomotionArea : MonoBehaviour
{
    // Start is called before the first frame update
    public void Resize()
    {
        // get target object of scene (contains meshes)
        GameObject targetObject = GameObject.Find("ModelWrapper").transform.GetChild(0).gameObject;

        if (targetObject != null)
        {
            // set vertices
            SetQuadVertices(GetMeshBoundVertices(targetObject));
        }
    }

    // gets the vectorised mesh bounds of the imported scene
    Vector3[] GetMeshBoundVertices(GameObject targetObject)
    {
        // get all meshes in parent object
        MeshFilter[] meshFilters = targetObject.GetComponentsInChildren<MeshFilter>();
        // holds mesh bounds
        Bounds combinedBounds = new Bounds(meshFilters[0].transform.position, Vector3.zero);

        // iterate through each sub-meshes bounds
        foreach (MeshFilter meshFilter in meshFilters)
        {
            combinedBounds.Encapsulate(meshFilter.sharedMesh.bounds);
        }

        // get array of world coords of 4 floor vertices
        Vector3 bottomLeft = targetObject.transform.TransformPoint(
            new Vector3(combinedBounds.min.x, 0f, combinedBounds.min.z));
        Vector3 bottomRight = targetObject.transform.TransformPoint(
            new Vector3(combinedBounds.min.x, 0f, combinedBounds.max.z));
        Vector3 topLeft = targetObject.transform.TransformPoint(
            new Vector3(combinedBounds.max.x, 0f, combinedBounds.min.z));
        Vector3 topRight = targetObject.transform.TransformPoint(
            new Vector3(combinedBounds.max.x, 0f, combinedBounds.max.z));

        return new Vector3[] {bottomLeft, bottomRight, topLeft, topRight};
    }

    void SetQuadVertices(Vector3[] newVertices)
    {
        // get quad's mesh
        Mesh quadMesh = GetComponent<MeshFilter>().sharedMesh;

        // set vertices
        quadMesh.vertices = newVertices;

        // recalculate mesh properties with updated vertices
        quadMesh.RecalculateNormals();
        quadMesh.RecalculateBounds();
        quadMesh.RecalculateTangents();

        // update collider
        GetComponent<MeshCollider>().sharedMesh = null;
        GetComponent<MeshCollider>().sharedMesh = quadMesh;
    }
}
