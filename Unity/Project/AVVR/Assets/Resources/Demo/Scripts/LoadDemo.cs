using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Dummiesman;

[ExecuteInEditMode]
public class LoadDemo : MonoBehaviour
{
    [UnityEditor.MenuItem("AVVR/Load Kitchen Demo")]
    public static void ShowObject()
    {
        ImportScenery.ImportScene(GetKitchenOutputMesh());
        ShowLIDAR(true);
        MakeTransparent();
    }

    // show lidar overlay mesh
    public static void ShowLIDAR(bool on)
    {
        GameObject kitchenDemoScene = GameObject.Find("KitchenDemoScene");
        if (kitchenDemoScene != null && kitchenDemoScene.transform.childCount > 0)
        {
            kitchenDemoScene.transform.GetChild(0).gameObject.SetActive(on);
        }
        else
        {
            Debug.LogWarning("KitchenDemoScene not found or has no children. Unable to show/hide LIDAR.");
        }
    }

    // get specific kitchen output mesh from resources folder
    static GameObject GetKitchenOutputMesh()
    {
        GameObject newObj = new OBJLoader().Load("Assets/Resources/Demo/DemoModel/flipped.obj");
        return newObj;
    }

    // make materials transparent to improve lidar visibility
    static void MakeTransparent()
    {
        GameObject modelwrapper = GameObject.Find("ModelWrapper");
        GameObject parent = modelwrapper.transform.GetChild(0).gameObject;

        foreach (Transform child in parent.transform)
        {
            Material material = child.gameObject.GetComponent<Renderer>().sharedMaterial;

            // set to transparent rendering
            material.SetFloat("_Mode", 3);
            material.renderQueue = 3000;

            // set material colour to specified alpha value
            Color color = material.color;
            color.a = 0.7f;
            material.color = color;
        }
    }
}
