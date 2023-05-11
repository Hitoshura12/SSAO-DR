Shader "Custom/ChromaticSplit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RedOffset("R Offset",Vector)=(0,0,0,0)
        _GreenOffset("G Offset",Vector)=(0,0,0,0)
        _BlueOffset("B Offset",Vector)=(0,0,0,0)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
            float4 _MainTex_ST;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            sampler2D _MainTex;
            float2 _RedOffset,_GreenOffset,_BlueOffset;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed r= tex2D(_MainTex,i.uv+_RedOffset).r;
                fixed g= tex2D(_MainTex,i.uv+_GreenOffset).g;
                fixed b= tex2D(_MainTex,i.uv+_BlueOffset).b;
                // just invert the colors
                col =fixed4(r,g,b,1);
                return col;
            }
            ENDCG
        }
    }
}
