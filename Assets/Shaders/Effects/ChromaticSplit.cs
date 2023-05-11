using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ImageEffectAllowedInSceneView,ExecuteInEditMode]
public class ChromaticSplit : MonoBehaviour
{
    public Vector2 redOffset;
    public Vector2 greenOffset;
    public Vector2 blueOffset;

    private Camera cam;
    private Shader shader;
    private Material mat;
    // Start is called before the first frame update
    private void OnPreCull()
    {
        if (cam==null)
            cam = GetComponent<Camera>();
        if (shader==null) shader = Shader.Find("Custom/ChromaticSplit");
        if (shader != null && mat == null) mat = new Material(shader);
    }

    private void OnDisable()
    {
        #if UNITY_EDITOR
        if (Application.isPlaying)
        {
            Destroy(mat);
        }else DestroyImmediate(mat);
        #else
        Destroy(mat);
        #endif
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (cam==null||mat==null)Graphics.Blit(source,destination);
        else
        {
            mat.SetVector("_RedOffset",redOffset);
            mat.SetVector("_GreenOffset",greenOffset);
            mat.SetVector("_BlueOffset",blueOffset);
            Graphics.Blit(source,destination,mat,0);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
