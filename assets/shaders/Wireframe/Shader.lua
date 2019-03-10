{
    name = "Wireframe",

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
        _thickness = { "float", 0.32894736528397 },
        _smoothness = { "float", 1.0 },
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
            out vec3 vBarycentricCoord;
            void vertex(inout Vertex v, out Input o)
            {
                vBarycentricCoord = vec3(0.0, 0.0, 0.0);
                vBarycentricCoord[gl_VertexID % 3] = 1.0;
            }
        ]],

        surface =
        [[
            uniform float _thickness;
            in vec3 vBarycentricCoord;
            uniform float _smoothness;
            
            void surface(in Input IN, inout SurfaceOutput o)
            {
                o.emissive = 1.0;
                vec3 multiply_8 = (_thickness * fwidth(vBarycentricCoord));
                o.diffuse = vec3(min(min(vec4(smoothstep(multiply_8, (multiply_8+(fwidth(vBarycentricCoord) * _smoothness)), vBarycentricCoord).rgb,0.0).r, vec4(smoothstep(multiply_8, (multiply_8+(fwidth(vBarycentricCoord) * _smoothness)), vBarycentricCoord).rgb,0.0).g), vec4(smoothstep(multiply_8, (multiply_8+(fwidth(vBarycentricCoord) * _smoothness)), vBarycentricCoord).rgb,0.0).b), min(min(vec4(smoothstep(multiply_8, (multiply_8+(fwidth(vBarycentricCoord) * _smoothness)), vBarycentricCoord).rgb,0.0).r, vec4(smoothstep(multiply_8, (multiply_8+(fwidth(vBarycentricCoord) * _smoothness)), vBarycentricCoord).rgb,0.0).g), vec4(smoothstep(multiply_8, (multiply_8+(fwidth(vBarycentricCoord) * _smoothness)), vBarycentricCoord).rgb,0.0).b), min(min(vec4(smoothstep(multiply_8, (multiply_8+(fwidth(vBarycentricCoord) * _smoothness)), vBarycentricCoord).rgb,0.0).r, vec4(smoothstep(multiply_8, (multiply_8+(fwidth(vBarycentricCoord) * _smoothness)), vBarycentricCoord).rgb,0.0).g), vec4(smoothstep(multiply_8, (multiply_8+(fwidth(vBarycentricCoord) * _smoothness)), vBarycentricCoord).rgb,0.0).b));
                o.roughness = 0.32468;
                o.metalness = 0.0;
                o.emission = vec3(0.0, 0.0, 0.0);
                o.opacity = 1.0;
                o.occlusion = 1.0;
            }
        ]]
    }
}
