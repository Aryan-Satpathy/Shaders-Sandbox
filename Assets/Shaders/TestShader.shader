Shader "Hidden/TestShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 viewVector : TEXCOORD3;
            };

            v2f vert(appdata v)
            {
                // v2f output;
                // output.pos = UnityObjectToClipPos(v.vertex);
                // output.uv = v.uv;
                // float3 viewVector = mul(unity_CameraInvProjection, float4(v.uv.xy * 2 - 1, 0, -1));
                // output.viewVector = mul(unity_CameraToWorld, float4(viewVector, 0));
                // return output;
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewVector = mul(unity_CameraToWorld, float4(mul(unity_CameraInvProjection, float4(v.uv.xy * 2 - 1, 0, -1)).xyz, 0));
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float _cameraFarClip;

            fixed4 frag (v2f i) : SV_Target
            {
                float nonlinDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                float depth = LinearEyeDepth(nonlinDepth) / _cameraFarClip;
                return float4(normalize(i.viewVector), 1);
            }
            ENDCG
        }
    }
}
