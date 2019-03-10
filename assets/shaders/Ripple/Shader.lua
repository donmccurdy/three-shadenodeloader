{
    name = "Ripple",

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
        _texture = { "texture2D", "Lava Normals" },
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

            
            void vertex(inout Vertex v, out Input o)
            {
                float sin_4 = sin((distance(v.uv, vec2(0.5, 0.5))*50.0+_time));
                v.position += (vec3(0.0, sin_4, 0.0)*vec3(0.25, 0.25, 0.25));
            }
        ]],

        surface =
        [[
            uniform float _time;
            uniform lowp sampler2D _texture;
            
            // Source - https://stackoverflow.com/questions/5281261/generating-a-normal-map-from-a-height-map
            
            float sampleHeightN(vec2 uv)
            {
                return sin((distance(uv, vec2(0.5, 0.5))*50.0+_time));
            }
            
            vec3 heightToNormal(vec2 uv, float strength, vec2 texelSize, vec2 offset)
            {
                const vec2 size = vec2(2.0,0.0);
                const vec3 off = vec3(-1.0,0.0,1.0);
            
                vec2 delta = texelSize;
            
                float s11 = sampleHeightN(uv + offset);
                float s01 = sampleHeightN(uv + delta * off.xy + offset);
                float s21 = sampleHeightN(uv + delta * off.zy + offset);
                float s10 = sampleHeightN(uv + delta * off.yx + offset);
                float s12 = sampleHeightN(uv + delta * off.yz + offset);
            
                vec3 va = normalize(vec3(size.x, size.y, (s21-s01) * strength));
                vec3 vb = normalize(vec3(size.y, size.x, (s12-s10) * strength));
            
                return cross(va,vb);
            }
            
            
            // Source - http://blog.selfshadow.com/publications/blending-in-detail/
            vec3 blendNormals(vec3 n1, vec3 n2)
            {
                mat3 nBasis = mat3(
                    vec3(n1.z, n1.y, -n1.x), // +90 degree rotation around y axis
                    vec3(n1.x, n1.z, -n1.y), // -90 degree rotation around x axis
                    vec3(n1.x, n1.y,  n1.z));
            
                return normalize(n2.x*nBasis[0] + n2.y*nBasis[1] + n2.z*nBasis[2]);
            }
            
            void surface(in Input IN, inout SurfaceOutput o)
            {
                vec3 temp_7 = heightToNormal(IN.uv, 1.0414, vec2(0.01, 0.01), vec2(0.0, 0.0));
                o.normal = perturbNormal2Arb( -IN.viewPosition, IN.normal, blendNormals(temp_7, ((texture(_texture, (IN.uv * 5.0)) * 2.0 - 1.0) * vec4(0.085526, 0.085526, 1.0, 1.0)).rgb));
                o.emissive = 1.0;
                o.diffuse = vec3(1.0, 1.0, 1.0);
                o.roughness = 0.66118;
                o.metalness = 0.70479;
                o.emission = vec3(0.0, 0.0, 0.0);
                o.opacity = 1.1039;
                o.occlusion = 1.0;
            }
        ]]
    }
}
