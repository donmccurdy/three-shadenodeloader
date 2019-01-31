// Created with Shade for iPad
Shader "Shade/Checkers"
{
    Properties
    {
        _ColorA  ("Color A", Color) = (0.0, 0.0, 0.0, 0)
        _ColorB  ("Color B", Color) = (1.0, 0.75297492742538, 0.0, 0)
        _Size  ("Size", float) = 8.00
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

        float3 _ColorA;

        float3 _ColorB;

        float _Size;
        

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
            o.Albedo = lerp(_ColorA, _ColorB, fmod((float4(floor((IN.texcoord * float2(_Size, _Size))).rg,0.0,0.0).r + float4(floor((IN.texcoord * float2(_Size, _Size))).rg,0.0,0.0).g), 2.0));
            o.Smoothness = (1.0 - 0.43421);
            o.Metallic = 0.0;
            o.Alpha = 1.1039;
            o.Occlusion = 1.0;
        }
        ENDCG
    }
}
