using UnityEngine;

[ExecuteInEditMode]
public class BrushPositionSetter : MonoBehaviour
{
    void Update()
    {
        Shader.SetGlobalVector("_BrushPos", transform.position);
    }
}