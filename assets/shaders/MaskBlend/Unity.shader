// Created with Shade for iPad
Shader "Shade/Mask Blend"
{
    Properties
    {
        [NoScaleOffset] _Mask  ("Mask", 2D) = "white" {}
        [NoScaleOffset] _NormalA  ("Normal A", 2D) = "white" {}
        [NoScaleOffset] _NormalB  ("Normal B", 2D) = "white" {}
        [NoScaleOffset] _BaseA  ("Base A", 2D) = "white" {}
        [NoScaleOffset] _BaseB  ("Base B", 2D) = "white" {}
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
        };

        sampler2D _Mask;

        sampler2D _NormalA;

        sampler2D _NormalB;

        sampler2D _BaseA;

        sampler2D _BaseB;
        // Source - https://stackoverflow.com/questions/5281261/generating-a-normal-map-from-a-height-map
        
        float sampleHeightN(float2 uv)
        {
            return tex2D(_Mask, uv).rgb.r;
        }
        
        float3 heightToNormal(float2 uv, float strength, float2 texelSize, float2 offset)
        {
            const float2 size = float2(2.0,0.0);
            const float3 off = float3(-1.0,0.0,1.0);
        
            float2 delta = texelSize;
        
            float s11 = sampleHeightN(uv + offset);
            float s01 = sampleHeightN(uv + delta * off.xy + offset);
            float s21 = sampleHeightN(uv + delta * off.zy + offset);
            float s10 = sampleHeightN(uv + delta * off.yx + offset);
            float s12 = sampleHeightN(uv + delta * off.yz + offset);
        
            float3 va = normalize(float3(size.x, size.y, (s21-s01) * strength));
            float3 vb = normalize(float3(size.y, size.x, (s12-s10) * strength));
        
            return cross(va,vb);
        }
        
        
        
        // Source - http://blog.selfshadow.com/publications/blending-in-detail/
        float3 blendNormals(float3 n1, float3 n2)
        {
            float3x3 nBasis = float3x3(
                float3(n1.z, n1.y, -n1.x), // +90 degree rotation around y axis
                float3(n1.x, n1.z, -n1.y), // -90 degree rotation around x axis
                float3(n1.x, n1.y,  n1.z));
        
            return normalize(n2.x*nBasis[0] + n2.y*nBasis[1] + n2.z*nBasis[2]);
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
            float3 temp_6 = heightToNormal(IN.texcoord, 1.0, float2(0.01, 0.01), float2(0.0, 0.0));
            float4 temp_Mask = tex2D(_Mask, IN.texcoord);
            o.Normal = blendNormals(temp_6, lerp(((tex2D(_NormalA, IN.texcoord) * 2.0 - 1.0) * float4(0.35855, 0.35855, 1.0, 1.0)).rgb, ((tex2D(_NormalB, IN.texcoord) * 2.0 - 1.0) * float4(0.25, 0.25, 1.0, 1.0)).rgb, temp_Mask.rgb));
            o.Emission = float3(0.0, 0.0, 0.0);
            o.Albedo = lerp(tex2D(_BaseA, IN.texcoord).rgb, tex2D(_BaseB, IN.texcoord).rgb, temp_Mask.rgb);
            o.Smoothness = (1.0 - 0.24342);
            o.Metallic = 0.0;
            o.Alpha = 0.0;
            o.Occlusion = 1.0;
        }
        ENDCG
    }
}
