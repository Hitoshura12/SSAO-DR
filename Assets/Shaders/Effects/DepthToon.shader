Shader "Hidden/Taka/Effects/DepthToon"
{
    HLSLINCLUDE
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    #define tex2D(idx,uv) SAMPLE_TEXTURE2D(idx,sampler##idx,uv)
    #define sampler2D(idx) TEXTURE2D_SAMPLER2D(idx, sampler##idx)
    #define v2f VaryingsDefault

    sampler2D(_MainTex);
    sampler2D(_CameraDepthTexture);
    sampler2D(_CameraGBufferTexture0);
    sampler2D(_CameraGBufferTexture2);
    sampler2D(_GlobalScreenSpaceShadows);
    int _CastShadows; //not int, this is a boolean!
    half _FallOff;
    half4 _Color;
    half4 _ShadowColor;
    half _Range;

    half _Softness;
    half _Coverage;
    float3 _LightDir;

    float4x4 _InverseMat; //for eye(View) space to world space for pixel world pos.
    float2 _Size; //Sphere of influence of the effect
    half4 frag(v2f i) : SV_Target
    {
        //Main cam tex and buffers (albedo and world normals)
        half4 col = tex2D(_MainTex, i.texcoord);
        half4 albedo= tex2D(_CameraGBufferTexture0,i.texcoord);
        float3 normal= tex2D(_CameraGBufferTexture2,i.texcoord).xyz;

        //position of the shadow by light direction and world normals from GBuffer
        float selfShadow= 1-(dot(normal,_LightDir)*0.5+0.5); 
        selfShadow = pow(selfShadow,lerp(1,4,_Coverage)); //how much the shadow toon covers?
        selfShadow=smoothstep(0.5,lerp(0.5,1,_Softness),selfShadow); //smoothing the shadow (Hard/Soft shadows)
        selfShadow *= tex2D(_GlobalScreenSpaceShadows, i.texcoord).r * _CastShadows + (1 - _CastShadows);
        half4 diffuse = lerp(_ShadowColor,_Color,selfShadow)* albedo; //applying the shadow to Albedo colors from GBuffer
        
        float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,sampler_CameraDepthTexture,i.texcoord);
        depth=Linear01Depth(depth); //these 2 lines are how depth calculations are done in 95% of shaders
        
        float4 p = float4((i.texcoord.x *2-1)*_Size.x,i.texcoord.y*_Size.y,depth,1); //pixel xyzw coordinates
        float3 worldPos = mul(_InverseMat,p); //transform with the inverse matrix from VS to WS
        float dist =1- distance(_WorldSpaceCameraPos,worldPos); //get the distance between pixel and camera
        // the above calc serves to create a "zone" in which the toony effect is applied.
        
       float range = ((depth*_ProjectionParams.z)-_ProjectionParams.y)*(1-_Range);
        range = saturate(exp2(-range*range));
        range = smoothstep(0.25, lerp(0.25, 1, _FallOff), range*dist);
        return lerp(col,diffuse,range*step(depth,0.999));

    }
    ENDHLSL
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite OFF ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment frag
            ENDHLSL
        }
    }
}