using System;
using System.Collections;
using System.Collections.Generic;
using Taka;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable,PostProcess(typeof(ShadowGradientRenderer),PostProcessEvent.BeforeTransparent,
     "Taka/ShadowGradient",allowInSceneView:true)]
public class ShadowGradient : PostProcessEffectSettings
{
    [Range(0, 1)] public FloatParameter mix = new FloatParameter{ value = 0.5f };

    public GradientParameter gradient = new GradientParameter
    {
      value = new Gradient()
      {
          colorKeys = new []
          {
            new GradientColorKey(Color.black,0f),
            new GradientColorKey(Color.white,1f)
          },
          alphaKeys = new[]
          {
              new GradientAlphaKey(1f,0f),new GradientAlphaKey(0.5f,1f)
          }
          
      }
    };


}

public class ShadowGradientRenderer : PostProcessEffectRenderer<ShadowGradient>
{
    private const string SHADER = "Hidden/Taka/Effects/ShadowGradient";
    public override void Render(PostProcessRenderContext context)
    {
        PropertySheet sheet = context.propertySheets.Get(Shader.Find(SHADER));
        sheet.properties.SetFloat("_Mix",settings.mix);
        sheet.properties.SetTexture("_Gradient",settings.gradient);
        context.command.BlitFullscreenTriangle(context.source,context.destination,sheet,0);
    }
}


