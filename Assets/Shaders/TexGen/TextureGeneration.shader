Shader "Unlit/TextureGeneration"
{
    Properties
    {
         _Tex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _TexNormal("Tex Normal",2D)="bump"{}
        _BlendTex ("Blend Tex",2D)="white"{}
         [NoScaleOffset] _BlendNormal("Blend Normal",2D)="bump"{}
        _Mask("Mask Tex",2D)="white"{}
        _BlendPower("Blend power",Range(0,2))=0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "PreviewType"="Plane" }
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        
        CGINCLUDE
            #pragma vertex vert
        
            #include "UnityCG.cginc"
            #include "TexGen.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
     
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 packedUV : TEXCOORD0;
                float2 maskUV: TEXCOORD1;
            };
            
            float4 _Tex_ST;
            float4 _BlendTex_ST;
            float4 _Mask_ST;
      

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.packedUV.xy = TRANSFORM_TEX(v.uv, _Tex);
                o.packedUV.zw= TRANSFORM_TEX(v.uv,_BlendTex);
                o.maskUV= TRANSFORM_TEX(v.uv,_Mask);
                return o;
            }

            fixed4 FragAlbedo (v2f i) : SV_Target
            {
              return Mix2(i.packedUV.xy,i.packedUV.zw,i.maskUV);
            }
            float4 FragNormal(v2f i):SV_Target
            {
                float3 normal =MixNormal(i.packedUV.xy,i.packedUV.zw,i.maskUV);
                return float4(RepackNormal(normal),1);
            }
        ENDCG
        
        Pass
        {
            CGPROGRAM
            #pragma fragment FragAlbedo
            ENDCG
        }
        Pass
        {
        CGPROGRAM
        #pragma fragment FragNormal
        ENDCG
        }
    }
}
