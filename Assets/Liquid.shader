Shader "Custom/Liquid" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _WaveSpeed ("Wave Speed", Range(0, 10)) = 1
        _DistortionStrength ("Distortion Strength", Range(0, 1)) = 0.5
        _DistortionScale ("Distortion Scale", Range(0, 1)) = 0.5
    }
 
    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Opaque"}
        LOD 100
 
        CGPROGRAM
        #pragma surface surf Standard vertex:vert
        #include "UnityCG.cginc"
 
        sampler2D _MainTex;
        sampler2D _BumpMap;
        float _WaveSpeed;
        float _DistortionStrength;
        float _DistortionScale;
 
        struct Input {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 worldPos;
            float3 worldNormal;
        };
 
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.worldPos = v.vertex.xyz;
            o.worldNormal = v.normal;
        }
 
        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Calculate the wave distortion based on time and the world position
            float3 distortion = _DistortionStrength * tex2D(_BumpMap, IN.uv_BumpMap * _DistortionScale + _Time.y * _WaveSpeed).rgb - 0.5;
 
            // Offset the world position based on the distortion
            float3 worldPos = IN.worldPos + distortion;
 
            // Sample the texture using the distorted world position
            o.Albedo = tex2D(_MainTex, worldPos.xz * 0.1 + _Time.y * _WaveSpeed * 0.1).rgb;
            o.Metallic = 0;
            o.Smoothness = 0.5;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap * _DistortionScale + _Time.y * _WaveSpeed)).rgb;
        }
        ENDCG
    }
}
