    {
        name = "Dissolve",

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
            _edgeColor = { "vec3", {0.0, 0.27863919734955, 1.0} },
            _edgeGlow = { "float", 20.0 },
            _edgeWidth = { "float", 0.029999999329448 },
            _time = { "float", "0.0" },
            _gradient = { "texture2D", "Gradient" },
            _noiseScale = { "float", 2.0 },
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
                    v.position += vec3(0.0, 0.1, 0.0);
                }
            ]],

            surface =
            [[
                uniform vec3 _edgeColor;
                uniform float _edgeGlow;
                uniform float _edgeWidth;
                uniform float _time;
                uniform lowp sampler2D _gradient;
                uniform float _noiseScale;


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
                // Description : Array and textureless GLSL 2D/3D/4D simplex
                //               noise functions.
                //      Author : Ian McEwan, Ashima Arts.
                //  Maintainer : ijm
                //     Lastmod : 20110822 (ijm)
                //     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
                //               Distributed under the MIT License. See LICENSE file.
                //               https://github.com/ashima/webgl-noise
                //
                
                vec3 mod289(vec3 x) {
                  return x - floor(x * (1.0 / 289.0)) * 289.0;
                }
                
                vec4 mod289(vec4 x) {
                  return x - floor(x * (1.0 / 289.0)) * 289.0;
                }
                
                vec4 permute(vec4 x) {
                     return mod289(((x*34.0)+1.0)*x);
                }
                
                vec4 taylorInvSqrt(vec4 r)
                {
                  return 1.79284291400159 - 0.85373472095314 * r;
                }
                
                float snoise3D(vec3 v)
                  {
                  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
                  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);
                
                // First corner
                  vec3 i  = floor(v + dot(v, C.yyy) );
                  vec3 x0 =   v - i + dot(i, C.xxx) ;
                
                // Other corners
                  vec3 g = step(x0.yzx, x0.xyz);
                  vec3 l = 1.0 - g;
                  vec3 i1 = min( g.xyz, l.zxy );
                  vec3 i2 = max( g.xyz, l.zxy );
                
                  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
                  //   x1 = x0 - i1  + 1.0 * C.xxx;
                  //   x2 = x0 - i2  + 2.0 * C.xxx;
                  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
                  vec3 x1 = x0 - i1 + C.xxx;
                  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
                  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y
                
                // Permutations
                  i = mod289(i);
                  vec4 p = permute( permute( permute(
                             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
                           + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
                           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));
                
                // Gradients: 7x7 points over a square, mapped onto an octahedron.
                // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
                  float n_ = 0.142857142857; // 1.0/7.0
                  vec3  ns = n_ * D.wyz - D.xzx;
                
                  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)
                
                  vec4 x_ = floor(j * ns.z);
                  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)
                
                  vec4 x = x_ *ns.x + ns.yyyy;
                  vec4 y = y_ *ns.x + ns.yyyy;
                  vec4 h = 1.0 - abs(x) - abs(y);
                
                  vec4 b0 = vec4( x.xy, y.xy );
                  vec4 b1 = vec4( x.zw, y.zw );
                
                  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
                  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
                  vec4 s0 = floor(b0)*2.0 + 1.0;
                  vec4 s1 = floor(b1)*2.0 + 1.0;
                  vec4 sh = -step(h, vec4(0.0));
                
                  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
                  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;
                
                  vec3 p0 = vec3(a0.xy,h.x);
                  vec3 p1 = vec3(a0.zw,h.y);
                  vec3 p2 = vec3(a1.xy,h.z);
                  vec3 p3 = vec3(a1.zw,h.w);
                
                //Normalise gradients
                  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
                  p0 *= norm.x;
                  p1 *= norm.y;
                  p2 *= norm.z;
                  p3 *= norm.w;
                
                // Mix final noise value
                  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
                  m = m * m;
                  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
                                                dot(p2,x2), dot(p3,x3) ) );
                  }
                
                
                float turb_snoise3D (in vec3 st, in int octaves, in float lacunarity, in float gain)
                {
                    // Initial values
                    float value = 0.0;
                    float amplitude = .5;
                    float frequency = 0.;
                    //
                    // Loop of octaves
                    for (int i = 0; i < octaves; i++) {
                        value += amplitude * abs(snoise3D(st));
                        st *= lacunarity;
                        amplitude *= gain;
                    }
                    return value;
                }
                

                void surface(in Input IN, inout SurfaceOutput o)
                {
                    o.emissive = 1.0;
                    o.diffuse = vec3(0.5, 0.5, 0.5);
                    o.roughness = 0.32237;
                    o.metalness = 1.0;
                    float remap_8_1 = remap(sin(_time), vec2(-1.0, 1.0).x, vec2(-1.0, 1.0).y, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y);
                    float localVar_Progression = remap_8_1;
                    vec4 temp_Gradient = texture(_gradient, vec2(remap(IN.worldPosition, vec2(0.0, 2.0).x, vec2(0.0, 2.0).y, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y).g, 0.0));
                    float temp_3 = turb_snoise3D((IN.worldPosition*vec3(_noiseScale, _noiseScale, _noiseScale)), 2, 3.000000, 0.500000);
                    float remap_2_1 = remap(temp_3, vec2(-1.0, 1.0).x, vec2(-1.0, 1.0).y, vec2(0.0, 1.0).x, vec2(0.0, 1.0).y);
                    vec3 multiply_11_1 = (temp_Gradient.rgb * remap_2_1);
                    vec3 step_6_1 = step((_edgeWidth+localVar_Progression), multiply_11_1);
                    vec3 oneminus_7_1 = (1.0 - step_6_1);
                    vec3 multiply_9_1 = ((_edgeColor*vec3(_edgeGlow, _edgeGlow, _edgeGlow)) * oneminus_7_1);
                    o.emission = multiply_9_1;
                    o.opacity = multiply_11_1.r;
                    o.occlusion = 1.0;
                    if (o.opacity < localVar_Progression) discard;
                }
            ]]
        }
    }
    