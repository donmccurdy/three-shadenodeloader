# THREE.ShadeNodeLoader

![Status](https://img.shields.io/badge/status-experimental-orange.svg)
[![License](https://img.shields.io/badge/license-MIT-007ec6.svg)](https://github.com/donmccurdy/three-shadenodeloader/blob/master/LICENSE)

three.js loader for shaders created with Shade app for iOS.

```js
const loader = new ShadeNodeLoader();

const sceneTime = new TimerNode();

// Some node types (time, microphone input, props, etc.) need to be
// provided by the application. Use the `.setFactory()` method to configure
// a callback for creating these nodes.
loader.setFactory( ( nodeDef ) => {

  switch ( nodeDef.class ) {

    case 'TimeNode':
      return sceneTime;

    default:
      throw new Error(`Unknown type: ${nodeDef.class}.`);

  }

} );

// The load callback returns a THREE.NodeMaterial instance, ready to be
// used in a mesh. Additional properties created by the loader may be
// visible in `material.userData`, such as:
// - needsDerivatives: Derivatives must be enabled on the material.
// - needsBarycentric: Barycentric coordinates must be added to the geometry.
// - instanceCount: Requires a THREE.InstanceBufferGeometry with the given count.
loader.load(

  'shaders/Dissolve/Graph.json',

  ( material ) => scene.add( new THREE.Mesh( new THREE.TorusKnotBufferGeometry(), material ) ),

  ( event ) => console.info( event ),

  ( error ) => console.error( error )

);
```
