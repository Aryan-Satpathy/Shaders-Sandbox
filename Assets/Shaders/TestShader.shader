// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/TestShader"
{
    SubShader
    {
        // No culling or depth
        //Cull Off ZWrite Off ZTest Always
        Tags {"RenderType"="Opaque"}
        Pass
        {
            //CGPROGRAM
            //#pragma vertex vert
            //#pragma fragment frag

            //#include "UnityCG.cginc"

            //struct appdata
            //{
            //    float4 vertex : POSITION;
            //    float2 uv : TEXCOORD0;
            //};

            //struct v2f
            //{
            //    float2 uv : TEXCOORD1;
            //    float4 uv0 : TEXCOORD2;
            //    float4 vertex : SV_POSITION;
            //    float3 viewVector : TEXCOORD3;
            //};


            //sampler2D _MainTex;
            //float4 _MainTex_ST;
            //sampler2D _CameraDepthTexture;
            //float _cameraFarClip = 1000;

            //v2f vert(appdata v)
            //{
            //    // v2f output;
            //    // output.pos = UnityObjectToClipPos(v.vertex);
            //    // output.uv = v.uv;
            //    // float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv.xy * 2 - 1, 0, -1));
            //    // output.viewVector = mul(unity_CameraToWorld, float4(viewVector, 0));
            //    // return output;
            //    v2f o;
            //    o.vertex = UnityObjectToClipPos(v.vertex);
            //    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            //    o.viewVector = mul(unity_CameraToWorld, float4(mul(unity_CameraInvProjection, float4(v.uv.xy * 2 - 1, 0, -1)).xyz, 0));
            //    o.uv0 = ComputeScreenPos(o.vertex);
            //    return o;
            //}

            //float4 frag (v2f i) : SV_Target
            //{
            //    float nonlinDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv0.xy / i.uv0.w);
            //    float depth = Linear01Depth(nonlinDepth) / _cameraFarClip;
            //    return float4(depth, depth, 0, 1);
            //}

            //ENDCG
            CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

sampler2D _CameraDepthTexture;

struct v2f {
float4 pos : SV_POSITION;
float4 scrPos:TEXCOORD1;
};

//Vertex Shader
v2f vert(appdata_base v) {
v2f o;
o.pos = UnityObjectToClipPos(v.vertex);
o.scrPos = ComputeScreenPos(o.pos);
return o;
}

//Fragment Shader
half4 frag(v2f i) : COLOR{
float depthValue = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);
half4 depth;

depth.r = depthValue;
depth.g = depthValue;
depth.b = depthValue;

depth.a = 1;
return depth;
}
ENDCG
        }
    } Fallback "Diffuse"
}
