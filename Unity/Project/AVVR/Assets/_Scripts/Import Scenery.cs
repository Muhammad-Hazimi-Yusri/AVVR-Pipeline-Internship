using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using Dummiesman;
using UnityEditor.SceneManagement;

[ExecuteInEditMode]
public class ImportScenery : MonoBehaviour
{
    [UnityEditor.MenuItem("AVVR/Import Scene")]
    public static void PerformImport()
    {
        try
        {
            // hide demo lidar overlay
            LoadDemo.ShowLIDAR(false);
        }
        catch (System.Exception e)
        {
            Debug.LogWarning("Failed to hide LIDAR: " + e.Message);
        }

        // call get new mesh to obtain obj file, then perform import automation
        ImportScene(GetNewMesh());
    }

    public static void ImportScene(GameObject AVVRScene)
    {
        if (AVVRScene == null)
        {
            UnityEditor.EditorUtility.DisplayDialog("Import cancelled!", "Invalid file (.obj file required).", "OK");
        }
        else
        {
            // Destroy existing scene using wrapper parent object
            GameObject existingWrapper = GameObject.Find("ModelWrapper");
            if (existingWrapper != null)
            {
                DestroyImmediate(existingWrapper);
            }

            // Initialize steam materials for model meshes and export steam geometry
            InitialiseMesh(AVVRScene);
            
            // Create new ModelWrapper
            GameObject modelWrapper = new GameObject("ModelWrapper");
            
            // Add MeshRenderer to ModelWrapper
            MeshRenderer meshRenderer = modelWrapper.AddComponent<MeshRenderer>();
            
            // Add custom script for dimension viewing
            modelWrapper.AddComponent<ModelDimensionsViewer>();
            
            // Set AVVRScene as child of ModelWrapper
            AVVRScene.transform.SetParent(modelWrapper.transform, false);

            // Add colliders to all meshes in the scene
            AddCollidersToMeshes(modelWrapper);

            // Update ModelWrapper's MeshRenderer bounds to encapsulate all children
            UpdateModelWrapperBounds(modelWrapper);

            // Resize locomotion area to new scene
            ResizeLocomotionArea();

            Debug.Log($"ModelWrapper dimensions: {meshRenderer.bounds.size}");
        }
    }

    private static void AddCollidersToMeshes(GameObject parent)
    {
        MeshFilter[] meshFilters = parent.GetComponentsInChildren<MeshFilter>();
        foreach (MeshFilter meshFilter in meshFilters)
        {
            GameObject obj = meshFilter.gameObject;
            if (obj.GetComponent<Collider>() == null)
            {
                MeshCollider meshCollider = obj.AddComponent<MeshCollider>();
                meshCollider.convex = false;
                meshCollider.cookingOptions = MeshColliderCookingOptions.EnableMeshCleaning | 
                                              MeshColliderCookingOptions.WeldColocatedVertices;
                Debug.Log($"Added MeshCollider to {obj.name}");
            }
        }
    }

    private static void UpdateModelWrapperBounds(GameObject modelWrapper)
    {
        MeshRenderer wrapperRenderer = modelWrapper.GetComponent<MeshRenderer>();
        Bounds bounds = new Bounds(Vector3.zero, Vector3.zero);
        bool boundsInitialized = false;

        // Collect all child renderers
        Renderer[] renderers = modelWrapper.GetComponentsInChildren<Renderer>();

        foreach (Renderer renderer in renderers)
        {
            if (!boundsInitialized)
            {
                bounds = renderer.bounds;
                boundsInitialized = true;
            }
            else
            {
                bounds.Encapsulate(renderer.bounds);
            }
        }

        // Set the ModelWrapper's MeshRenderer bounds
        wrapperRenderer.bounds = bounds;
    }

    private static void ResizeLocomotionArea()
    {
        GameObject locomotionArea = GameObject.Find("LocomotionArea");
        if (locomotionArea != null)
        {
            ResizeLocomotionArea resizeScript = locomotionArea.GetComponent<ResizeLocomotionArea>();
            if (resizeScript != null)
            {
                resizeScript.Resize();
            }
            else
            {
                Debug.LogWarning("ResizeLocomotionArea script not found on LocomotionArea.");
            }
        }
        else
        {
            Debug.LogWarning("LocomotionArea not found in the scene.");
        }
    }

    static GameObject GetNewMesh()
    {
        // starts in default folder for pipeline output        
        // Get the project root directory (4 levels up from Assets folder)
        string projectRoot = Directory.GetParent(Directory.GetParent(Directory.GetParent(Directory.GetParent(Application.dataPath).FullName).FullName).FullName).FullName;

        // Combine paths to get the default path
        string default_path = Path.Combine(projectRoot, "edgenet360", "Output");
        Debug.Log("Default path: " + default_path);
        string replace_path = UnityEditor.EditorUtility.OpenFilePanel("Select scene mesh", default_path, "obj");

        if (replace_path != null && replace_path != "" && replace_path.EndsWith(".obj"))
        {
            // use objloader library to load in new game object from mesh filepath
            GameObject newObj = new OBJLoader().Load(replace_path);
            return newObj;
        }
        else
        {
            return null;
        }
    }

    static void InitialiseMesh(GameObject uninitialisedGameObject)
    {
        // add assign materials component to game object (will iterate through children to assign)
        AssignMaterials materialAssigner = uninitialisedGameObject.AddComponent<AssignMaterials>();
            
        // initialise assignmaterial script in new gameobject
        materialAssigner.Initialise();
    }
}