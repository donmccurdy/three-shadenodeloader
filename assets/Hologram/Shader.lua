{
    name = "Hologram",

    options =
    {
        USE_COLOR = { true },
        SELECTION_MODE = { true },
    },

    properties =
    {
        _time = { "float", "0.0" },
    },

    pass =
    {
        base = "Surface",

        blendMode = "additive",
        depthWrite = false,
        depthFunc = "lessEqual",
        renderQueue = "transparent",
        colorMask = {"rgba"},
        cullFace = "back",

        vertex =
        [[
            uniform float _time;
            out vec3 vPosition;

            
            void vertex(inout Vertex v, out Input o)
            {
                v.position += (vec3(smoothstep(0.0, 0.2, distance(vec4(position.rgb,0.0).g, max((mod(_time, 5.0) - 2.0), -2.0))), 0.0, 0.0) * 0.1);
                vPosition = position;
            }
        ]],

        surface =
        [[
            in vec3 vPosition;
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
            
            
            void surface(in Input IN, inout SurfaceOutput o)
            {
                o.emissive = 1.0;
                o.diffuse = (remap(sin((vec4(vPosition.rgb,0.0).g*150.0+(_time * 5.0))), vec2(-1.0, 1.0).x, vec2(-1.0, 1.0).y, vec2(0.0, 0.8).x, vec2(0.0, 0.8).y) * vec3(0.0, 0.43129, 1.0));
                o.emission = vec3(0.0, 0.0, 0.0);
                o.opacity = 1.0;
            }
        ]]
    }
}
