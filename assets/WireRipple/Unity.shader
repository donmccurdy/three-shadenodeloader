// Created with Shade for iPad
Shader "Shade/Wire Ripple "
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
            float3 worldPos;
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
            float multiply_23 = ((length(IN.worldPos.rb)-(_Time.y * 0.25658)) * 5.0);
            o.Emission = (float3(max((1.0 - (abs((frac((multiply_23-0.5))-0.5)) / fwidth(multiply_23))), 0.0), max((1.0 - (abs((frac((multiply_23-0.5))-0.5)) / fwidth(multiply_23))), 0.0), max((1.0 - (abs((frac((multiply_23-0.5))-0.5)) / fwidth(multiply_23))), 0.0))*float3(1.0, 0.3918, 0.0)*float3(30.0, 30.0, 30.0));
            o.Albedo = float3(0.0, 0.0, 0.0);
            o.Smoothness = (1.0 - 1.0);
            o.Metallic = 0.0;
            o.Alpha = 1.1039;
            o.Occlusion = 1.0;
        }
        ENDCG
    }
}
