using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Windows;

public class TextureGenerator : EditorWindow
{
    private const string WARNING = "Please Drag the material into the slot!";
    public enum Resolution
    {
        x128 = 128,
        x256 = 256,
        x512 = 512,
        x1024 = 1024,
        x2048 = 2048
    };
    public enum OutputType
    {
        Albedo =0,
        Normal =1
    }
    public Material material;
    public Resolution resolution = Resolution.x1024;
    public OutputType outputType;


    private void OnGUI()
    {
        EditorGUILayout.Space();
        if (!material)
        {
            EditorGUILayout.HelpBox(WARNING, MessageType.Warning,true);
        }
        EditorGUILayout.Space();
        GUIStyle style = new GUIStyle();
        style.fontStyle = FontStyle.Bold;
        style.richText = true;
        style.normal.textColor = Color.red;
        EditorGUILayout.LabelField("Material Box",style);
        material= (Material)EditorGUILayout.ObjectField("Material",material,typeof(Material),false,GUILayout.MinWidth(350));
        EditorGUILayout.Space();
        GUIStyle popupStyle = new GUIStyle(EditorStyles.popup);
        popupStyle.fontStyle = FontStyle.Italic;
        popupStyle.alignment = TextAnchor.MiddleCenter;
        resolution = (Resolution)EditorGUILayout.EnumPopup("Resolution",resolution,popupStyle);
        outputType = (OutputType)EditorGUILayout.EnumPopup("Output Type", outputType);
        EditorGUILayout.Space();
        EditorGUILayout.Separator();
        GUIStyle buttonStyle = new GUIStyle(EditorStyles.toolbarButton);
        EditorGUILayout.LabelField("Generate",style);
        if (GUILayout.Button("Generate")&& material)
        {
           Generate();
        }
        
        
    }

    private void Generate()
    {
        string path = EditorUtility.SaveFilePanel("Save",AssetDatabase.GetAssetPath(material),material.name,"png");
        if (!string.IsNullOrEmpty(path))
        {
            RenderTexture tempRT = RenderTexture.GetTemporary((int)resolution,(int)resolution);
            Graphics.Blit(Texture2D.blackTexture,tempRT,material,(int)outputType);
            Texture2D final = new Texture2D(tempRT.width,tempRT.height,TextureFormat.RGBA32,false);
            RenderTexture.active = tempRT;
            
            final.ReadPixels(new Rect(0,0,tempRT.width,tempRT.height),0,0);
            final.filterMode = FilterMode.Bilinear;
            final.Apply();
            
            File.WriteAllBytes(path,final.EncodeToPNG());
            RenderTexture.ReleaseTemporary(tempRT);
            RenderTexture.active = null;
            if (path.Contains("Assets"))
            {
                AssetDatabase.Refresh();
            }
        }
    }

    [MenuItem("Tools/Taka/Tex Gen",false,1)]
    public static void ShowWindow() => GetWindow(typeof(TextureGenerator));
}
