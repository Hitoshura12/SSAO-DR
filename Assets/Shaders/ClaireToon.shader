﻿Shader "Custom/ClaireToon"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Float) = 1
		[HDR]_EmissionColor("Emission Color", Color) = (0,0,0,1)
		_EmissionMap("Emission Tex", 2D) = "white" {}
		[HDR]_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimPower("Rim Fill", Range(0, 2)) = 0.1
		_RimSmooth("Rim Smoothness", Range(0.5, 1)) = 1
		_Thresh("Shadow Threshold", Range(0,2)) = 1
		_ShadowSmooth("Shadow Smoothness", Range(0.5, 1)) = 0.6
		_ShadowColor("Shadow Color", Color) = (0,0,0,1)
		[Space]
		[Header(Gloss)]
		_SpecMap("Spec Map", 2D) = "white" {}
		_Gloss("Glossiness", Range(0,20)) = 0
		_GlossSmoothness("Gloss Smoothness", Range(0,2)) = 0
		[HDR]_GlossColor("Gloss Color", Color) = (1,1,1,1)
		[Space]
		[Header(Outline)]
		_Outline("Outline",Range(0,0.05))=0.02
		[HDR] _OutlineColor("Outline Color",Color)=(0,1,1,1)
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 200
			Cull front
			CGPROGRAM
			#pragma surface surf Toon fullforwardshadows vertex:OutlineVertex
			#pragma target 3.0
		#include "ClaireCommon.cginc"
			
		   half _Outline;
			struct Input
			{
				float2 uv_MainTex;
				float3 color;
			};
			half4 _OutlineColor;
			void OutlineVertex(inout appdata_full v)
			{
				v.color = _OutlineColor;
				v.vertex.xyz +=v.normal*_Outline*_OutlineColor;
			}

			void surf(Input IN, inout SurfaceOutput o)
			{
				o.Emission= Black;
			}
			ENDCG
			Cull back
			//Second shader
			CGPROGRAM
			#include "ClaireCommon.cginc"
			#pragma surface surf Toon
			
			half _Thresh;
			half _ShadowSmooth;
			half3 _ShadowColor;
			half _Gloss;
			half3 _GlossColor;
			half _GlossSmoothness;
			half _Outline;
			fixed4 _Color;
			float _NormalStrength;
			half4 _EmissionColor;
			half4 _RimColor;
			half _RimPower;
			half _RimSmooth;
			
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _EmissionMap;
			sampler2D _SpecMap;

			struct Input
			{
				float2 uv_MainTex;
				float3 viewDir;
			};
			void surf(Input IN, inout SurfaceOutput o)
			{
				InitLightingToon(_Thresh,_ShadowSmooth,_ShadowColor,_Gloss,_GlossSmoothness,_GlossColor);
				o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
				o.Normal.z *= _NormalStrength;
				o.Emission = _EmissionColor * tex2D(_EmissionMap, IN.uv_MainTex) * o.Albedo;
				half d = 1 - pow(dot(o.Normal, IN.viewDir), _RimPower);
				o.Emission += _RimColor * smoothstep(0.5, max(0.5, _RimSmooth), d);
				o.Specular = tex2D(_SpecMap, IN.uv_MainTex).r;
			}
		ENDCG			
}
	FallBack "Diffuse"
}
