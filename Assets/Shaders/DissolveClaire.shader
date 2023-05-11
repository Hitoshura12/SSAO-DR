Shader "Custom/DissolveClaire"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normal", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Float) = 1
        [Space]
        [Header(Emission)]
        [HDR] _EmissionColor("Emission Color",Color)=(0,0,0,1)
        _EmissionMap("Emission map",2D)="white"{}

        [Space]
        [Header(RimFresnel)]
        [HDR] _RimColor("RimColor",Color)=(1,1,1,1)
        _RimPower("Rim Power",Range(0,2))=0.4
        _RimSmoothing("Rim Smoothing",Range(0.5,1))=1
        _Threshold("Light Threshold",Range(0,2))=0.5
        _ShadowSmoothness("Shadow Smoothness",Range(0,1))=0.5
        _ShadowColor("Shadow Color", Color) = (0,0,0,1)
        [Space]
        [Header(Dissolve Params)]
        _DissolveMap("Dissolve Map",2D)="white"{}
        _DissolveAmount("Amount",Range(0,1))=0.4
        _DissolveScale("Scale",Range(0,5))=2
        _DissolveLine("Line thickness",Range(0,0.2))=0.2
        [HDR]_DissolveLineColor("Dissolve Color",Color)=(0,1,1,1)
        [Space]
        [Header(Glossiness)]
        _Glossiness("Glossiness",Range(0,20))= 0.4
        [HDR]_GlossColor("Gloss Color",Color)=(1,1,1,1)
        _GlossSmoothness("Smoothness",float)=0.4
        _SpecularMap("Specular Map",2D)="white"{}

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Toon fullforwardshadows
        #pragma target 3.0
        #pragma enable_d3d11_debug_symbols


        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _EmissionMap;
        sampler2D _SpecularMap;
        sampler2D _DissolveMap;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
        };

        fixed4 _Color;
        float _NormalStrength;
        half4 _EmissionColor;
        half4 _ShadowColor;
        half4 _RimColor;
        float _RimPower;
        float _RimSmoothing;
        float _Threshold;
        float _ShadowSmoothness;
        half _DissolveAmount;
        half _DissolveScale;
        half _DissolveLine;
        half _Glossiness;
        half _GlossSmoothness;
        half3 _DissolveLineColor;
        half3 _GlossColor;
        


        half4 LightingToon(SurfaceOutput s, half3 lightDir,half viewDir, half atten)
        {
            half d = pow(dot(s.Normal, lightDir) * 0.5 + 0.5, _Threshold);
            half4 c;
            half shadow = smoothstep(0.5, _ShadowSmoothness, d);
            half3 shadowColor = lerp(_ShadowColor, half3(1, 1, 1), shadow);
            c.rgb = s.Albedo * d * _LightColor0.rgb * atten * shadowColor;
            c.a = s.Alpha;
            half halfDir= normalize(lightDir+viewDir);
            half halfDot =pow(dot(s.Normal,halfDir),_Glossiness);
            half gloss = smoothstep(0.5,max(0.5,_GlossSmoothness),halfDot)*s.Specular;
            c.rgb = lerp(c.rgb,_GlossColor*_LightColor0.rgb,gloss);
            return c;
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            float d = 1 - pow(dot(o.Normal, IN.viewDir), _RimPower);
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
            o.Normal.z *= _NormalStrength;
            float4 dissolve = tex2D(_DissolveMap, IN.uv_MainTex * _DissolveScale);
            clip(dissolve.r - _DissolveAmount);
            o.Emission = _EmissionColor * tex2D(_EmissionMap, IN.uv_MainTex);
            o.Emission += _RimColor * smoothstep(0.5, max(0.5, _RimSmoothing), d);
            o.Emission += step(dissolve.r, _DissolveAmount + _DissolveLine) * _DissolveLineColor;
            half specMap= tex2D(_SpecularMap,IN.uv_MainTex).r;
            o.Specular = specMap;
        }
        ENDCG
    }
    FallBack "Diffuse"
}