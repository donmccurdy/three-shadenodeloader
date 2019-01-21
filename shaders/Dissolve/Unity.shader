// Created with Shade for iPad
Shader "Shade/Dissolve"
{
    Properties
    {
        _EdgeColor  ("Edge Color", Color) = (0.0, 0.27863919734955, 1.0, 0)
        _EdgeGlow  ("Edge Glow", float) = 20.00
        _EdgeWidth  ("Edge Width", float) = 0.03
        [NoScaleOffset] _Gradient  ("Gradient", 2D) = "white" {}
        _NoiseScale  ("Noise Scale", float) = 2.00
    }

    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        ZWrite On
        LOD 200

        CGPROGRAM
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard vertex:vert finalcolor:customColor fullforwardshadows addshadow
        struct Input {
            float2 texcoord : TEXCOORD0;
            float3 worldPos;
        };

        float3 _EdgeColor;

        float _EdgeGlow;

        float _EdgeWidth;

        sampler2D _Gradient;

        float _NoiseScale;
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
        
        
        //
        // Description : Array and tex2Dless GLSL 2D/3D/4D simplex
        //               noise functions.
        //      Author : Ian McEwan, Ashima Arts.
        //  Maintainer : ijm
        //     Lastmod : 20110822 (ijm)
        //     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
        //               Distributed under the MIT License. See LICENSE file.
        //               https://github.com/ashima/webgl-noise
        //
        
        float3 mod289(float3 x) {
          return x - floor(x * (1.0 / 289.0)) * 289.0;
        }
        
        float4 mod289(float4 x) {
          return x - floor(x * (1.0 / 289.0)) * 289.0;
        }
        
        float4 permute(float4 x) {
             return mod289(((x*34.0)+1.0)*x);
        }
        
        float4 taylorInvSqrt(float4 r)
        {
          return 1.79284291400159 - 0.85373472095314 * r;
        }
        
        float snoise3D(float3 v)
          {
          const float2  C = float2(1.0/6.0, 1.0/3.0) ;
          const float4  D = float4(0.0, 0.5, 1.0, 2.0);
        
        // First corner
          float3 i  = floor(v + dot(v, C.yyy) );
          float3 x0 =   v - i + dot(i, C.xxx) ;
        
        // Other corners
          float3 g = step(x0.yzx, x0.xyz);
          float3 l = 1.0 - g;
          float3 i1 = min( g.xyz, l.zxy );
          float3 i2 = max( g.xyz, l.zxy );
        
          //   x0 = x0 - 0.0 + 0.0 * C.xxx;
          //   x1 = x0 - i1  + 1.0 * C.xxx;
          //   x2 = x0 - i2  + 2.0 * C.xxx;
          //   x3 = x0 - 1.0 + 3.0 * C.xxx;
          float3 x1 = x0 - i1 + C.xxx;
          float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
          float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y
        
        // Permutations
          i = mod289(i);
          float4 p = permute( permute( permute(
                     i.z + float4(0.0, i1.z, i2.z, 1.0 ))
                   + i.y + float4(0.0, i1.y, i2.y, 1.0 ))
                   + i.x + float4(0.0, i1.x, i2.x, 1.0 ));
        
        // Gradients: 7x7 points over a square, mapped onto an octahedron.
        // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
          float n_ = 0.142857142857; // 1.0/7.0
          float3  ns = n_ * D.wyz - D.xzx;
        
          float4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  fmod(p,7*7)
        
          float4 x_ = floor(j * ns.z);
          float4 y_ = floor(j - 7.0 * x_ );    // fmod(j,N)
        
          float4 x = x_ *ns.x + ns.yyyy;
          float4 y = y_ *ns.x + ns.yyyy;
          float4 h = 1.0 - abs(x) - abs(y);
        
          float4 b0 = float4( x.xy, y.xy );
          float4 b1 = float4( x.zw, y.zw );
        
          //float4 s0 = float4(lessThan(b0,0.0))*2.0 - 1.0;
          //float4 s1 = float4(lessThan(b1,0.0))*2.0 - 1.0;
          float4 s0 = floor(b0)*2.0 + 1.0;
          float4 s1 = floor(b1)*2.0 + 1.0;
          float4 sh = -step(h, float4(0.0));
        
          float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
          float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;
        
          float3 p0 = float3(a0.xy,h.x);
          float3 p1 = float3(a0.zw,h.y);
          float3 p2 = float3(a1.xy,h.z);
          float3 p3 = float3(a1.zw,h.w);
        
        //Normalise gradients
          float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
          p0 *= norm.x;
          p1 *= norm.y;
          p2 *= norm.z;
          p3 *= norm.w;
        
        // Mix final noise value
          float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
          m = m * m;
          return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1),
                                        dot(p2,x2), dot(p3,x3) ) );
          }
        
        
        float turb_snoise3D (in float3 st, in int octaves, in float lacunarity, in float gain)
        {
            // Initial values
            float value = 0.0;
            float amplitude = .5;
            float frequency = 0.;
            //
            // Loop of octaves
            for (int i = 0; i < octaves; i++) {
                value += amplitude * abs(snoise3D(st));
                st *= lacunarity;
                amplitude *= gain;
            }
            return value;
        }
        

        #include "UnityPBSLighting.cginc"
        void customColor (Input IN, SurfaceOutputStandard o, inout fixed4 color)
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

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float remap_8_1 = remap(sin(_Time.y), float2(-1.0, 1.0).x, float2(-1.0, 1.0).y, float2(0.0, 1.0).x, float2(0.0, 1.0).y);
            float localVar_Progression = remap_8_1;
            float4 temp_Gradient = tex2D(_Gradient, float2(remap(IN.worldPos, float2(0.0, 2.0).x, float2(0.0, 2.0).y, float2(0.0, 1.0).x, float2(0.0, 1.0).y).g, 0.0));
            float temp_3 = turb_snoise3D((IN.worldPos*float3(_NoiseScale, _NoiseScale, _NoiseScale)), 2, 3.000000, 0.500000);
            float remap_2_1 = remap(temp_3, float2(-1.0, 1.0).x, float2(-1.0, 1.0).y, float2(0.0, 1.0).x, float2(0.0, 1.0).y);
            float3 multiply_11_1 = (temp_Gradient.rgb * remap_2_1);
            float3 step_6_1 = step((_EdgeWidth+localVar_Progression), multiply_11_1);
            float3 oneminus_7_1 = (1.0 - step_6_1);
            float3 multiply_9_1 = ((_EdgeColor*float3(_EdgeGlow, _EdgeGlow, _EdgeGlow)) * oneminus_7_1);
            o.Emission = multiply_9_1;
            o.Albedo = float3(0.5, 0.5, 0.5);
            o.Smoothness = (1.0 - 0.32237);
            o.Metallic = 1.0;
            o.Alpha = multiply_11_1.r;
            o.Occlusion = 1.0;
        }
        ENDCG
    }
}
