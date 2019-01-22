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
