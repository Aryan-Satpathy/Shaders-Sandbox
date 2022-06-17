// Upgrade NOTE: commented out 'float3 _WorldSpaceCameraPos', a built-in variable

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Atmosphere"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        // _cameraFarClip("cameraFarClip", float) = 1000
        // _numScatterPoints("numScatterPoints", int) = 50
        // _numDensityPoints("numDensityPoints", int) = 30
        // _sunPos("sunPos", Vector) = (0, 0, 43.42)
        // _planetPos("planetPos", Vector) = (0, 0, 0)
        // _atmosphereRadius("atmosphereRadius", float) = 10
        // _planetRadius("planetRadius", float) = 5
        // _densityFallOff("densityFallOff", float) = 10
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
            int _numScatterPoints;
            int _numDensityPoints;
            float3 _sunPos;
            float3 _planetPos;
            float _atmosphereRadius;
            float _planetRadius;
            float _densityFallOff;
            float scatterR;
            float scatterG;
            float scatterB;

            float2 raySphere(float3 center, float radius, float3 origin, float3 dir)
            {
                float3 posVector = origin - center;
                
                // line : posVector + k raydir (segment when k > 0)
                // posVector.posVector + (k ^ 2) raydir.raydir + 2k posVector.raydir = r ^ 2
                float a = 1;
                float b = 2 * dot(posVector, dir);
                float c = dot(posVector, posVector) - radius * radius;

                float D = b * b - 4 * a * c;

                // D < 0 : no real intersection
                // D == 0 : tangent
                // D > 0 : 2 intersections

                if (D < 0)
                {
                    return float2(1E48, 0);
                    // return float2(0, 0);
                }
                else if (D == 0)
                {
                    return float2(-b / 2 / a, 0);
                    //return float2(0, 1);
                }
                else
                {
                    float d = sqrt(D);
                    float k1 = max(0, (-b - d) / 2 / a);
                    float k2 = (-b + d) / 2 / a;
                    if (k2 < 0) return float2(1E48, 0); // return float2(1, 0); 
                    return float2(k1, k2 - k1);
                    // return float2(1, 1);
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

            float3 calculateLight(float3 rayOrigin, float3 rayDir, float3 rayLength, float3 originalCol)
            {
                float3 inScatterPoint = rayOrigin;
                float step = rayLength / (_numScatterPoints - 1);
                float3 inScatterLight = 0;
                float3 scatterCoeffs = float3(scatterR, scatterG, scatterB);
                float viewRayOpticalDepth;

                for (int i = 0; i < _numScatterPoints; i++)
                {
                    float3 sunRay = normalize(_sunPos - inScatterPoint);
                    float sunRayLength = raySphere(_planetPos, _atmosphereRadius, inScatterPoint, sunRay).y;
                    float sunRayOpticalDepth = opticalDepth(inScatterPoint, sunRay, sunRayLength);
                    viewRayOpticalDepth = opticalDepth(inScatterPoint, -rayDir, step * i);
                    float3 transmittance = exp((-sunRayOpticalDepth - viewRayOpticalDepth) * scatterCoeffs);
                    float localDensity = densityAtPoint(inScatterPoint);

                    inScatterLight += localDensity * transmittance * scatterCoeffs * step;

                    inScatterPoint += rayDir * step;
                }
                float originalTransmittance = exp(-viewRayOpticalDepth);
                return originalCol * originalTransmittance + inScatterLight;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 originalColor = tex2D(_MainTex, i.uv);
                // return originalColor;
                float nonlinDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);

                // return Linear01Depth(nonlinDepth);

                float depth = Linear01Depth(tex2D(_CameraDepthTexture, i.uv)) * _cameraFarClip;
                
                // float depth = LinearEyeDepth(nonlinDepth); //  * length(i.viewVector) / 100;
                // float depth = LinearEyeDepth(nonlinDepth) * length(i.viewVector) / 100;
                // return length(i.viewVector) / 10;
                // float depth = LinearEyeDepth(nonlinDepth);

                float3 rayOrigin = _WorldSpaceCameraPos;
                float3 rayDir = normalize(i.viewVector);

                // return float4((rayDir + 1) / 2, 1);
                // just invert the colors
                // col.rgb = 1 - col.rgb;
                // return float4(depth / _cameraFarClip * length(i.viewVector) / 2, depth / _cameraFarClip * length(i.viewVector) / 2, depth / _cameraFarClip * length(i.viewVector) / 2, 1);
                // return depth / length(i.viewVector);

                float dstToOcean = raySphere(_planetPos, _planetRadius, rayOrigin, rayDir);
                float dstToSurface = min(depth, dstToOcean);

                float2 hit = raySphere(_planetPos, _atmosphereRadius, rayOrigin, rayDir);
                // return float4(hit.x, hit.y, 1, 1);
                   
                // return float4(hit, 1, 1);

                float dstToAtm = hit.x;
                float dstThrAtm = min(hit.y, dstToSurface - dstToAtm);

                // return hit.y / 2 / _atmosphereRadius;
                // return dstThrAtm / 2 / _atmosphereRadius;

                if (dstThrAtm > 0)
                {
                    const float epsilon = 0.00001;
                    float3 _point = rayOrigin + rayDir * (dstToAtm + epsilon);//  + epsilon
                    float3 light = calculateLight(_point, rayDir, dstThrAtm - epsilon * 2, originalColor); // - epsilon * 2
                    // return float4(0, 0, 0, 1);
                    return float4(light, 1);
                }
                return originalColor;
            }
            ENDCG
        }
    }
}
