// Created with Shade for iPad
Shader "Shade/Wireframe"
{
    Properties
    {
        _Thickness  ("Thickness", Range (0.00, 1.00)) = 0.33
        _Smoothness  ("Smoothness", Range (0.00, 1.00)) = 1.00
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

        float _Thickness;

        float _Smoothness;
        

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
            o.Emission = float3(0.0, 0.0, 0.0);
            float3 multiply_8 = (_Thickness * fwidth(float3(0.0, 0.0, 0.0)));
            o.Albedo = float3(min(min(float4(smoothstep(multiply_8, (multiply_8+(fwidth(float3(0.0, 0.0, 0.0)) * _Smoothness)), float3(0.0, 0.0, 0.0)).rgb,0.0).r, float4(smoothstep(multiply_8, (multiply_8+(fwidth(float3(0.0, 0.0, 0.0)) * _Smoothness)), float3(0.0, 0.0, 0.0)).rgb,0.0).g), float4(smoothstep(multiply_8, (multiply_8+(fwidth(float3(0.0, 0.0, 0.0)) * _Smoothness)), float3(0.0, 0.0, 0.0)).rgb,0.0).b), min(min(float4(smoothstep(multiply_8, (multiply_8+(fwidth(float3(0.0, 0.0, 0.0)) * _Smoothness)), float3(0.0, 0.0, 0.0)).rgb,0.0).r, float4(smoothstep(multiply_8, (multiply_8+(fwidth(float3(0.0, 0.0, 0.0)) * _Smoothness)), float3(0.0, 0.0, 0.0)).rgb,0.0).g), float4(smoothstep(multiply_8, (multiply_8+(fwidth(float3(0.0, 0.0, 0.0)) * _Smoothness)), float3(0.0, 0.0, 0.0)).rgb,0.0).b), min(min(float4(smoothstep(multiply_8, (multiply_8+(fwidth(float3(0.0, 0.0, 0.0)) * _Smoothness)), float3(0.0, 0.0, 0.0)).rgb,0.0).r, float4(smoothstep(multiply_8, (multiply_8+(fwidth(float3(0.0, 0.0, 0.0)) * _Smoothness)), float3(0.0, 0.0, 0.0)).rgb,0.0).g), float4(smoothstep(multiply_8, (multiply_8+(fwidth(float3(0.0, 0.0, 0.0)) * _Smoothness)), float3(0.0, 0.0, 0.0)).rgb,0.0).b));
            o.Smoothness = (1.0 - 0.32468);
            o.Metallic = 0.0;
            o.Alpha = 1.0;
            o.Occlusion = 1.0;
        }
        ENDCG
    }
}
