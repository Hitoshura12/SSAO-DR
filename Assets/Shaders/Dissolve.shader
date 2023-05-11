Shader "Custom/Dissolve" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _DissolveMap ("Dissolve Map", 2D) = "white" {}
        _DissolveAmount ("Dissolve Amount", Range(0.0, 1.0)) = 0.0
    }
 
    SubShader {
        Tags {"Queue"="Transparent" "RenderType"="Opaque"}
        LOD 100
         
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
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
            sampler2D _DissolveMap;
            float _DissolveAmount;
             
            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
             
            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                float dissolve = tex2D(_DissolveMap, i.uv).a;
                dissolve = step(dissolve, _DissolveAmount);
                col.a *= dissolve;
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
