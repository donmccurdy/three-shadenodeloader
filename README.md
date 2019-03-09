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
