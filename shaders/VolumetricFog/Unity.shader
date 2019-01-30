// Created with Shade for iPad
Shader "Shade/Volumetric Fog"
{
    Properties
    {
        _NoiseScaleA  ("Noise Scale A", float) = 1.00
        _NoiseSpeedA  ("Noise Speed A", Vector) = (0.10000000149012, 0.20000000298023, 0, 0)
        [NoScaleOffset] _NoiseTexture  ("Noise Texture", 2D) = "white" {}
        _NoiseScaleB  ("Noise Scale B", float) = 0.50
        _NoiseSpeedB  ("Noise Speed B", Vector) = (0.5, -0.25, 0, 0)
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
        };

        float _NoiseScaleA;

        float2 _NoiseSpeedA;

        sampler2D _NoiseTexture;

        float _NoiseScaleB;

        float2 _NoiseSpeedB;
        

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
            float4 temp_Texture = tex2D(_NoiseTexture, (IN.texcoord*float2(_NoiseScaleA, _NoiseScaleA)+(_NoiseSpeedA * (_Time.y * 0.5))));
            float4 temp_Texture1 = tex2D(_NoiseTexture, (IN.texcoord*float2(_NoiseScaleB, _NoiseScaleB)+(_NoiseSpeedB * (_Time.y * 0.2))));
            float3 multiply_11_1 = (temp_Texture.rgb * temp_Texture1.rgb);
            float divide_18_1 = (0.0 / 30.0);
            float smoothstep_29_1 = smoothstep(0.0, 1.0, divide_18_1);
            float3 subtract_22_1 = (multiply_11_1 - (smoothstep_29_1*0.5));
            float3 multiply_27_1 = (float3(0.59452, 0.75792, 0.77341) * subtract_22_1);
            o.Emission = multiply_27_1;
            o.Albedo = multiply_27_1;
            float3 clamp01_35_1 = clamp(subtract_22_1, 0.0, 1.0);
            o.Alpha = clamp01_35_1.r;
        }
        ENDCG
    }
}
