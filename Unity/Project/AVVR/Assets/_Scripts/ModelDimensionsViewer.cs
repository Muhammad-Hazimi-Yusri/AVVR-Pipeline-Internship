using UnityEngine;

[ExecuteInEditMode]
public class ModelDimensionsViewer : MonoBehaviour
{
    [SerializeField] private Vector3 dimensions;
    [SerializeField] private float volume;
    [SerializeField] private float width;
    [SerializeField] private float height;
    [SerializeField] private float depth;

    void OnValidate()
    {
        UpdateDimensions();
    }

    void Update()
    {
        if (!Application.isPlaying)
        {
            UpdateDimensions();
        }
    }

    void UpdateDimensions()
    {
        MeshRenderer renderer = GetComponent<MeshRenderer>();
        if (renderer != null)
        {
            dimensions = renderer.bounds.size;
            width = dimensions.x;
            height = dimensions.y;
            depth = dimensions.z;
            volume = width * height * depth;
        }
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireCube(transform.position, dimensions);
    }
}