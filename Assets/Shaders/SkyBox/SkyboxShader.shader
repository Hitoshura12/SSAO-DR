Shader "Unlit/SkyboxShader"
{
    Properties
    {
        _TopColor("Top Color",Color)=(0,0,0,0)
        _BottomColor("BottomColor",Color)=(0,0,0,0)
        _Offset("Offset Skybox",Range(-1,1))=0.2
        _Smoothness("Smoothness",Range(0,1))=0.3
    }
    SubShader
    {
        Tags { "RenderType"="Background" "Queue"="Background" "PreviewType"="Skybox" }
        ZWrite Off
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            half3 _TopColor;
            half3 _BottomColor;
            half _Offset;
            half _Smoothness;
            fixed3 frag (v2f i) : SV_Target
            {
                // sample the texture
                float uvpos= (i.uv.y-_Offset)*2-1;
                half blend = smoothstep(0,_Smoothness*10,uvpos);
                fixed3 finalCol = lerp(_BottomColor,_TopColor,blend);
                return finalCol;
            }
            ENDCG
        }
    }
}
