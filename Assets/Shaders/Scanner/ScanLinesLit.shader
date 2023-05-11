Shader "Custom/ScanLinesLit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        [HDR] _ScanColor("ScanLine Color",Color)=(1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Speed("Speed",Range(0,4))=1
        _Height("Height",Range(0,1024))=4
        _Metallic("Metallic",Range(0,1))=0.3
        _Glossiness("Glossiness",Range(0,1))=0.5
        _RimPower("Rim Power",Range(0,2))=1
        _RimSoftness("Rim Softness",Range(0,1))=0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float4 screenPos;
            float3 viewDir;
        };

        half _Speed;
        half _Metallic;
        half _Glossiness;
     half4 _Color;
        half _Height;
        half4 _ScanColor;
        half _RimPower;
        half _RimSoftness;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
         half4 mainTex= tex2D(_MainTex,IN.uv_MainTex);
            float2 screenPos= IN.screenPos.y/IN.screenPos.w;
            half scroll = sin(_Time.y*_Speed);
            float scanline= sin((screenPos-scroll)*_Height)*0.5+0.5;
            o.Albedo= lerp(mainTex,mainTex*_Color.rgb,_Color.a*scanline);
            half rim = smoothstep(0.5,max(0.5,_RimSoftness),1-pow(dot(o.Normal,IN.viewDir),_RimPower));
            o.Emission = scanline*_ScanColor*mainTex.rgb*rim;
       
            o.Metallic=_Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
