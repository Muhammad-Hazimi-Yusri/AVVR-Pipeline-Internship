using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using SteamAudio;
using Dummiesman;

[ExecuteInEditMode]
public class AssignMaterials : MonoBehaviour
{
    // define dictionary of mappings from DBAT output colours to their names
    Dictionary<string, string> colourDict = new Dictionary<string, string>
    {
            {"119, 17, 17", "asphalt"},
            {"202, 198, 144", "ceramic"},
            {"186, 200, 238", "concrete"},
            {"0, 0, 200", "fabric"},
            {"89, 125, 49", "foliage"},
            {"16, 68, 16", "food"},
            {"187, 129, 156", "glass"},
            {"208, 206, 72", "metal"},
            {"98, 39, 69", "paper"},
            {"102, 102, 102", "plaster"},
            {"76, 74, 95", "plastic"},
            {"16, 16, 68", "rubber"},
            {"68, 65, 38", "soil"},
            {"117, 214, 70", "stone"},
            {"221, 67, 72", "water"},
            {"92, 133, 119", "wood"}
    };

    // when gameobject initialised, assign geometry in scene and run steam audio export fucntion
    public void Initialise()
    {
        this.AssignGeometry();
        this.ExportSteamScene();
    }

    // assign steam geometries to submeshes
    void AssignGeometry()
    {
        foreach (Transform child in this.transform)
        {
            // get colour, format for dictionary lookup
            Color32 meshColour = child.gameObject.GetComponent<Renderer>().sharedMaterial.color;
            string rgb = $"{meshColour.r}, {meshColour.g}, {meshColour.b}";
            
            // get name of steam material to add
            string mat;

            try
            {
                mat = GetMatName(colourDict[rgb]);
            }
            catch (KeyNotFoundException)
            {
                mat = "default";
            }

            // add steam audio geometry, add material property from assets
            SteamAudioGeometry steam_geom = child.gameObject.AddComponent<SteamAudioGeometry>();

            SteamAudioMaterial mat_to_add = Resources.Load<SteamAudioMaterial>("Materials/" + mat);
            if (mat_to_add == null)
            {
                Resources.Load<SteamAudioMaterial>("Materials/Default");
            }
            steam_geom.material = mat_to_add;
        }
    }

    public void ExportSteamScene()
    {
        // find steam audio manager
        // export scene
        SteamAudioManager.ExportScene(gameObject.scene, false);
    }

    string GetMatName(string input)
    {
        if (input == null || input == "")
        {
            return "default";
        }

        char[] chars = input.ToCharArray();
        chars[0] = char.ToUpper(chars[0]);
        return new string(chars);
    }
}
