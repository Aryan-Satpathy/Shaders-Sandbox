Shader "Hidden/Atmosphere"
{
    Properties
    {
        _cameraFarClip("cameraFarClip", float) = 1000
        _numScatterPoints("numScatterPoints", int) = 50
        _numDensityPoints("numDensityPoints", int) = 30
        _sunPos("sunPos", Vector) = (0, 0, 0)
        _planetPos("planetPos", Vector) = (0, 0, 0)
        _atmosphereRadius("atmosphereRadius", float) = 10
        _planetRadius("planetRadius", float) = 5
        _densityFallOff("densityFallOff", float) = 10
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewVector : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldViewVec = UnityWorldSpaceViewDir(worldPos);
                o.viewVector = worldViewVec;
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float _cameraFarClip;
            int _numScatterPoints;
            int _numDensityPoints;
            float3 _sunPos;
            float3 _planetPos;
            float _atmosphereRadius;
            float _planetRadius;
            float _densityFallOff;

            float2 raySphere(float3 center, float radius, float3 origin, float3 dir)
            {
                float2 posVector = origin - center;
                
                // line : posVector + k raydir (segment when k > 0)
                // posVector.posVector + (k ^ 2) raydir.raydir + k posVector.raydir = r ^ 2
                float a = 1;
                float b = dot(posVector, dir);
                float c = dot(posVector, posVector) - radius * radius;

                float D = b * b - 4 * a * c;

                // D < 0 : no real intersection
                // D == 0 : tangent
                // D > 0 : 2 intersections

                if (D < 0)
                {
                    return float2(1E48, 0);
                }
                else if (D == 0)
                {
                    return float2(-b / 2 / a, 0);
                }
                else
                {
                    float d = sqrt(D);
                    float k1 = max(0, (-b - d) / 2 / a);
                    float k2 = (-b + d) / 2 / a;
                    if (k2 < 0) return float2(-1, -1);
                    return float2(k1, k2 - k1);
                }
            }

            float densityAtPoint(float3 Point)
            {
                float heightAboveSurface = length(Point - _planetPos) - _planetRadius;
                float height01 = heightAboveSurface / (_atmosphereRadius - _planetRadius);

                float localDensity = exp(-height01 * _densityFallOff) * (1 - height01);

                return localDensity;
            }

            float opticalDepth(float3 rayOrigin, float3 dir, float distance)
            {
                float3 densityPoint = rayOrigin;
                float step = distance / (_numDensityPoints - 1);
                float depth = 0;

                for (int i = 0; i < _numDensityPoints; i++)
                {
                    float localDensity = densityAtPoint(densityPoint);
                    depth += step * localDensity;
                    densityPoint += dir * step;
                }

                return depth;
            }

            float calculateLight(float3 rayOrigin, float3 rayDir, float3 rayLength)
            {
                float3 inScatterPoint = rayOrigin;
                float step = rayLength / (_numScatterPoints - 1);
                float inScatterLight = 0;

                for (int i = 0; i < _numScatterPoints; i++)
                {
                    float3 sunRay = normalize(_sunPos - inScatterPoint);
                    float sunRayLength = raySphere(_planetPos, _atmosphereRadius, inScatterPoint, sunRay).y;
                    float sunRayOpticalDepth = opticalDepth(inScatterPoint, sunRay, sunRayLength);
                    float viewRayOpticalDepth = opticalDepth(inScatterPoint, -rayDir, step * i);
                    float transmittance = exp(-sunRayOpticalDepth - viewRayOpticalDepth);
                    float localDensity = densityAtPoint(inScatterPoint);

                    inScatterLight += localDensity * transmittance * step;

                    inScatterPoint += rayDir * step;
                }

                return inScatterLight;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 originalColor = tex2D(_MainTex, i.uv);
                float nonlinDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);

                float depth = LinearEyeDepth(nonlinDepth) * length(i.viewVector);
                // float depth = LinearEyeDepth(nonlinDepth);

                float3 rayOrigin = _WorldSpaceCameraPos;
                float3 rayDir = normalize(i.viewVector);
                // just invert the colors
                // col.rgb = 1 - col.rgb;
                // return float4(depth / _cameraFarClip, depth / _cameraFarClip, depth / _cameraFarClip, 1);
                float MaxDir = (rayDir.x > rayDir.y? rayDir.x : rayDir.y);
                MaxDir = MaxDir > rayDir.z ? MaxDir : rayDir.z;
                MaxDir = max(0.5, MaxDir);
                return float4(rayDir.x / MaxDir, rayDir.y / MaxDir, rayDir.z / MaxDir, 1);

                float2 hit = raySphere(_planetPos, _atmosphereRadius, rayOrigin, rayDir);
                return float4(hit.x, hit.y, 0, 1);
                
                float dstToAtm = hit.x;
                float dstThrAtm = min(hit.y, depth - dstToAtm);

                if (dstThrAtm)
                {
                    const float epsilon = 0.00001;
                    float3 _point = rayOrigin + rayDir * (dstToAtm + epsilon);
                    float light = calculateLight(_point, rayDir, dstThrAtm - epsilon * 2);
                    return originalColor * (1 - light) + light;
                }
                return originalColor;
            }
            ENDCG
        }
    }
}
