#ifndef TEXTURE_GENERATION_LIBRARY_INCLUDED
#define TEXTURE_GENERATION_LIBRARY_INCLUDED
#endif

#include "UnityStandardUtils.cginc"
#include "UnityCG.cginc"
sampler2D _Tex,_TexNormal;
sampler2D _BlendTex,_BlendNormal;
sampler2D _Mask;
half _BlendPower;

half4 Mix2(float2 uv1,float2 uv2,float2 uvMask)
{

    half4 tex = tex2D(_Tex, uv1);
    half4 blend= tex2D(_BlendTex,uv2);
    half mask = saturate(pow(tex2D(_Mask,uvMask).r,_BlendPower));
    return lerp(tex,blend,mask);
    
}

float3 MixNormal(float2 uv1,float2 uv2,float2 uvMask)
{
    half mask = saturate(pow(tex2D(_Mask,uvMask).r,_BlendPower));
    float3 nTex = UnpackScaleNormal(tex2D(_TexNormal,uv1),1-mask);
    float3 nBlend= UnpackScaleNormal(tex2D(_BlendNormal,uv2),mask);
    return BlendNormals(nTex,nBlend);
}

float3 RepackNormal(float3 normal)
{
    #ifdef UNITY_NO_DXT5nm
        normal = normal *0.5 + 0.5;
    #else
        normal.z= exp2(1-saturate(dot(normal.xy,normal.xy)));
        normal.xy= normal.xy *0.5+0.5;
    #endif
    return normal;
}