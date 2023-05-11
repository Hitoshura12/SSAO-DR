Shader "Taka/Unlit/ColorBlendMask"
{
    Properties
    {
       [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
        _Color1("Color1",Color)=(1,1,1,1)
        _Color2("Color2",Color)=(1,1,1,1)
        _Color3("Color3",Color)=(1,1,1,1)
        _Blend1("BlendColor 1",Color)=(1,1,1,1)
        _Blend2("BlendColor 2",Color)=(1,1,1,1)
        _Blend3("BlendColor 3",Color)=(1,1,1,1)
        
        _Speed("Speed",Vector)=(0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"
             "Queue"="Transparent" 
            "CanUseSpriteAtlas"="true"
             "IgnoreProjector"="true" }
        Blend SrcAlpha OneMinusSrcAlpha

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
                half4 color: COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                half4 color: COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half4 _Speed;
            half4 _Color1,_Color2,_Color3;
            half4 _Blend1,_Blend2,_Blend3;
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                 v.uv.x+=frac(_Time.x+_Speed.w);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
               
                o.color=v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 mask = tex2D(_MainTex, i.uv);
                half4 col=half4(0,0,0,0);
                half4 r= lerp(_Color1,_Blend1,sin(_Time.x*_Speed.r)*0.5+0.5);
                half4 g = lerp(_Color2,_Blend2,sin(_Time.x*_Speed.g)*0.5+0.5);
                half4 b = lerp(_Color3,_Blend3,sin(_Time.x*_Speed.b)*0.5+0.5);
                col+=mask.r*r;
                col+=mask.g*g;
                col+=mask.b*b;
                col*=mask.a;
                
                return col* i.color;
            }
            ENDCG
        }
    }
}
