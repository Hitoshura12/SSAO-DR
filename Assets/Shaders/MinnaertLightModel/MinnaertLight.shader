Shader "Taka/Custom/MinnaertLight"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normal map",2D)="bump"{}
        _SpecGlossMap("Specular Map",2D)="white"{}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic("Metallic",Range(0,1))=0.0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Minnaert
        #include "UnityPBSLighting.cginc"


        struct Input
        {
            float2 uv_MainTex;
        };

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _SpecGlossMap;
        half _Glossiness;
        half _Metallic;
        half4 _Color;

        half Minnaert(half3 normal,half3 lightDir,half3 viewDir,half atten)
        {
            half ndotL= dot(normal,lightDir);
            half ndotV = dot(normal,viewDir);
            return saturate(ndotL*pow(ndotL*ndotV,1-atten)*atten);
        }

        inline half4 LightingMinnaert(SurfaceOutputStandard s, float3 viewDir, UnityGI gi)
        {

            return LightingStandard(s, viewDir, gi);
        }

        void LightingMinnaert_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            half3 lightColor = gi.light.color;
            LightingStandard_GI(s, data, gi);
            gi.light.color = lightColor* Minnaert(s.Normal,gi.light.dir,data.worldViewDir,data.atten);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            half4 shiny = tex2D(_SpecGlossMap, IN.uv_MainTex);
            o.Smoothness = _Glossiness * shiny.r;
            o.Metallic = _Metallic;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}