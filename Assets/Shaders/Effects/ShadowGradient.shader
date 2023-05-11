Shader "Hidden/Taka/Effects/ShadowGradient"
{
 HLSLINCLUDE
     #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
           #define tex2D(idx,uv) SAMPLE_TEXTURE2D(idx,sampler##idx,uv)
           #define sampler2D(idx) TEXTURE2D_SAMPLER2D(idx, sampler##idx)
            #define v2f VaryingsDefault

           sampler2D(_MainTex);
           sampler2D(_Gradient);
           sampler2D(_GlobalScreenSpaceShadows);

           half _Mix;
           half3 _SunDirection;
           half4 _GlobalLightColor;
            half3 frag (v2f i) : SV_Target
            {
               half3 mainTex=tex2D(_MainTex,i.texcoord);
                half4 gradient = tex2D(_Gradient,i.texcoord)* _GlobalLightColor;
              half3 shadowColor= lerp(mainTex,gradient.rgb*mainTex,gradient.a);
                shadowColor=lerp(shadowColor,gradient.rgb,_Mix*gradient.a);
                half shadow =tex2D(_GlobalScreenSpaceShadows,i.texcoord).r;
                half3 finalMix= lerp(shadowColor,mainTex,shadow);
                int ready =step(0.001,abs(_SunDirection.x+_SunDirection.y+_SunDirection.z));
                return finalMix*ready+mainTex*(1-ready);
            }
    ENDHLSL
    
    SubShader
    {
        Cull Off
         ZWrite On
         ZTest Always
    
        Pass
        {
           HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment frag

          ENDHLSL
        }
    }
}
