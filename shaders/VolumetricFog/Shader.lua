    {
        name = "Volumetric Fog",

        options =
        {
            DOUBLE_SIDED = { true },
            USE_COLOR = { true },
            SELECTION_MODE = { true },
        },

        properties =
        {
            _volumeHeight = { "float", 4.0 },
            _noiseScaleA = { "float", 1.0 },
            _noiseSpeedA = { "vec2", {0.10000000149012, 0.20000000298023} },
            _time = { "float", "0.0" },
            _noiseTexture = { "texture2D", "Noise Texture" },
            _noiseScaleB = { "float", 0.5 },
            _noiseSpeedB = { "vec2", {0.5, -0.25} },
        },

        pass =
        {
            base = "Surface",

            blendMode = "normal",
            depthWrite = false,
            depthFunc = "lessEqual",
            renderQueue = "transparent",
            colorMask = {"rgba"},
            cullFace = "none",


            vertex =
            [[
                uniform float _volumeHeight;
                out float vInstanceID;


                void vertex(inout Vertex v, out Input o)
                {
                    vec3 multiply_25_1 = (position * 30.0);
                    float divide_19_1 = (_volumeHeight / 30.0);
                    float multiply_20_1 = (float(gl_InstanceID) * divide_19_1);
                    v.position += (multiply_25_1-vec3(0.0, 0.45, 0.0)+vec3(0.0, multiply_20_1, 0.0));
                    vInstanceID = float(gl_InstanceID);
                }
            ]],

            surface =
            [[
                uniform float _noiseScaleA;
                uniform vec2 _noiseSpeedA;
                uniform float _time;
                uniform lowp sampler2D _noiseTexture;
                uniform float _noiseScaleB;
                uniform vec2 _noiseSpeedB;
                in float vInstanceID;


                

                void surface(in Input IN, inout SurfaceOutput o)
                {
                    o.emissive = 1.0;
                    vec4 temp_Texture = texture(_noiseTexture, (IN.uv*vec2(_noiseScaleA, _noiseScaleA)+(_noiseSpeedA * (_time * 0.5))));
                    vec4 temp_Texture1 = texture(_noiseTexture, (IN.uv*vec2(_noiseScaleB, _noiseScaleB)+(_noiseSpeedB * (_time * 0.2))));
                    vec3 multiply_11_1 = (temp_Texture.rgb * temp_Texture1.rgb);
                    float divide_18_1 = (vInstanceID / 30.0);
                    float smoothstep_29_1 = smoothstep(0.0, 1.0, divide_18_1);
                    vec3 subtract_22_1 = (multiply_11_1 - (smoothstep_29_1*0.5));
                    vec3 multiply_27_1 = (vec3(0.59452, 0.75792, 0.77341) * subtract_22_1);
                    o.diffuse = multiply_27_1;
                    o.emission = multiply_27_1;
                    vec3 clamp01_35_1 = clamp(subtract_22_1, 0.0, 1.0);
                    o.opacity = clamp01_35_1.r;
                }
            ]]
        }
    }
    