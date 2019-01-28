🚨 In development

# THREE.ShadeLoader

![Status](https://img.shields.io/badge/status-experimental-orange.svg)
[![License](https://img.shields.io/badge/license-MIT-007ec6.svg)](https://github.com/donmccurdy/three-shadeloader/blob/master/LICENSE)

three.js loader for shaders created with Shade app for iOS.

```js
  const loader = new ShadeLoader();

  loader.load(

    'shaders/Dissolve/Graph.json',

    ( material ) => {

      const mesh = new THREE.Mesh( new THREE.TorusKnotBufferGeometry(), material );

      scene.add( mesh );

    },

    ( event ) => console.info( event ),

    ( error ) => console.error( error )

  );
```

## Issues

### alphaTest is a macro

Take the "dissolve" effect described in [this article](http://glowfishinteractive.com/dissolving-the-world-part-2/):

![dissolvetheworld_part02_03_proceduraldissolvespecial_small](https://user-images.githubusercontent.com/1848368/51575747-353af880-1e68-11e9-8852-eebcaa14fa1a.gif)

We'd like to animate `.alphaTest` over time as the object dissolves. It would be natural to try:

```js
var material = new StandardNodeMaterial();
material.alphaTest = new Math1Node( new TimerNode(), Math1Node.SIN );
```

... or, better, drive alphaTest with a noise function. However, `.alphaTest` cannot be derived procedurally.

### TimerNode doesn't update

TimerNode has an `updateFrame()` method that I assumed would be automatically called, setting current time, but it isn't. What's the usage here?

### Function calls with dependencies

A typical noise function may call other functions, or have overloaded versions of itself with different parameter types. The regex that parses function source for a function name breaks on this and returns `''`. Is there a safe way to import a library of noise functions?

### TextureNode 'uv' parameter

Maybe this parameter should be named 'coord' rather than 'uv', to indicate that it doesn't need to be a UVNode instance. It doesn't, right?

### Add a RemapNode type

Would be helpful to simplify node trees, in these examples at least.

### Debugging tools

Full visual editor would be awesome, of course, but short of that I would love to have some basic debugging tools. For example: (1) print a dependency graph, (2) display value of a given node as a 2D texture.

### Organizing math nodes by number of parameters

This isn't intuitive; found myself making mistakes with this often. If there's no conceptual way to organize them, can we just have a single MathNode that accepts a variable number of parameters?

### Assigning PositionNode gives warnings

```
three.js:17264 THREE.WebGLProgram: gl.getProgramInfoLog() WARNING: Output of vertex shader 'vPosition' not read by fragment shader
```

### Could use an unlit node

e.g. BasicNodeMaterial.
