{
    name = "Wire Ripple ",

    options =
    {
        USE_COLOR = { true },
        USE_LIGHTING = { true },
        STANDARD = { true },
        PHYSICAL = { true },
        ENVMAP_TYPE_CUBE = { true },
        ENVMAP_MODE_REFLECTION = { true },
        USE_ENVMAP = { false, {"envMap"} },
        SELECTION_MODE = { true },
    },

    properties =
    {
        envMap = { "cubeTexture", "nil" },
        envMapIntensity = { "float", "0.75" },
        refactionRatio = { "float", "0.5" },
        _time = { "float", "0.0" },
        _mic_amp_freq = { "vec2", {0.0, 0.0} },
    },

    pass =
    {
        base = "Surface",

        blendMode = "disabled",
        depthWrite = true,
        depthFunc = "lessEqual",
        renderQueue = "solid",
        colorMask = {"rgba"},
        cullFace = "back",

        vertex =
        [[
            uniform float _time;
            uniform vec2 _mic_amp_freq;

            
            void vertex(inout Vertex v, out Input o)
            {
                v.position += (vec3(0.0, (sin((distance(v.uv, vec2(0.5, 0.5))*50.0+_time)) * (2.0*_mic_amp_freq.x)), 0.0)+vec3(0.0, 1.0, 0.0));
            }
        ]],

        surface =
        [[
            uniform float _time;
            
            void surface(in Input IN, inout SurfaceOutput o)
            {
                o.emissive = 1.0;
                o.diffuse = vec3(0.0, 0.0, 0.0);
                o.roughness = 1.0;
                o.metalness = 0.0;
                float multiply_23 = ((length(IN.worldPosition.rb)-(_time * 0.25658)) * 5.0);
                o.emission = (vec3(max((1.0 - (abs((fract((multiply_23-0.5))-0.5)) / fwidth(multiply_23))), 0.0), max((1.0 - (abs((fract((multiply_23-0.5))-0.5)) / fwidth(multiply_23))), 0.0), max((1.0 - (abs((fract((multiply_23-0.5))-0.5)) / fwidth(multiply_23))), 0.0))*vec3(1.0, 0.3918, 0.0)*vec3(30.0, 30.0, 30.0));
                o.opacity = 1.1039;
                o.occlusion = 1.0;
            }
        ]]
    }
}
