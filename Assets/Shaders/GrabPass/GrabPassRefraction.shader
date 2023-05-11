Shader "Custom/GrabPassRefraction"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normal",2D)="bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Occlusion("Occlusion",Range(0,1))=0.5
        _Distortion("Distortion",Range(0,1))=0.3
        [Space]
        [Header(Rim)]
        [HDR]_RimColor("Rim Color",Color)=(0,0,0,0)
        _RimPower("Rim Fill",Range(0,2))=0.3
        _RimSmoothness("Rim Smoothness",Range(0.5,1))=0.4
        _SideRimSize("Side Rim",Range(0,1))=0.5
        [Space]
        [Header(Highlights)]
        [HDR]_GlossColor("Gloss color",Color)=(0, 1, 0.9897847, 1)
        _GlossSize("Gloss size",Range(0,1))=0.5
        _GlossSmoothness("Gloss smoothness",Range(0,1))=0.6
        [Space]
        [Header(Shadow)]
        _Threshold("Shadow threshold",Range(0,2))=0.3
        _ShadowColor("Shadow color",Color)=(0,0,0,1)
        _ShadowSmoothness("Shadow smoothness",Range(0.5,1))=0.6
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
//        Pass{
//        ZWrite On
//        ColorMask A
//        }
        GrabPass{}
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf StandardGlass 
        #include "UnityPBSLighting.cginc"
        #pragma target 3.0
        #define EPSILON 1.19204590e-07
        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _GrabTexture;

        struct Input
        {
            float2 uv_MainTex;
            float3 uv_bumpMap;
            float3 viewDir;
            float4 screenPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        half _Occlusion;
        half _RimPower;
        half _RimSmoothness;
        half _Distortion;
        half _ShadowSmoothness;
        half _Threshold;
        half3 _ShadowColor;
        half _GlossSmoothness;
        half _GlossSize;
        half3 _GlossColor;
        half _SideRimSize;
        half3 _RimColor;
        half3 grabColor;

        inline half4 LightingStandardGlass(SurfaceOutputStandard s,half3 viewDir,UnityGI gi)
        {
            half3 color = max(_ShadowColor* s.Albedo, s.Albedo *(1-s.Metallic));
            color*= gi.indirect.diffuse;
            color=lerp(grabColor,color,s.Alpha);
            half3 final = color +gi.indirect.specular;
            return  half4(final,1);
        }
        inline void LightingStandardGlass_GI(SurfaceOutputStandard s,UnityGIInput data,inout UnityGI gi)
        {
            half shadowDot = pow(dot(s.Normal,data.light.dir)*0.5+0.5,_Threshold);
            shadowDot =smoothstep(0.5,_ShadowSmoothness,shadowDot);
            
            gi= UnityGI_Base(data,s.Occlusion,s.Normal);
            gi.light.color= lerp(_ShadowColor,gi.light.color,shadowDot*data.atten);
            gi.indirect.diffuse+=gi.light.color;
            
            half3 reflectionDir = reflect(-data.worldViewDir,s.Normal);
            half mip= (1-s.Smoothness)* UNITY_SPECCUBE_LOD_STEPS;
            half4 rgbm= UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0,reflectionDir,mip);
            gi.indirect.specular= DecodeHDR(rgbm,unity_SpecCube0_HDR).rgb*s.Occlusion;
            gi.indirect.specular *= max(0.25, gi.indirect.diffuse);
            
            half3 halfDir= normalize(gi.light.dir+data.worldViewDir);
            half glossSize= lerp(20,EPSILON,_GlossSize);
            half halfDot= pow(dot(normalize(s.Normal),halfDir),glossSize);
            half glossDot = smoothstep(0.5,max(0.5,halfDot+_GlossSmoothness/glossSize *2),halfDot);
            half3 glossColor= lerp(_GlossColor,s.Albedo,s.Metallic);
            gi.indirect.specular+= glossDot*glossColor *unity_ColorSpaceDouble;
            
            half glossPower = max(0, GGXTerm(pow(dot(normalize(s.Normal), halfDir), 5), 0.2));
		    gi.indirect.specular += glossPower * s.Smoothness;
            half viewDot = dot(data.worldViewDir,s.Normal);
            half lightDot = exp2(saturate(dot(gi.light.dir, halfDir))) * _SideRimSize * 20;
		half sideRim = saturate(pow((1 - shadowDot), 5) * pow((1 - viewDot), 5) * lightDot);
		gi.indirect.specular += sideRim * _RimColor;
            
        }
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Normal = UnpackNormal(tex2D(_BumpMap,IN.uv_MainTex));
            
            half2 distortion = lerp(float2(1,1),exp2(o.Normal).xy,_Distortion);
            fixed2 screenUV = IN.screenPos.xy/max(EPSILON,IN.screenPos.w)*distortion;
             grabColor = tex2D(_GrabTexture,screenUV);
            
            o.Albedo=c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            o.Occlusion = _Occlusion;
            
            half rimDot = 1-pow(dot(o.Normal,IN.viewDir),_RimPower);
            half rim = smoothstep(0.5,max(0.5,_RimSmoothness),rimDot);
            o.Emission = rim*_RimColor;
            
        }
        ENDCG
    }
    FallBack "Diffuse"
}
