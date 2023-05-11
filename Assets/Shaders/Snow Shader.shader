Shader "Custom/Snow Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _SnowColor("Snow Color",Color)=(1,1,1,1)
        _MainTex ("MainTex (RGB)", 2D) = "white" {}
        _OtherTex ("OtherTex ",2D)="white"{}
        _BumpMap("normal Map",2D)="bump"{}
        _BumpMap2("normal Map",2D)="bump"{}
        _Mix ("lerp value",Range(0,1))= 0.3
        _NormalStrength("Normal Strength",float)= 0.3
        _SnowDirection("Snow Direction",Vector)=(0,1,0,0)
     
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
  
        #pragma surface surf Standard fullforwardshadows

        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _OtherTex;
        sampler2D _BumpMap;
        sampler2D _BumpMap2;
        
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_OtherTex;
            float3 worldNormal;INTERNAL_DATA
        };

        fixed4 _Color;
        float _Mix;
        float _NormalStrength;
        float3 _SnowDirection;
        float4 _SnowColor;
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half dotProduct= dot(WorldNormalVector(IN,o.Normal),_SnowDirection);
             fixed4 maintex = tex2D (_MainTex, IN.uv_MainTex)*_Color;
            fixed4 othertex =tex2D(_OtherTex,IN.uv_OtherTex)*_SnowColor;
            o.Albedo = lerp(maintex,othertex, dotProduct*_Mix);
            fixed3 bumpMap1= UnpackNormal(tex2D(_BumpMap,IN.uv_MainTex));
            fixed3 bumpMap2 = UnpackNormal(tex2D(_BumpMap2,IN.uv_OtherTex));
            o.Normal = lerp(bumpMap1,bumpMap2,_Mix);
            o.Normal.z *= _NormalStrength;
            
            // Albedo comes from a texture tinted by color
           
        }
        ENDCG
    }
    FallBack "Diffuse"
}
