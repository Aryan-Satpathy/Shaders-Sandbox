// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // _CameraDepthTexture ("Texture", 2D) = "white" {}
        
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members viewVector)
// #pragma exclude_renderers d3d11
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
                float3 viewVector : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewVector = mul(unity_CameraToWorld, float4(mul(unity_CameraInvProjection, float4(v.uv.xy * 2 - 1, 0, -1)).xyz, 0));
                o.uv = v.uv;
                return o;
                /*v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldViewVec = UnityWorldSpaceViewDir(worldPos);
                o.viewVector = worldViewVec;
                o.uv = v.uv;
                return o;*/
            }

            uniform sampler2D _MainTex;
            uniform sampler2D _CameraDepthTexture;
            
            float density;
            float startDst;

            float4 ColorA;
            float4 ColorB;

            fixed4 frag(v2f i) : SV_Target
            {
                float3 rayPos = _WorldSpaceCameraPos;
                float viewLength = length(i.viewVector);
                float3 rayDir = i.viewVector / viewLength;
                
                float non_lindepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                float depth = LinearEyeDepth(non_lindepth) * viewLength;

                float fogDensity = 1 - saturate(exp(-(depth - startDst) * density * 0.01));

                float4 fogColor = lerp(ColorA, ColorB, rayDir.y * 0.5 + 0.5);
                
                float4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                // col.rgb = 1 - col.rgb;
                // return 1 - fogDensity;
                return fogColor * fogDensity + col * (1 - fogDensity);
                // return col;
            }
            ENDCG
        }
    }
}
