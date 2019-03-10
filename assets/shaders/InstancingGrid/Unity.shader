// Created with Shade for iPad
Shader "Shade/Instancing Grid"
{
    Properties
    {
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
            o.Albedo = float3(1.0, 0.62895, 0.0);
            o.Smoothness = (1.0 - 0.59211);
            o.Metallic = 0.42434;
            o.Alpha = 1.0;
            o.Occlusion = 1.0;
        }
        ENDCG
    }
}
