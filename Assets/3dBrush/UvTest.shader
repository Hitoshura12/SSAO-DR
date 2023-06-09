﻿Shader "Unlit/UvTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BrushColor("Brush color", Color) = (1,.5,.5,1)
		_BrushSize("Brush size", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
		Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BrushPos;
            fixed4 _BrushColor;
            float _BrushSize;
			

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = float4(v.uv.x-0.5, -v.uv.y+0.5, 0, 0.5);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				float dist = distance(i.worldPos, float4(_BrushPos.xyz, 1));
				fixed t = smoothstep(0,_BrushSize,dist);
				col = lerp(_BrushColor, col, t);
                return col;
            }
            ENDCG
        }
    }
}
