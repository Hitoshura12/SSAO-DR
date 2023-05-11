using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable,PostProcess(typeof(DepthToonRenderer),PostProcessEvent.AfterStack,"Taka/DepthToon",allowInSceneView:true)]
public class DepthToon : PostProcessEffectSettings
{
    [Range(0,1)]
    public FloatParameter FallOff = new FloatParameter() { value = 0.4f };
    [Range(0,1)]
    public FloatParameter Range = new FloatParameter() { value = 0.5f };
    [ColorUsage(false,false)]
    public ColorParameter Color = new ColorParameter() { value = new Color(1, 1, 0, 1) };
    [Range(0, 1)] 
    public FloatParameter Softness = new FloatParameter() { value = 0.6f };
    [Range(0, 1)] 
    public FloatParameter Coverage = new FloatParameter() { value = 0.1f };
    [ColorUsage(false,false)]
    public ColorParameter ShadowColor = new ColorParameter() { value = new Color(0.5f, 0.3f, 1, 1) };
    [Range(0,2)]
    public FloatParameter Width= new FloatParameter() { value = 0.4f };
    [Range(0,2)]
    public FloatParameter Height = new FloatParameter() { value = 0.2f };

    public BoolParameter CastShadows = new BoolParameter() { value = true };
}

public class DepthToonRenderer:PostProcessEffectRenderer<DepthToon>
{
    private const string SHADER = "Hidden/Taka/Effects/DepthToon";
    public override DepthTextureMode GetCameraFlags()
    {
        return DepthTextureMode.Depth;
    }

    public override void Render(PostProcessRenderContext context)
    {
        PropertySheet sheet = context.propertySheets.Get(Shader.Find(SHADER));
        sheet.properties.SetFloat("_Range", settings.Range);
        sheet.properties.SetFloat("_FallOff",settings.FallOff);
        sheet.properties.SetColor("_Color",settings.Color);
        sheet.properties.SetColor("_ShadowColor",settings.ShadowColor);
        sheet.properties.SetFloat("_Coverage",settings.Coverage);
        sheet.properties.SetFloat("_Softness",settings.Softness);
        sheet.properties.SetVector("_Size",new Vector2(settings.Width,settings.Height));
        sheet.properties.SetMatrix("_InverseMat", context.camera.cameraToWorldMatrix);
        sheet.properties.SetInt("_CastShadows",settings.CastShadows?1:0);
        if (RenderSettings.sun)
        {
            sheet.properties.SetVector("_LightDir",RenderSettings.sun.transform.forward);
        }
        context.command.BlitFullscreenTriangle(context.source,context.destination,sheet,0);
    }
}
