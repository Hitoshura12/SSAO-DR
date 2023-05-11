Shader "Unlit/BeatMusic"
{
    Properties
    {
        _Color("Color",Color)=(1,1,1,1)
        _BackgroundColor("Color",Color)=(0,0,0,1)
        _Radius("Radius",Range(0,1))=0.5
        _Smooth("Smoothing",Range(0,0.05))=0.01

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "PreviewType"="Plane"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };


            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                return o;
            }

            half _Radius, _Smooth;
            half4 _Color, _BackgroundColor;
            float _GlobalRMS;

            half4 frag(v2f i) : SV_Target
            {
                float d = distance(i.uv, half2(0.5, 0.5));
                half blend = smoothstep(d - _Smooth, d + _Smooth, _Radius+_GlobalRMS);
                return lerp(_BackgroundColor, _Color, blend);
            }
            ENDCG
        }
    }
}