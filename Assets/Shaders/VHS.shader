//Shader "Custom/VHS" {
//    Properties {
//        _MainTex ("Texture", 2D) = "white" {}
//        _Distortion ("Distortion", Range(0,1)) = 0.1
//        _ScanlineStrength ("Scanline Strength", Range(0,1)) = 0.1
//        _NoiseStrength ("Noise Strength", Range(0,1)) = 0.1
//        _NoiseSpeed ("Noise Speed", Range(0,1)) = 0.1
//    }
//    SubShader {
//        Tags { "RenderType"="Opaque" }
//        LOD 100
//        Pass {
//            CGPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//            #include "UnityCG.cginc"
//            
//            struct appdata {
//                float4 vertex : POSITION;
//                float2 uv : TEXCOORD0;
//            };
//            
//            struct v2f {
//                float2 uv : TEXCOORD0;
//                float4 vertex : SV_POSITION;
//            };
//            
//            sampler2D _MainTex;
//            float _Distortion;
//            float _ScanlineStrength;
//            float _NoiseStrength;
//            float _NoiseSpeed;
//            
//            v2f vert (appdata v) {
//                v2f o;
//                o.vertex = UnityObjectToClipPos(v.vertex);
//                o.uv = v.uv;
//                return o;
//            }
//            
//            float4 frag (v2f i) : SV_Target {
//                float2 uv = i.uv;
//                float4 color = tex2D(_MainTex, uv);
//                
//                // Distortion effect
//                float2 offset = float2(
//                    sin(uv.y * 100.0 * _Distortion + _Time.y * _NoiseSpeed),
//                    cos(uv.x * 100.0 * _Distortion + _Time.y * _NoiseSpeed)
//                ) * _Distortion * 0.1;
//                uv += offset;
//                
//                // Scanlines effect
//                float scanline = abs(sin(uv.y * 100.0)) * _ScanlineStrength;
//                color.rgb -= scanline;
//                
//                // Noise effect
//                float noise = (tex2D(_MainTex, uv * 100.0 + _Time.y * _NoiseSpeed) - 0.5) * _NoiseStrength;
//                color.rgb += noise;
//                
//                return color;
//            }
//            ENDCG
//        }
//    }
//}
Shader "Custom/VHS with Color Bleeding" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Distortion ("Distortion", Range(0,1)) = 0.1
        _ScanlineStrength ("Scanline Strength", Range(0,1)) = 0.1
        _NoiseStrength ("Noise Strength", Range(0,1)) = 0.1
        _NoiseSpeed ("Noise Speed", Range(0,1)) = 0.1
        _ColorBleedAmount ("Color Bleed Amount", Range(0,1)) = 0.1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            float _Distortion;
            float _ScanlineStrength;
            float _NoiseStrength;
            float _NoiseSpeed;
            float _ColorBleedAmount;
            
            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            float4 frag (v2f i) : SV_Target {
                float2 uv = i.uv;
                float4 color = tex2D(_MainTex, uv);
                
                // Distortion effect
                float2 offset = float2(
                    sin(uv.y * 100.0 * _Distortion + _Time.y * _NoiseSpeed),
                    cos(uv.x * 100.0 * _Distortion + _Time.y * _NoiseSpeed)
                ) * _Distortion * 0.1;
                uv += offset;
                
                // Scanlines effect
                float scanline = abs(sin(uv.y * 100.0)) * _ScanlineStrength;
                color.rgb -= scanline;
                
                // Noise effect
                float noise = (tex2D(_MainTex, uv * 100.0 + _Time.y * _NoiseSpeed) - 0.5) * _NoiseStrength;
                color.rgb += noise;
                
                // Color bleeding effect
                float4 adjacentColors = (
                    tex2D(_MainTex, uv + float2(-0.005, 0)) +
                    tex2D(_MainTex, uv + float2(0.005, 0)) +
                    tex2D(_MainTex, uv + float2(0, -0.005)) +
                    tex2D(_MainTex, uv + float2(0, 0.005))
                ) * 0.5;
                color.rgb += (adjacentColors.rgb - color.rgb) * _ColorBleedAmount;
                
                return color;
            }
            ENDCG
        }
    }
}
