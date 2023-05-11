Shader "Unlit/SpriteMaskShader"
{
    Properties
    {
       [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _Mask("Mask",2D)="transparent"{}
        _R("Red Color",Color)=(1,0,0,1)
        _G("Green Color",Color)=(0,1,0,1)
        _B("Blue Color",Color)=(0,0,1,1)
        _A("Alpha Color",Color)=(1,1,1,1)
        [Enum(Off,0,Front,1,Back,2)]_Cull("Cull",float)=2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "IgnoreProjector"="True"
             "Queue"="Transparent" "PreviewType"="Plane"
             "CanUseSpriteAtlas"="True" }
        LOD 100
        Cull [_Cull]
        Blend SrcAlpha OneMinusSrcAlpha
        //ZTest Off
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
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Mask;
            float4 _R;
            float4 _G;
            float4 _B;
            float4 _A;
          //  float4 _Color;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 col = tex2D(_MainTex, i.uv)* i.color;
                half4 mask = tex2D(_Mask,i.uv);
                half4 mix= half4(0,0,0,1);
                mix=lerp(mix,_R,mask.r);
                mix=lerp(mix,_G,mask.g);
                mix= lerp(mix,_B,mask.b);
                mix=lerp(mix,_A,1-mask.a);
                col=col*mix;
                return col;
            }
            ENDCG
        }
    }
}
