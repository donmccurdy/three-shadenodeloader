{
    name = "Explosion",

    options =
    {
        USE_COLOR = { true },
        SELECTION_MODE = { true },
    },

    properties =
    {
        _time = { "float", "0.0" },
        _colorMap = { "texture2D", "Color Map" },
        _clipGradient = { "texture2D", "Clip Gradient" },
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
            out vec3 vNormal;

            

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

            

            

            const mat2 myt = mat2(.12121212, .13131313, -.13131313, .12121212);

            const vec2 mys = vec2(1e4, 1e6);

            

            vec2 rhash(vec2 uv) {

              uv *= myt;

              uv *= mys;

              return fract(fract(uv / mys) * uv);

            }

            

            vec3 hash(vec3 p) {

              return fract(

                  sin(vec3(dot(p, vec3(1.0, 57.0, 113.0)), dot(p, vec3(57.0, 113.0, 1.0)),

                           dot(p, vec3(113.0, 1.0, 57.0)))) *

                  43758.5453);

            }

            

            vec3 voronoi3D(const in vec3 x) {

              vec3 p = floor(x);

              vec3 f = fract(x);

            

              float id = 0.0;

              vec2 res = vec2(100.0);

              for (int k = -1; k <= 1; k++) {

                for (int j = -1; j <= 1; j++) {

                  for (int i = -1; i <= 1; i++) {

                    vec3 b = vec3(float(i), float(j), float(k));

                    vec3 r = vec3(b) - f + hash(p + b);

                    float d = dot(r, r);

            

                    float cond = max(sign(res.x - d), 0.0);

                    float nCond = 1.0 - cond;

            

                    float cond2 = nCond * max(sign(res.y - d), 0.0);

                    float nCond2 = 1.0 - cond2;

            

                    id = (dot(p + b, vec3(1.0, 57.0, 113.0)) * cond) + (id * nCond);

                    res = vec2(d, res.x) * cond + res * nCond;

            

                    res.y = cond2 * d + nCond2 * res.y;

                  }

                }

              }

            

              return vec3(sqrt(res), abs(id));

            }

            
            void vertex(inout Vertex v, out Input o)
            {
                float localVar_ExplosionTime = sqrt(min(mod((_time * 0.75), 2.0), 2.5));
                float oneminus_8 = (1.0 - vec4(voronoi3D(((v.normal * remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(0.5, 1.3).x, vec2(0.5, 1.3).y))+vec3(0.0, (localVar_ExplosionTime * 4.0), 0.0))).rgb,0.0).r);
                vec3 normalize_38 = normalize((modelMatrix * vec4(v.normal, 0.0)).xyz);
                v.position += (((sqrt(oneminus_8) * normalize_38) * remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(-2.0, 6.0).x, vec2(-2.0, 6.0).y))+((normalize_38 * localVar_ExplosionTime) * (v.uv.y*3.0)));
                vNormal = normal;
            }
        ]],

        surface =
        [[
            uniform float _time;
            in vec3 vNormal;
            uniform lowp sampler2D _colorMap;
            uniform lowp sampler2D _clipGradient;
            
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
            
            
            const mat2 myt = mat2(.12121212, .13131313, -.13131313, .12121212);
            const vec2 mys = vec2(1e4, 1e6);
            
            vec2 rhash(vec2 uv) {
              uv *= myt;
              uv *= mys;
              return fract(fract(uv / mys) * uv);
            }
            
            vec3 hash(vec3 p) {
              return fract(
                  sin(vec3(dot(p, vec3(1.0, 57.0, 113.0)), dot(p, vec3(57.0, 113.0, 1.0)),
                           dot(p, vec3(113.0, 1.0, 57.0)))) *
                  43758.5453);
            }
            
            vec3 voronoi3D(const in vec3 x) {
              vec3 p = floor(x);
              vec3 f = fract(x);
            
              float id = 0.0;
              vec2 res = vec2(100.0);
              for (int k = -1; k <= 1; k++) {
                for (int j = -1; j <= 1; j++) {
                  for (int i = -1; i <= 1; i++) {
                    vec3 b = vec3(float(i), float(j), float(k));
                    vec3 r = vec3(b) - f + hash(p + b);
                    float d = dot(r, r);
            
                    float cond = max(sign(res.x - d), 0.0);
                    float nCond = 1.0 - cond;
            
                    float cond2 = nCond * max(sign(res.y - d), 0.0);
                    float nCond2 = 1.0 - cond2;
            
                    id = (dot(p + b, vec3(1.0, 57.0, 113.0)) * cond) + (id * nCond);
                    res = vec2(d, res.x) * cond + res * nCond;
            
                    res.y = cond2 * d + nCond2 * res.y;
                  }
                }
              }
            
              return vec3(sqrt(res), abs(id));
            }
            
            void surface(in Input IN, inout SurfaceOutput o)
            {
                o.emissive = 1.0;
                float localVar_ExplosionTime = sqrt(min(mod((_time * 0.75), 2.0), 2.5));
                vec4 temp_ColorMap = texture(_colorMap, vec2((localVar_ExplosionTime-((1.0 - localVar_ExplosionTime) * vec4(voronoi3D(((normalize(vNormal) * remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(0.5, 1.3).x, vec2(0.5, 1.3).y))+vec3(0.0, (localVar_ExplosionTime * 4.0), 0.0))).rgb,0.0).r)), 0.0));
                o.diffuse = temp_ColorMap.rgb;
                o.emission = clamp((temp_ColorMap.rgb - 0.5), 0.0, 1.0);
                float oneminus_8 = (1.0 - vec4(voronoi3D(((normalize(vNormal) * remap(localVar_ExplosionTime, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y, vec2(0.5, 1.3).x, vec2(0.5, 1.3).y))+vec3(0.0, (localVar_ExplosionTime * 4.0), 0.0))).rgb,0.0).r);
                o.opacity = (oneminus_8 * 1.0);
                if (o.opacity < texture(_clipGradient, vec2(localVar_ExplosionTime, 0.0)).rgb.r) discard;
            }
        ]]
    }
}
