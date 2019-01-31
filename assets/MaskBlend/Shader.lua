{
    name = "Mask Blend",

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
        _mask = { "texture2D", "Logo" },
        _normalA = { "texture2D", "LayeredRockWall_normal" },
        _normalB = { "texture2D", "FrozenTundra_normal" },
        _baseA = { "texture2D", "LayeredRockWall_basecolor" },
        _baseB = { "texture2D", "FrozenTundra_basecolor" },
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
            void vertex(inout Vertex v, out Input o)
            {
            }
        ]],

        surface =
        [[
            uniform lowp sampler2D _mask;
            uniform lowp sampler2D _normalA;
            uniform lowp sampler2D _normalB;
            uniform lowp sampler2D _baseA;
            uniform lowp sampler2D _baseB;
            // Source - https://stackoverflow.com/questions/5281261/generating-a-normal-map-from-a-height-map
            
            float sampleHeightN(vec2 uv)
            {
                return texture(_mask, uv).rgb.r;
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
                vec3 temp_6 = heightToNormal(IN.uv, 1.0, vec2(0.01, 0.01), vec2(0.0, 0.0));
                vec4 temp_Mask = texture(_mask, IN.uv);
                o.normal = perturbNormal2Arb( -IN.viewPosition, IN.normal, blendNormals(temp_6, mix(((texture(_normalA, IN.uv) * 2.0 - 1.0) * vec4(0.35855, 0.35855, 1.0, 1.0)).rgb, ((texture(_normalB, IN.uv) * 2.0 - 1.0) * vec4(0.25, 0.25, 1.0, 1.0)).rgb, temp_Mask.rgb)));
                o.emissive = 1.0;
                o.diffuse = mix(texture(_baseA, IN.uv).rgb, texture(_baseB, IN.uv).rgb, temp_Mask.rgb);
                o.roughness = 0.24342;
                o.metalness = 0.0;
                o.emission = vec3(0.0, 0.0, 0.0);
                o.opacity = 0.0;
                o.occlusion = 1.0;
            }
        ]]
    }
}
