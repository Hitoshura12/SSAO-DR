Shader "Xibanya/Unlit/Normals"
{
    Properties
    {
        [MainTexture]
        _BumpMap        ("Normal Map", 2D) = "bump" {}
        [IntRange]
        _Mode           ("Mode", Range(0, 4)) = 0
    }
        SubShader
        {
            Tags{ "RenderType" = "Opaque" }
            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float2 uv       : TEXCOORD0;
                    float4 tangent  : TANGENT;
                };
                struct v2f
                {
                    float4 pos          : SV_POSITION;
                    float3 normal       : NORMAL;
                    float3 tangent      : TANGENT;
                    float2 uv           : TEXCOORD0;
                    float3 viewDir      : TEXCOORD1;
                    float3 viewNormal   : TEXCOORD2;
                    float3 bitangent    : TEXCOORD3;
                    float3 objNorm      : TEXCOORD4;
                };

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    float3 worldPos = mul(v.vertex, unity_ObjectToWorld).xyz;
                    o.viewDir = _WorldSpaceCameraPos.xyz - worldPos;
                    o.viewNormal = COMPUTE_VIEW_NORMAL;
                    o.normal = UnityObjectToWorldNormal(v.normal);
                    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
                    half sign = v.tangent.w * unity_WorldTransformParams.w;
                    o.bitangent = cross(o.normal, o.tangent) * sign;
                    o.objNorm = v.normal;
                    return o;
                }
                sampler2D       _BumpMap;
                half            _Mode;

                half4 frag(v2f i) : SV_Target
                {
                    float3 normalTS = UnpackNormal(tex2D(_BumpMap, i.uv));
                    half3 col = normalTS * 0.5 + 0.5;

                    float3 worldNormal = mul(normalTS, half3x3(i.tangent, i.bitangent, i.normal)) * 0.5 + 0.5;
                    col = lerp(col, worldNormal, _Mode == 1);

                    float3 worldViewDir = mul(normalTS, half3x3(i.tangent, i.bitangent, i.viewDir)) * 0.5 + 0.5;
                    col = lerp(col, worldViewDir, _Mode == 2);

                    float3 viewNormal = mul(normalTS, half3x3(i.tangent, i.bitangent, i.viewNormal)) * 0.5 + 0.5;
                    col = lerp(col, viewNormal, _Mode == 3);

                    float3 objNormal = mul(normalTS, half3x3(i.tangent, i.bitangent, i.objNorm)) * 0.5 + 0.5;
                    col = lerp(col, objNormal, _Mode == 4);
                 
                    return half4(col, 1);
                }
                ENDCG
            }
        }
}