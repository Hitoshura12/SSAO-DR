Shader "Custom/UIScroll"
{
    Properties
    {
      [PerRendererData]  _MainTex ("Texture", 2D) = "white" {}
        _PatternTex("Pattern ",2D) = "white"{}
        _ScrollX("Scroll X",Range(-1,1))=0.4
        _ScrollY("Scroll Y",Range(-1,1))=0.4
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
        LOD 100

        Blend  SrcAlpha OneMinusSrcAlpha
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
                float4 color: COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                half4 color:COLOR;
                half2 patternUV: TEXCOORD1;
                
            };

            sampler2D _MainTex,_PatternTex;
            float4 _MainTex_ST, _PatternTex_ST;
            float _ScrollX,_ScrollY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color=v.color;
                o.patternUV=TRANSFORM_TEX(v.uv,_PatternTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                half2 offset = frac(_Time.y*float2(_ScrollX,_ScrollY));
                fixed4 pattern=tex2D(_PatternTex,i.patternUV+offset);
               
                return col*i.color*pattern;
            }
            ENDCG
        }
    }
}
