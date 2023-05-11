Shader "Xibanya/XibStandard"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normal", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Float) = 1
        [HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
        _EmissionMap("Emission Tex", 2D) = "white" {}
        [HDR]_RimColor("Rim Color", Color) = (1,1,1,1)
        _RimPower("Rim Fill", Range(0, 2)) = 0.1
        _RimSmooth("Rim Smoothness", Range(0.5, 1)) = 1
        _Glossiness("Smoothness",Range(0,1))=0.5
        _Metallic("Metallic",Range(0,1))=0.4
        _MetallicGlossMap("Shiny Map",2D)="white"{}
        _OcclusionMap("Occlusion Map",2D)="white"{}
        _OcclusionPower("AO strength",Range(0,1))=0.5
        _SpecGlossMap("Secondary Shiny Map",2D)="white"{}
        [KeywordEnum(None,FirstA,AlbedoA,FirstR,SecondR)]_SMOOTH("Smoothenss source",float)=0
        [Toggle]_ROUGHNESS("Rough or Smooth?",float)=0
        [KeywordEnum(None,FirstR,FirstG)]_METALLIC("Metallic source?",float)=0
        [KeywordEnum(None,AO,FirstB,FirstG,AlbedoA)]_AO("Ambient Occlusion?",float)=0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0
        #pragma multi_compile_local __ _SMOOTH_FIRSTA _SMOOTH_ALBEDOA _SMOOTH_FIRSTR _SMOOTH_SECONDR
        #pragma multi_compile_local __ _ROUGHNESS_ON
        #pragma multi_compile_local _METALLIC_NONE _METALLIC_FIRSTR _METALLIC_FIRSTG
        #pragma multi_compile_local _AO_NONE _AO_FIRSTB _AO_FIRSTG _AO_ALBEDOA

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _EmissionMap;
        sampler2D _MetallicGlossMap;
        sampler2D _OcclusionMap;
        sampler2D _SpecGlossMap;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
        };

        fixed4 _Color;
        float _NormalStrength;
        half4 _EmissionColor;
        half4 _RimColor;
        half _RimPower;
        half _RimSmooth;
        half _Glossiness;
        half _Metallic;
        half _OcclusionPower;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
        	half4 mainTex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = mainTex.rgb * _Color;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            o.Normal.z *= _NormalStrength;
            o.Emission = _EmissionColor * tex2D(_EmissionMap, IN.uv_MainTex) * o.Albedo;
            half d = 1 - pow(dot(o.Normal, IN.viewDir), _RimPower);
            o.Emission += _RimColor * smoothstep(0.5, max(0.5, _RimSmooth), d);
            #if defined(_SMOOTH_FIRSTA) || defined(_SMOOTH_FIRSTR) || !defined(_METAL_NONE) || \
			defined(_AO_FIRSTB) || defined(_AO_FIRSTG)
			half4 metallicMap = tex2D(_MetallicGlossMap, IN.uv_MainTex);
			#endif
            //o.Smoothness= metallicMap.a* _Glossiness;
            fixed4 AOMap = tex2D(_OcclusionMap, IN.uv_MainTex);

            half smooth = 1;
            #ifdef _SMOOTH_FIRSTA
				smooth = metallicMap.a;
            #elif _SMOOTH_ALBEDOA
        		smooth = mainTex.a;
            #elif _SMOOTH_FIRSTR
        	smooth = metallicMap.r;
            #elif _SMOOTH_SECONDR
        	smooth = tex2D(_SpecGlossMap,IN.uv_MainTex).r;
            #endif
            #ifdef _ROUGHNESS_ON
				smooth = 1-smooth;
            #endif
            #ifdef _METALLIC_FIRSTR
        	o.Metallic = metallicMap.r *_Metallic;
            #elif _METALLIC_FIRSTG
        	o.Metallic = metallicMap.g *_Metallic;
            #endif
            o.Smoothness = smooth * _Glossiness;
            half occlusion = 1;
            #ifdef _AO
        	occlusion = AOMap.g;
            #elif _AO_FIRSTB
        	occlusion = metallicMap.b;
            #elif _AO_FIRSTG
        	occlusion = metallicMap.g;
            #elif _AO_ALBEDOA
        	occlusion = mainTex.a;
            #endif
            #if(SHADER_TARGET<30|| defined(_AO_NONE))
            o.Occlusion = occlusion * _OcclusionPower;
            #else
        	o.Occlusion = (1-_OcclusionPower)+ occlusion*_OcclusionPower;
            #endif
        }
        ENDCG
    }
    FallBack "Diffuse"
}