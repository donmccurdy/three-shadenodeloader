# THREE.ShadeLoader

three.js loader for shader graphs from the Shade for iOS app.

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

It could be helpful if .alphaTest's value were be a uniform. Take a "dissolve" effect as described in [this article](http://glowfishinteractive.com/dissolving-the-world-part-2/):

![dissolvetheworld_part02_03_proceduraldissolvespecial_small](https://user-images.githubusercontent.com/1848368/51575747-353af880-1e68-11e9-8852-eebcaa14fa1a.gif)

We'd like to animate the `.alphaTest` value over time, as the object dissolves. As for other NodeMaterial properties, it would be natural to try something roughly like this:

```js
var material = new StandardNodeMaterial();
material.alphaTest = new Math1Node( new TimerNode(), Math1Node.SIN );
```

... or, better, drive alphaTest with our noise function. However, `.alphaTest` cannot be derived procedurally.

### TimerNode doesn't update

TimerNode has an `updateFrame()` method that I assumed would be automatically called, but it isn't. What's the correct usage here?

### Function calls with dependencies

A typical noise function may call other functions, or have overloaded versions of itself with different parameter types. The regex that parses function source for a function name breaks on this and returns `''`. Is there a safe way to import a library of noise functions?

### TextureNode 'uv' parameter

Maybe this parameter should be named 'coord' rather than 'uv', to indicate that it doesn't need to be a UVNode instance. It doesn't, right?

### Add a RemapNode type

Would be helpful to simplify node trees, in these examples at least.

### Debugging tools

Full visual editor would be awesome, of course, but short of that I would love to have some humble debugging tools. For example: (1) print a connectivity graph, or something like it, (2) display value of a given node as a 2D texture.