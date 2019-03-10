# Issues

## Custom nodes

Ideally:

- BlendNormalsNode
- HeightToNormalNode
- RemapNode
- Noise2DNode
- Noise3DNode
- UnlitNodeMaterial

## TimerNode doesn't update

TimerNode has an `updateFrame()` method that I assumed would be automatically called, setting current time, but it isn't. What's the usage here?

## Function calls with dependencies

A typical noise function may call other functions, or have overloaded versions of itself with different parameter types. The regex that parses function source for a function name breaks on this and returns `''`. Is there a safe way to import a library of noise functions?

## TextureNode 'uv' parameter

Maybe this parameter should be named 'coord' rather than 'uv', to indicate that it doesn't need to be a UVNode instance. It doesn't, right?

## Debugging tools

Full visual editor would be awesome, of course, but short of that I would love to have some basic debugging tools. For example: (1) print a dependency graph, (2) display value of a given node as a 2D texture.

## Organizing math nodes by number of parameters

This isn't intuitive; found myself making mistakes with this often. If there's no conceptual way to organize them, can we just have a single MathNode that accepts a variable number of parameters?

## Assigning PositionNode gives warnings

```
three.js:17264 THREE.WebGLProgram: gl.getProgramInfoLog() WARNING: Output of vertex shader 'vPosition' not read by fragment shader
```

## TextureNode assumes v4

Struggling to get around:

```
ERROR: 0:768: 'assign' : cannot convert from 'highp 4-component vector of float' to 'highp 3-component vector of float'
```

Maybe this is baked into ColorSpaceNode? See hack in BlendNormalsNode...
