Shader "Custom/EmissionMappedClaire"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Float) = 1
		[HDR] _Emission1("Emission Color",Color)=(0,0,0,1)
    	[HDR] _Emission2("Emission Color",Color)=(0,0,0,1)
    	[HDR] _Emission3("Emission Color",Color)=(0,0,0,1)
		_EmissionMap("Emission map",2D)="white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _EmissionMap;
        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;
		float _NormalStrength;
        half4 _Emission1;
        half4 _Emission2;
        half4 _Emission3;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
			o.Normal.z *= _NormalStrength;
        	half4 emissionMap = tex2D(_EmissionMap,IN.uv_MainTex);
        	half4 color1 = _Emission1*emissionMap.r;
        	half4 color2 = _Emission2*emissionMap.g;
        	half4 color3 = _Emission3*emissionMap.b;
        	o.Emission = color1+ color2+color3;
        	
        }
        ENDCG
    }
    FallBack "Diffuse"
}