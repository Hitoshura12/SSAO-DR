Shader "Taka/Unlit/AlphaDraw"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Line ("Line",Range(0,1))=0.5
        _Color("Color",Color)=(1,1,1,1)
        _Speed("Speed",Range(-2,2))=1
        _FallOff("FallOff",Range(0,0.1))=0.1
        [Toggle(MANUAL)]
        _Manual("Manual line progress",float)=0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"
            "Queue"="Transparent"
            "PreviewType"="Plane" }
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local MANUAL
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;

                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;
            half _Line;
            half _FallOff;
            half _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 mask = tex2D(_MainTex, i.uv);
                #ifdef MANUAL
                half lineTime = _Line;
                #else
                half lineTime= frac(sin(_Time.y*_Speed)*0.5+0.5);
                #endif
                half progress=saturate(smoothstep(mask.r-_FallOff,mask.r+_FallOff,lineTime));
                half4 col = lerp(0,_Color,progress*mask.a);
                return col;
            }
            ENDCG
        }
    }
}
