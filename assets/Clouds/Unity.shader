// Created with Shade for iPad
Shader "Shade/Clouds"
{
    Properties
    {
        [NoScaleOffset] _Gradient  ("Gradient", 2D) = "white" {}
        [NoScaleOffset] _Gradient1  ("Gradient 1", 2D) = "white" {}
        _WindSpeed  ("Wind Speed", float) = 10.00
        _Number  ("Number", float) = 0.10
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        LOD 200

        CGPROGRAM
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        // Unlit model
        #pragma surface surf NoLighting vertex:vert finalcolor:customColor noforwardadd alpha addshadow

        fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            fixed4 c;
            c.rgb = s.Albedo + s.Emission.rgb;
            c.a = s.Alpha;
            return c;
        }

        struct Input {
            float2 texcoord : TEXCOORD0;
            float3 worldPos;
        };

        sampler2D _Gradient;

        sampler2D _Gradient1;

        float _WindSpeed;

        float _Number;
        //
        // GLSL tex2Dless classic 3D noise "cnoise3D",
        // with an RSL-style periodic variant "pnoise".
        // Author:  Stefan Gustavson (stefan.gustavson@liu.se)
        // Version: 2011-10-11
        //
        // Many thanks to Ian McEwan of Ashima Arts for the
        // ideas for permutation and gradient selection.
        //
        // Copyright (c) 2011 Stefan Gustavson. All rights reserved.
        // Distributed under the MIT license. See LICENSE file.
        // https://github.com/ashima/webgl-noise
        //
        
        float3 mod289(float3 x)
        {
          return x - floor(x * (1.0 / 289.0)) * 289.0;
        }
        
        float4 mod289(float4 x)
        {
          return x - floor(x * (1.0 / 289.0)) * 289.0;
        }
        
        float4 permute(float4 x)
        {
          return mod289(((x*34.0)+1.0)*x);
        }
        
        float4 taylorInvSqrt(float4 r)
        {
          return 1.79284291400159 - 0.85373472095314 * r;
        }
        
        float3 fade(float3 t) {
          return t*t*t*(t*(t*6.0-15.0)+10.0);
        }
        
        // Classic Perlin noise
        float cnoise3D(float3 P)
        {
          float3 Pi0 = floor(P); // Integer part for indexing
          float3 Pi1 = Pi0 + float3(1.0); // Integer part + 1
          Pi0 = mod289(Pi0);
          Pi1 = mod289(Pi1);
          float3 Pf0 = frac(P); // Fractional part for interpolation
          float3 Pf1 = Pf0 - float3(1.0); // Fractional part - 1.0
          float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
          float4 iy = float4(Pi0.yy, Pi1.yy);
          float4 iz0 = Pi0.zzzz;
          float4 iz1 = Pi1.zzzz;
        
          float4 ixy = permute(permute(ix) + iy);
          float4 ixy0 = permute(ixy + iz0);
          float4 ixy1 = permute(ixy + iz1);
        
          float4 gx0 = ixy0 * (1.0 / 7.0);
          float4 gy0 = frac(floor(gx0) * (1.0 / 7.0)) - 0.5;
          gx0 = frac(gx0);
          float4 gz0 = float4(0.5) - abs(gx0) - abs(gy0);
          float4 sz0 = step(gz0, float4(0.0));
          gx0 -= sz0 * (step(0.0, gx0) - 0.5);
          gy0 -= sz0 * (step(0.0, gy0) - 0.5);
        
          float4 gx1 = ixy1 * (1.0 / 7.0);
          float4 gy1 = frac(floor(gx1) * (1.0 / 7.0)) - 0.5;
          gx1 = frac(gx1);
          float4 gz1 = float4(0.5) - abs(gx1) - abs(gy1);
          float4 sz1 = step(gz1, float4(0.0));
          gx1 -= sz1 * (step(0.0, gx1) - 0.5);
          gy1 -= sz1 * (step(0.0, gy1) - 0.5);
        
          float3 g000 = float3(gx0.x,gy0.x,gz0.x);
          float3 g100 = float3(gx0.y,gy0.y,gz0.y);
          float3 g010 = float3(gx0.z,gy0.z,gz0.z);
          float3 g110 = float3(gx0.w,gy0.w,gz0.w);
          float3 g001 = float3(gx1.x,gy1.x,gz1.x);
          float3 g101 = float3(gx1.y,gy1.y,gz1.y);
          float3 g011 = float3(gx1.z,gy1.z,gz1.z);
          float3 g111 = float3(gx1.w,gy1.w,gz1.w);
        
          float4 norm0 = taylorInvSqrt(float4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
          g000 *= norm0.x;
          g010 *= norm0.y;
          g100 *= norm0.z;
          g110 *= norm0.w;
          float4 norm1 = taylorInvSqrt(float4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
          g001 *= norm1.x;
          g011 *= norm1.y;
          g101 *= norm1.z;
          g111 *= norm1.w;
        
          float n000 = dot(g000, Pf0);
          float n100 = dot(g100, float3(Pf1.x, Pf0.yz));
          float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
          float n110 = dot(g110, float3(Pf1.xy, Pf0.z));
          float n001 = dot(g001, float3(Pf0.xy, Pf1.z));
          float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
          float n011 = dot(g011, float3(Pf0.x, Pf1.yz));
          float n111 = dot(g111, Pf1);
        
          float3 fade_xyz = fade(Pf0);
          float4 n_z = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
          float2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
          float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
          return 2.2 * n_xyz;
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
            o.Emission = float3(0.0, 0.0, 0.0);
            float divide_13 = (0.0 / 50.0);
            o.Albedo = tex2D(_Gradient, float2((1.0 - divide_13), 0.0)).rgb;
            float temp_15 = cnoise3D((float3((((IN.worldPos.rb+float2((_Time.y * _WindSpeed), 0.0))*float2(0.25, 0.25)) * _Number).r, 0.0, (((IN.worldPos.rb+float2((_Time.y * _WindSpeed), 0.0))*float2(0.25, 0.25)) * _Number).g)+float3(0.0, (_Time.y * 0.05), 0.0)));
            o.Alpha = clamp((tex2D(_Gradient1, float2(divide_13, 0.0)).rgb.r*temp_15), 0.0, 1.0);
        }
        ENDCG
    }
}
