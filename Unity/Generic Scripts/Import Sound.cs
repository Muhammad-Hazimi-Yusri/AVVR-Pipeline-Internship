using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using UnityEditor;

[ExecuteInEditMode]
public class ImportSound : MonoBehaviour
{
    static string[] extensions = {"wav", "ogg", "mp3"};

    [MenuItem("AVVR/Add Custom Audio File")]
    public static void AddAudioFile()
    {
        string filepath = GetAudioFilePath();

        if (filepath == null)
        {
            EditorUtility.DisplayDialog(
                "Import cancelled!", "Invalid file (.wav, .ogg, or .mp3 file required).", "OK");
        }
        else
        {
            AddFileToResources(filepath);
        }
    }

    static string GetAudioFilePath()
    {
        // build extension list for file selector
        string extension_list = "";
        foreach (string type in extensions)
        {
            extension_list += type + ",";
        }
        extension_list = extension_list.Substring(0, extension_list.Length - 1);

        // allow user file selection
        string filepath = EditorUtility.OpenFilePanel("Select audio file", "", extension_list);

        // return filepath if file of valid type
        if (filepath != null && filepath != "" && extensions.Contains(filepath.Substring(filepath.Length - 3)))
        {
            return filepath;
        }
        else
        {
            return null;
        }
    }

    // adds sound file to assets/resources location
    static void AddFileToResources(string filepath)
    {
        string name = System.IO.Path.GetFileName(filepath);
        string destination = "Assets/Resources/Audio/" + name;
        
        FileUtil.CopyFileOrDirectory(filepath, destination);
        AssetDatabase.Refresh();

        EditorUtility.DisplayDialog("Audio file added!", name + "added to assets. Assign with \"Change Audio\"." , "OK");
    }
}
