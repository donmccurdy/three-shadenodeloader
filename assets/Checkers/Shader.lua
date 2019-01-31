{
    name = "Checkers",

    options =
    {
        DOUBLE_SIDED = { true },
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
        _colorA = { "vec3", {0.0, 0.0, 0.0} },
        _colorB = { "vec3", {1.0, 0.75297492742538, 0.0} },
        _size = { "float", 8.0 },
    },

    pass =
    {
        base = "Surface",

        blendMode = "disabled",
        depthWrite = true,
        depthFunc = "lessEqual",
        renderQueue = "solid",
        colorMask = {"rgba"},
        cullFace = "none",

        vertex =
        [[
            void vertex(inout Vertex v, out Input o)
            {
            }
        ]],

        surface =
        [[
            uniform vec3 _colorA;
            uniform vec3 _colorB;
            uniform float _size;
            
            void surface(in Input IN, inout SurfaceOutput o)
            {
                o.emissive = 1.0;
                o.diffuse = mix(_colorA, _colorB, mod((vec4(floor((IN.uv * vec2(_size, _size))).rg,0.0,0.0).r + vec4(floor((IN.uv * vec2(_size, _size))).rg,0.0,0.0).g), 2.0));
                o.roughness = 0.43421;
                o.metalness = 0.0;
                o.emission = vec3(0.0, 0.0, 0.0);
                o.opacity = 1.1039;
                o.occlusion = 1.0;
            }
        ]]
    }
}
