Shader "Custom/Cutout"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Float) = 1
		[HDR] _EmissionColor("Emission Color",Color)=(0,0,0,1)
		_EmissionMap("Emission map",2D)="white"{}
    	[HDR] _RimColor("RimColor",Color)=(1,1,1,1)
    	_RimPower("Rim Power",Range(0,2))=0.4
    	_RimSmoothing("Rim Smoothing",Range(0.5,1))=1
    	_Threshold("Light Threshold",Range(0,2))=0.5
    	_ShadowSmoothness("Shadow Smoothness",Range(0,1))=0.5
    	_ShadowColor("Shadow Color", Color) = (0,0,0,1)
    	_Cutout("Cutout threshold",Range(0,1))=0.5
    	
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Toon fullforwardshadows
        #pragma target 3.0
       

        sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _EmissionMap;
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
        half _Cutout;
        
			half4 LightingToon( SurfaceOutput s, half3 lightDir,half atten)
	        {
        		half d = pow(dot(s.Normal,lightDir)*0.5+0.5,_Threshold) ; //NDOTL
        		half4 c;
				half shadow = smoothstep(0.5,_ShadowSmoothness,d);
				half3 shadowColor = lerp(_ShadowColor,half3(1,1,1),shadow);
        		c.rgb= s.Albedo*d* _LightColor0.rgb * atten *shadowColor;
        		c.a = s.Alpha;
		        return c;
	        }
        void surf (Input IN, inout SurfaceOutput o)
        {
        	float d = 1-pow(dot(o.Normal,IN.viewDir),_RimPower);
			half4 tex= tex2D(_MainTex,IN.uv_MainTex);
			o.Albedo = tex.rgb * _Color;
			o.Alpha = tex.a;
			clip(tex.a-_Cutout);	
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
			o.Normal.z *= _NormalStrength;
        	o.Emission= _EmissionColor*tex2D(_EmissionMap,IN.uv_MainTex);
			o.Emission+=_RimColor *smoothstep(0.5,max(0.5,_RimSmoothing),d);
        }
        ENDCG
    }
    FallBack "Diffuse"
}