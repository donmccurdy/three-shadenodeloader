{
    name = "Grass",

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
        _range = { "vec2", {-3.0, 3.0} },
        __propPos_16 = { "vec3", {0, 0, 0} },
        _time = { "float", "0.0" },
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
            uniform vec2 _range;
            uniform vec3 _propPos_16;
            uniform float _time;

            

            float remap(float value, float minA, float maxA, float minB, float maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec2 remap(vec2 value, vec2 minA, vec2 maxA, vec2 minB, vec2 maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec3 remap(vec3 value, vec3 minA, vec3 maxA, vec3 minB, vec3 maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec4 remap(vec4 value, vec4 minA, vec4 maxA, vec4 minB, vec4 maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec2 remap(vec2 value, float minA, float maxA, float minB, float maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec3 remap(vec3 value, float minA, float maxA, float minB, float maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            vec4 remap(vec4 value, float minA, float maxA, float minB, float maxB)

            {

                return minB + (value - minA) * (maxB - minB) / (maxA - minA);

            }

            

            

            highp float random(vec2 co)

            {

                highp float a = 12.9898;

                highp float b = 78.233;

                highp float c = 43758.5453;

                highp float dt= dot(co.xy ,vec2(a,b));

                highp float sn= mod(dt,3.14);

                return fract(sin(sn) * c);

            }

            
            void vertex(inout Vertex v, out Input o)
            {
                float mod_2 = mod(float(gl_InstanceID), sqrt(400.0));
                vec3 add_15 = (vec3(vec2(random(vec3(remap(vec2(((float(gl_InstanceID) - mod_2) / sqrt(400.0)), mod_2), vec2(0.0, sqrt(400.0)).x, vec2(0.0, sqrt(400.0)).y, _range.x, _range.y).r, 0.0, remap(vec2(((float(gl_InstanceID) - mod_2) / sqrt(400.0)), mod_2), vec2(0.0, sqrt(400.0)).x, vec2(0.0, sqrt(400.0)).y, _range.x, _range.y).g).rb), random((vec2(42.33, 42.33)*vec3(remap(vec2(((float(gl_InstanceID) - mod_2) / sqrt(400.0)), mod_2), vec2(0.0, sqrt(400.0)).x, vec2(0.0, sqrt(400.0)).y, _range.x, _range.y).r, 0.0, remap(vec2(((float(gl_InstanceID) - mod_2) / sqrt(400.0)), mod_2), vec2(0.0, sqrt(400.0)).x, vec2(0.0, sqrt(400.0)).y, _range.x, _range.y).g).rg))).r, 0.0, vec2(random(vec3(remap(vec2(((float(gl_InstanceID) - mod_2) / sqrt(400.0)), mod_2), vec2(0.0, sqrt(400.0)).x, vec2(0.0, sqrt(400.0)).y, _range.x, _range.y).r, 0.0, remap(vec2(((float(gl_InstanceID) - mod_2) / sqrt(400.0)), mod_2), vec2(0.0, sqrt(400.0)).x, vec2(0.0, sqrt(400.0)).y, _range.x, _range.y).g).rb), random((vec2(42.33, 42.33)*vec3(remap(vec2(((float(gl_InstanceID) - mod_2) / sqrt(400.0)), mod_2), vec2(0.0, sqrt(400.0)).x, vec2(0.0, sqrt(400.0)).y, _range.x, _range.y).r, 0.0, remap(vec2(((float(gl_InstanceID) - mod_2) / sqrt(400.0)), mod_2), vec2(0.0, sqrt(400.0)).x, vec2(0.0, sqrt(400.0)).y, _range.x, _range.y).g).rg))).g) + vec3(remap(vec2(((float(gl_InstanceID) - mod_2) / sqrt(400.0)), mod_2), vec2(0.0, sqrt(400.0)).x, vec2(0.0, sqrt(400.0)).y, _range.x, _range.y).r, 0.0, remap(vec2(((float(gl_InstanceID) - mod_2) / sqrt(400.0)), mod_2), vec2(0.0, sqrt(400.0)).x, vec2(0.0, sqrt(400.0)).y, _range.x, _range.y).g));
                vec3 localVar_GrassPosition = add_15;
                float localVar_GrassBendFactor = pow(v.uv.y, 2.0);
                v.position += (add_15+((localVar_GrassPosition - _propPos_16) * ((1.0 - smoothstep(1.0, 2.0, distance(localVar_GrassPosition, _propPos_16)))*localVar_GrassBendFactor))+(localVar_GrassBendFactor * (sin((localVar_GrassPosition*vec3(0.5, 0.5, 0.5)+vec3(_time, _time, _time))) * vec3(0.2, 0.0, 0.2))));
            }
        ]],

        surface =
        [[
            void surface(in Input IN, inout SurfaceOutput o)
            {
                o.emissive = 1.0;
                o.diffuse = (vec3(1.0, 0.0, 0.54083) * IN.uv.y);
                o.roughness = 1.0;
                o.metalness = 0.0;
                o.emission = vec3(0.0, 0.0, 0.0);
                o.opacity = 1.0;
                o.occlusion = 1.0;
            }
        ]]
    }
}
