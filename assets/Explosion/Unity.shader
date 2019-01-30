// Created with Shade for iPad
Shader "Shade/Explosion"
{
    Properties
    {
        [NoScaleOffset] _ColorMap  ("Color Map", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        ZWrite On
        LOD 200

        CGPROGRAM
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        // Unlit model
        #pragma surface surf NoLighting vertex:vert finalcolor:customColor noforwardadd addshadow

        fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            fixed4 c;
            c.rgb = s.Albedo + s.Emission.rgb;
            c.a = s.Alpha;
            return c;
        }

        struct Input {
            float2 texcoord : TEXCOORD0;
            float3 worldNormal; 
        };

        sampler2D _ColorMap;
        
        float remap(float value, float minA, float maxA, float minB, float maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float2 remap(float2 value, float2 minA, float2 maxA, float2 minB, float2 maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float3 remap(float3 value, float3 minA, float3 maxA, float3 minB, float3 maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float4 remap(float4 value, float4 minA, float4 maxA, float4 minB, float4 maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float2 remap(float2 value, float minA, float maxA, float minB, float maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float3 remap(float3 value, float minA, float maxA, float minB, float maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        float4 remap(float4 value, float minA, float maxA, float minB, float maxB)
        {
            return minB + (value - minA) * (maxB - minB) / (maxA - minA);
        }
        
        
        const float2x2 myt = float2x2(.12121212, .13131313, -.13131313, .12121212);
        const float2 mys = float2(1e4, 1e6);
        
        float2 rhash(float2 uv) {
          uv *= myt;
          uv *= mys;
          return frac(frac(uv / mys) * uv);
        }
        
        float3 hash(float3 p) {
          return frac(
              sin(float3(dot(p, float3(1.0, 57.0, 113.0)), dot(p, float3(57.0, 113.0, 1.0)),
                       dot(p, float3(113.0, 1.0, 57.0)))) *
              43758.5453);
        }
        
        float3 voronoi3D(const in float3 x) {
          float3 p = floor(x);
          float3 f = frac(x);
        
          float id = 0.0;
          float2 res = float2(100.0);
          for (int k = -1; k <= 1; k++) {
            for (int j = -1; j <= 1; j++) {
              for (int i = -1; i <= 1; i++) {
                float3 b = float3(float(i), float(j), float(k));
                float3 r = float3(b) - f + hash(p + b);
                float d = dot(r, r);
        
                float cond = max(sign(res.x - d), 0.0);
                float nCond = 1.0 - cond;
        
                float cond2 = nCond * max(sign(res.y - d), 0.0);
                float nCond2 = 1.0 - cond2;
        
                id = (dot(p + b, float3(1.0, 57.0, 113.0)) * cond) + (id * nCond);
                res = float2(d, res.x) * cond + res * nCond;
        
                res.y = cond2 * d + nCond2 * res.y;
              }
            }
          }
        
          return float3(sqrt(res), abs(id));
        }
        

        void customColor (Input IN, SurfaceOutput o, inout fixed4 color)
        {
        #ifndef UNITY_PASS_FORWARDADD
        color = fixed4(lerp(float3(0.0, 0.0, 0.0), color.rgb, o.Alpha), 1.0);
        #endif
        }

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.texcoord = v.texcoord;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            float localVar_ExplosionTime = sqrt(min(fmod((_Time.y * 0.75), 2.0), 2.5));
            float4 temp_ColorMap = tex2D(_ColorMap, float2((localVar_ExplosionTime-((1.0 - localVar_ExplosionTime) * float4(voronoi3D(((normalize( mul( float4(normalize(IN.worldNormal) , 0.0 ), unity_WorldToObject ).xyz ) * remap(localVar_ExplosionTime, float2(0.0, 1.0).x, float2(0.0, 1.0).y, float2(0.5, 1.3).x, float2(0.5, 1.3).y))+float3(0.0, (localVar_ExplosionTime * 4.0), 0.0))).rgb,0.0).r)), 0.0));
            o.Emission = clamp((temp_ColorMap.rgb - 0.5), 0.0, 1.0);
            o.Albedo = temp_ColorMap.rgb;
            float oneminus_8 = (1.0 - float4(voronoi3D(((normalize( mul( float4(normalize(IN.worldNormal) , 0.0 ), unity_WorldToObject ).xyz ) * remap(localVar_ExplosionTime, float2(0.0, 1.0).x, float2(0.0, 1.0).y, float2(0.5, 1.3).x, float2(0.5, 1.3).y))+float3(0.0, (localVar_ExplosionTime * 4.0), 0.0))).rgb,0.0).r);
            o.Alpha = (oneminus_8 * 1.0);
        }
        ENDCG
    }
}
