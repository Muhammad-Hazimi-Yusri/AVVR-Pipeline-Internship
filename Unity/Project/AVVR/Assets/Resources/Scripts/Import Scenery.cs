using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Dummiesman;
using UnityEditor.SceneManagement;

[ExecuteInEditMode]
public class ImportScenery : MonoBehaviour
{
    [UnityEditor.MenuItem("AVVR/Import Scene")]
    public static void PerformImport()
    {
        // hide demo lidar overlay
        LoadDemo.ShowLIDAR(false);
        // call get new mesh to obtain obj file, then perform import automation
        ImportScene(GetNewMesh());
    }

    // automates importation of new scenery from new obj mesh
    public static void ImportScene(GameObject AVVRScene)
    {
        if (AVVRScene == null)
        {
            UnityEditor.EditorUtility.DisplayDialog("Import cancelled!", "Invalid file (.obj file required).", "OK");
        }
        else
        {
            // destroy existing scene using wrapper parent object
            GameObject existingWrapper = GameObject.Find("ModelWrapper");
            if (existingWrapper != null)
            {
                DestroyImmediate(existingWrapper);
            }

            // initialise steam materials for model meshes and export steam geometry
            InitialiseMesh(AVVRScene);
            // add to wrapper for deletion on next import
            AVVRScene.transform.parent = new GameObject("ModelWrapper").transform;

            // resize locomotion area to new scene
            GameObject.Find("LocomotionArea").GetComponent<ResizeLocomotionArea>().Resize();
        }
    }

    // gets new obj from file system
    static GameObject GetNewMesh()
    {
        // starts in default folder for pipeline output
        string default_path = "C:/Project/AV-VR-Internship/edgenet360/Output";
        string replace_path = UnityEditor.EditorUtility.OpenFilePanel("Select scene mesh", default_path, "obj");

        // TODO check if string ends in .obj
        if (replace_path != null && replace_path != "" && replace_path.Substring(replace_path.Length - 4) == ".obj")
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

    // automate adding of steam audio geometry/properties
    static void InitialiseMesh(GameObject uninitialisedGameObject)
    {
        // add assign materials component to game object (will iterate through children to assign)
        AssignMaterials materialAssigner = uninitialisedGameObject.AddComponent<AssignMaterials>();
            
        // initialise assignmaterial script in new gameobject
        materialAssigner.Initialise();
    }
}
