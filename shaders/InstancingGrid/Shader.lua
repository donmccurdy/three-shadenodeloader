    {
        name = "Instancing Grid",

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
                
                
                //
                // GLSL textureless classic 2D noise "cnoise2D",
                // with an RSL-style periodic variant "pnoise".
                // Author:  Stefan Gustavson (stefan.gustavson@liu.se)
                // Version: 2011-08-22
                //
                // Many thanks to Ian McEwan of Ashima Arts for the
                // ideas for permutation and gradient selection.
                //
                // Copyright (c) 2011 Stefan Gustavson. All rights reserved.
                // Distributed under the MIT license. See LICENSE file.
                // https://github.com/ashima/webgl-noise
                //
                
                vec4 mod289(vec4 x)
                {
                  return x - floor(x * (1.0 / 289.0)) * 289.0;
                }
                
                vec4 permute(vec4 x)
                {
                  return mod289(((x*34.0)+1.0)*x);
                }
                
                vec4 taylorInvSqrt(vec4 r)
                {
                  return 1.79284291400159 - 0.85373472095314 * r;
                }
                
                vec2 fade(vec2 t) {
                  return t*t*t*(t*(t*6.0-15.0)+10.0);
                }
                
                // Classic Perlin noise
                float cnoise2D(vec2 P)
                {
                  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
                  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
                  Pi = mod289(Pi); // To avoid truncation effects in permutation
                  vec4 ix = Pi.xzxz;
                  vec4 iy = Pi.yyww;
                  vec4 fx = Pf.xzxz;
                  vec4 fy = Pf.yyww;
                
                  vec4 i = permute(permute(ix) + iy);
                
                  vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
                  vec4 gy = abs(gx) - 0.5 ;
                  vec4 tx = floor(gx + 0.5);
                  gx = gx - tx;
                
                  vec2 g00 = vec2(gx.x,gy.x);
                  vec2 g10 = vec2(gx.y,gy.y);
                  vec2 g01 = vec2(gx.z,gy.z);
                  vec2 g11 = vec2(gx.w,gy.w);
                
                  vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
                  g00 *= norm.x;
                  g01 *= norm.y;
                  g10 *= norm.z;
                  g11 *= norm.w;
                
                  float n00 = dot(g00, vec2(fx.x, fy.x));
                  float n10 = dot(g10, vec2(fx.y, fy.y));
                  float n01 = dot(g01, vec2(fx.z, fy.z));
                  float n11 = dot(g11, vec2(fx.w, fy.w));
                
                  vec2 fade_xy = fade(Pf.xy);
                  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
                  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
                  return 2.3 * n_xy;
                }
                
                

                void vertex(inout Vertex v, out Input o)
                {
                    float mod_2_1 = mod(float(gl_InstanceID), 10.0);
                    float remap_9_1 = remap(mod_2_1, vec2(0.0, 10.0).x, vec2(0.0, 10.0).y, vec2(-10.0, 10.0).x, vec2(-10.0, 10.0).y);
                    float subtract_5_1 = (float(gl_InstanceID) - mod_2_1);
                    float divide_6_1 = (subtract_5_1 / 10.0);
                    float divide_11_1 = (100.0 / 10.0);
                    float remap_8_1 = remap(divide_6_1, vec2(0.0, divide_11_1).x, vec2(0.0, divide_11_1).y, vec2(-10.0, 10.0).x, vec2(-10.0, 10.0).y);
                    float temp_14 = cnoise2D(((vec3(remap_9_1, 0.0, 0.0)+vec3(0.0, 0.0, remap_8_1)).rb+vec2((_time * 0.5), 0.0)));
                    v.position += ((vec3(remap_9_1, 0.0, 0.0)+vec3(0.0, 0.0, remap_8_1))+vec3(0.0, temp_14, 0.0));
                }
            ]],

            surface =
            [[



                void surface(in Input IN, inout SurfaceOutput o)
                {
                    o.emissive = 1.0;
                    o.diffuse = vec3(1.0, 0.62895, 0.0);
                    o.roughness = 0.59211;
                    o.metalness = 0.42434;
                    o.emission = vec3(0.0, 0.0, 0.0);
                    o.opacity = 1.0;
                    o.occlusion = 1.0;
                }
            ]]
        }
    }
    