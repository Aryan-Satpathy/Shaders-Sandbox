Shader "Unlit/TexCol"
{
    SubShader
    {
        Tags {"RenderType"="Opaque"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float nor : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float r : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                float r = sqrt(v.vertex.x * v.vertex.x + v.vertex.y * v.vertex.y + v.vertex.z * v.vertex.z);
                o.r = r;
                o.nor = dot(normalize(v.normal), v.vertex / r);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                if (i.r > 5.9) return float4(1, 1, 1, 1);
                if (i.r < 4.9) return float4(194.0 / 255, 189.0 / 255, 128.0 / 255, 1);
                if (pow(i.nor, 5) < 0.8) return float4(0.4, 0.25, 0.25, 1);
                if (1 - pow(i.nor, 10) < 0.01) return float4(1, 0.8, 0.6, 1);
                return float4(0.55, 0.74, 0.31, 1);
            }
            ENDCG
        }
    }
        Fallback "Diffuse"
}
