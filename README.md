# THREE.ShadeNodeLoader

![Status](https://img.shields.io/badge/status-experimental-orange.svg)
[![License](https://img.shields.io/badge/license-MIT-007ec6.svg)](https://github.com/donmccurdy/three-shadenodeloader/blob/master/LICENSE)

three.js loader for shaders created with Shade app for iOS.

```js
const loader = new ShadeNodeLoader();

const sceneTime = new TimerNode();

loader.setFactory( ( nodeDef ) => {

  switch ( nodeDef.class ) {

    case 'TimeNode':
      return sceneTime;

    default:
      throw new Error(`Unknown type: ${nodeDef.class}.`);

  }

} );

loader.load(

  'shaders/Dissolve/Graph.json',

  ( material ) => scene.add( new THREE.Mesh( new THREE.TorusKnotBufferGeometry(), material ) ),

  ( event ) => console.info( event ),

  ( error ) => console.error( error )

);
```
