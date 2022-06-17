Shader "Hidden/atmos2"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
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
			// #include "../Includes/Math.cginc"
			//

			struct appdata {
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float3 norm : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 norm : NORMAL;
				float3 viewDir : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v) {
				v2f output;
				output.pos = UnityObjectToClipPos(v.vertex);
				output.uv = TRANSFORM_TEX(v.uv, _MainTex);
				output.norm = v.norm;
				// output.viewDir = normalize(v.vertex.xyz - _WorldSpaceCameraPos);
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				output.viewDir = mul(unity_CameraInvProjection, float4(v.uv.xy * 2 - 1, 0, -1));
				output.viewDir = mul(unity_CameraToWorld, float4(output.viewDir, 0));
				output.viewDir = normalize(output.viewDir);
				output.screenPos = ComputeScreenPos(output.pos);
				return output;
			}

			//sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			float4 frag(v2f i) : SV_Target
			{
				//return float4(i.uv.xy, 0, 1);
				float3 viewDir01 = (i.viewDir + 1) * 0.5;
				return float4(viewDir01, 1);
				// return float4(i.uv.x, i.uv.y, 0, 1);
				// return i.screenPos;				// In i.screenPos, z = 0, w = 1
				return Linear01Depth(tex2D(_CameraDepthTexture, i.uv));
				// return tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)).r;
				// return SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				// return length(i.viewVec) / 8;
				// return float4(float3(length(i.viewVec)), 1);
				// return float4(i.viewDir * 0.5 + 1, 1);
				float4 originalCol = tex2D(_MainTex, i.uv);
				return originalCol;
			}


			ENDCG
		}
	}
}