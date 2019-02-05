import {
  // core

  InputNode,
  ConstNode,
  VarNode,
  StructNode,
  AttributeNode,
  FunctionNode,
  ExpressionNode,
  FunctionCallNode,

  // inputs

  IntNode,
  FloatNode,
  Vector2Node,
  Vector3Node,
  Vector4Node,
  ColorNode,
  Matrix3Node,
  Matrix4Node,
  TextureNode,
  CubeTextureNode,
  ScreenNode,
  ReflectorNode,
  PropertyNode,
  RTTNode,

  // accessors

  UVNode,
  ColorsNode,
  PositionNode,
  NormalNode,
  CameraNode,
  LightNode,
  ReflectNode,
  ScreenUVNode,
  ResolutionNode,

  // math

  Math1Node,
  Math2Node,
  Math3Node,
  OperatorNode,
  CondNode,

  // procedural

  NoiseNode,
  CheckerNode,

  // utils

  BypassNode,
  JoinNode,
  SwitchNode,
  TimerNode,

  // materials

  StandardNodeMaterial

} from './node_modules/three/examples/js/nodes/Nodes.js';

import { Noise2DNode } from './nodes/Noise2DNode.js';
import { Noise3DNode } from './nodes/Noise3DNode.js';
import { RemapNode } from './nodes/RemapNode.js';

const CombineMode = {
  EQUALS: 1,
  ADD: 2,
  SUBTRACT: 3,
  MULTIPLY: 4,
  DIVIDE: 5
};

class ShadeLoader {

  constructor ( manager ) {

    this.manager = manager;

  }

  load ( url, onLoad, onProgress, onError ) {

    fetch( url )
      .then( ( response ) => response.json() )
      .then( ( json ) => this.parse( json, onLoad, onError ) )
      .catch( onError );

  }

  parse ( json, onLoad, onError ) {

    if ( json.version !== 3 ) {

      console.warn( '[THREE.ShadeLoader] Tested only against Shade format v3. Older or newer versions may not work correctly.' );

    }

    const nodeCache = {};
    const dependencies = {};
    const timerNodes = [];
    const instanceCountNodes = [];
    let needsDerivatives = false;

    const ZERO = new FloatNode( 0.0 )
      .setLabel('ZERO')
      .setReadonly(true);
    const ONE = new FloatNode( 1.0 )
      .setLabel('ONE')
      .setReadonly(true);

    function createNode ( nodeID ) {

      if ( nodeCache[ nodeID ] ) return nodeCache[ nodeID ];

      const nodeDef = json.nodes.find( ( def ) => def.id === nodeID );

      return nodeCache[nodeID] = new Promise( ( resolve ) => {

        const pendingDeps = ( dependencies[ nodeID ] || [] ).map( ( [ leftID ] ) => createNode( leftID ) );

        resolve( Promise.all( pendingDeps ) );

      } )
      .then( ( deps ) => {

        const inputs = {};

        deps.forEach( ( dep, depIndex ) => {

          const [ leftID, leftProp, rightID, rightProp, swizzle, mode ] = dependencies[ nodeID ][ depIndex ];

          if ( leftProp === 'sinTime' ) dep = new Math1Node( dep, Math1Node.SIN );
          if ( leftProp === 'cosTime' ) dep = new Math1Node( dep, Math1Node.COS );
          if ( leftProp === 'r' ) dep = new SwitchNode( dep, 'r' );
          if ( leftProp === 'g' ) dep = new SwitchNode( dep, 'g' );
          if ( leftProp === 'b' ) dep = new SwitchNode( dep, 'b' );

          if ( swizzle ) {

            const { r, g, b, sizeOut } = swizzle;
            const sizeIn = ( r ? 1 : 0 ) + ( g ? 1 : 0 ) + ( b ? 1 : 0 );
            const components = [];

            if ( sizeIn > 1 ) {

              if ( r ) r.forEach( ( c, i ) => ( components[ 'rgb'.indexOf( c ) ] = 'r' ) );
              if ( g ) g.forEach( ( c, i ) => ( components[ 'rgb'.indexOf( c ) ] = 'g' ) );
              if ( b ) b.forEach( ( c, i ) => ( components[ 'rgb'.indexOf( c ) ] = 'b' ) );

              dep = new SwitchNode( dep, components.join('') );

            } else {

              dep = new JoinNode(
                r.indexOf( 'r' ) >= 0 ? dep : ZERO,
                r.indexOf( 'g' ) >= 0 ? dep : ZERO,
                sizeOut > 2 ? ( r.indexOf( 'b' ) >= 0 ? dep : ZERO ) : undefined
              );

            }

          }

          // Two connections can target the same node input property. It appears that the second
          // occurrence contains an operator >1, specifying how to modify the existing value.
          switch ( mode ) {

            case CombineMode.EQUALS:
              if ( inputs[ rightProp ] ) console.warn( `[THREE.ShadeLoader] Overwriting ".${rightProp}".` );
              inputs[ rightProp ] = dep;
              break;

            case CombineMode.ADD:
              inputs[ rightProp ] = new OperatorNode( inputs[ rightProp ], dep, OperatorNode.ADD );
              break;

            case CombineMode.SUBTRACT:
              inputs[ rightProp ] = new OperatorNode( inputs[ rightProp ], dep, OperatorNode.SUB );
              break;

            case CombineMode.MULTIPLY:
              inputs[ rightProp ] = new OperatorNode( inputs[ rightProp ], dep, OperatorNode.MUL );
              break;

            case CombineMode.DIVIDE:
              inputs[ rightProp ] = new OperatorNode( inputs[ rightProp ], dep, OperatorNode.DIV );
              break;

            default:
              console.warn( `[THREE.ShadeLoader] Unknown combine mode "${mode}" for socket ".${rightProp}".` );

          }

        } );

        let node;
        let skipped = false;

        switch ( nodeDef.class ) {
          case 'SurfaceNode':
            node = new StandardNodeMaterial();
            node.position = new OperatorNode(
              new PositionNode(),
              createParameter( nodeDef, inputs, 'offset' ),
              OperatorNode.ADD
            );
            node.color = createParameter( nodeDef, inputs, 'diffuse' );
            node.mask = new CondNode(
              createParameter( nodeDef, inputs, 'opacity' ),
              createParameter( nodeDef, inputs, 'opacityClip' ),
              CondNode.GREATER
            );
            node.emissive = createParameter( nodeDef, inputs, 'emissionColor' );
            node.roughness = createParameter( nodeDef, inputs, 'rough' );
            node.metalness = createParameter( nodeDef, inputs, 'metallic' );
            node.ao = createParameter( nodeDef, inputs, 'occlusion' );
            if ( nodeDef.options.blendMode === 'additive' ) {
              node.blending = THREE.AdditiveBlending;
            } else if ( nodeDef.options.blendMode === 'multiply' ) {
              node.blending = THREE.MultiplyBlending;
            }
            node.side = nodeDef.cullFace === 'none' ? THREE.DoubleSide : THREE.FrontSide;
            break;

          case 'PropNode':
            // TODO(donmccurdy): Include visible properties?
            node = new Vector3Node(
              nodeDef.options.position[ 0 ],
              nodeDef.options.position[ 1 ],
              nodeDef.options.position[ 2 ]
            );
            break;

          case 'ColorNode':
            node = new ColorNode( new THREE.Color().fromArray ( nodeDef.inputs.value.value ) );
            break;

          case 'RelayNode':
          case 'Vector2DNode':
          case 'Vector3DNode':
          case 'CreateLocalVarNode':
            node = createParameter( nodeDef, inputs, 'value' );
            break;

          case 'GetLocalVarNode':
            const decl = json.nodes.find( ( def ) => {
              return def.class === 'CreateLocalVarNode'
                && def.options.userLabel === nodeDef.options.localVarName;
            } );
            node = createNode( decl.id );
            break;

          case 'GradientNode':
            const canvas = document.createElement( 'canvas' );
            canvas.width = 256;
            canvas.height = 16;

            // debug
            canvas.style.position = 'absolute';
            canvas.style.top = '1em';
            canvas.style.left = '1em';
            document.body.appendChild( canvas );

            const ctx = canvas.getContext( '2d' );
            const { startPos, endPos } = nodeDef.options;
            const sx = canvas.width / ( endPos[ 0 ] - startPos[ 0 ] );
            const sy = 1; // canvas.height / ( endPos[ 1 ] - startPos[ 1 ] );
            const gradient = ctx.createLinearGradient( sx * startPos[ 0 ], sy * startPos[ 1 ], sx * endPos[ 0 ], sy * endPos[ 1 ] );

            for ( let i = 0; i < nodeDef.options.value.colors.length; ++ i ) {

              const color = new THREE.Color().fromArray( nodeDef.options.value.colors[ i ].map( ( v ) => v / 256 ) );
              const stop = nodeDef.options.value.stops[ i ];
              gradient.addColorStop( stop, color.getStyle() );

            }

            ctx.fillStyle = gradient;
            ctx.fillRect( 0, 0, 256, 16 );

            const texture = new THREE.CanvasTexture( canvas );
            texture.wrapS = texture.wrapT = THREE.RepeatWrapping;
            const coord = createParameter( nodeDef, inputs, 'coord' );
            node = new TextureNode( texture, coord );
            break;

          case 'GroupNode':
            skipped = true;
            break;

          case 'AddNode':
            node = new OperatorNode(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              OperatorNode.ADD
            );
            break;

          case 'SubtractNode':
            node = new OperatorNode(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              OperatorNode.SUB
            );
            break;

          case 'MultiplyNode':
            node = new OperatorNode(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              OperatorNode.MUL
            );
            break;

          case 'DivideNode':
            node = new OperatorNode(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              OperatorNode.DIV
            );
            break;

          case 'Noise2DNode':
            // TODO(donmccurdy): Shade Noise2D has additional options.
            // TODO(donmccurdy): Set 'repeat' on the noise?
            node = new Noise2DNode( createParameter( nodeDef, inputs, 'position' ) );
            break;

          case 'Noise3DNode':
            // TODO(donmccurdy): Shade Noise3D has additional options.
            const lacunarity = new FloatNode( nodeDef.options.lacunarity );
            const gain = new FloatNode( nodeDef.options.gain );
            lacunarity.readonly = gain.readonly = true;
            node = new Noise3DNode( createParameter( nodeDef, inputs, 'position' ), lacunarity, gain );
            break;

          case 'NumberNode':
          case 'SliderNode':
            node = createParameter( nodeDef, inputs, 'value' );
            break;

          case 'OneMinusNode':
            node = new OperatorNode(
              new FloatNode( 1.0 ),
              createParameter( nodeDef, inputs, 'arg1' ),
              OperatorNode.SUB
            );
            break;

          case 'PositionNode':
            node = new PositionNode( nodeDef.options.space === 'world' ? PositionNode.WORLD : PositionNode.LOCAL );
            break;

          case 'NormalNode':
            node = new NormalNode();
            break;

          case 'UVNode':
            node = new UVNode();
            const tiling = createParameter( nodeDef, inputs, 'tiling' );
            if ( tiling.x !== 1 || tiling.y !== 1 ) {
              node = new OperatorNode( node, tiling, OperatorNode.MUL );
            }
            const offset = createParameter( nodeDef, inputs, 'offset' );
            if ( offset.x !== 0 || offset.y !== 0 ) {
              node = new OperatorNode( node, offset, OperatorNode.ADD );
            }
            break;

          case 'RemapNode':
            node = new RemapNode(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              createParameter( nodeDef, inputs, 'arg3' ),
            );
            break;

          case 'StepNode':
            node = new Math2Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              Math2Node.STEP
            );
            break;


          case 'PowNode':
            node = new Math2Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              Math2Node.POW
            );
            break;

          case 'TimeNode':
            node = new TimerNode( 1.0 );
            timerNodes.push( node );
            break;

          case 'SplitNode':
            node = createParameter( nodeDef, inputs, 'value' );
            break;

          case 'CombineNode':
            node = new JoinNode(
              createParameter( nodeDef, inputs, 'valueX' ),
              createParameter( nodeDef, inputs, 'valueY' ),
              createParameter( nodeDef, inputs, 'valueZ' ),
              createParameter( nodeDef, inputs, 'valueW' ),
            );
            break;

          case 'ModNode':
            node = new Math2Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              Math2Node.MOD
            );
            break;

          case 'SinNode':
            node = new Math1Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              Math1Node.SIN
            );
            break;

          case 'CosNode':
            node = new Math1Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              Math1Node.COS
            );
            break;

          case 'FloorNode':
            node = new Math1Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              Math1Node.FLOOR
            );
            break;

          case 'CeilNode':
            node = new Math1Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              Math1Node.CEIL
            );
            break;

          case 'SqrtNode':
            node = new Math1Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              Math1Node.SQRT
            );
            break;

          case 'LengthNode':
            node = new Math1Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              Math1Node.LENGTH
            );
            break;

          case 'FractNode':
            node = new Math1Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              Math1Node.FRACT
            );
            break;

          case 'AbsNode':
            node = new Math1Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              Math1Node.ABS
            );
            break;

          case 'MaxNode':
            node = new Math2Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              Math2Node.MAX
            );
            break;

          case 'MinNode':
            node = new Math2Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              Math2Node.MIN
            );
            break;

          case 'DistanceNode':
            node = new Math2Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              Math2Node.DISTANCE
            );
            break;

          case 'MixNode':
            node = new Math3Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              createParameter( nodeDef, inputs, 'arg3' ),
              Math3Node.MIX
            );
            break;

          case 'ClampNode':
            node = new Math3Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              createParameter( nodeDef, inputs, 'arg3' ),
              Math3Node.CLAMP
            );
            break;

          case 'SmoothstepNode':
            node = new Math3Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              createParameter( nodeDef, inputs, 'arg3' ),
              Math3Node.SMOOTHSTEP
            );
            break;

          case 'FWidthNode':
            // TODO(donmccurdy): Make a proper API.
            node = new Math1Node( createParameter( nodeDef, inputs, 'value' ), 'fwidth' );
            needsDerivatives = true;
            break;

          case 'MicNode':
            // TODO(donmccurdy): Boringgg.
            node = new FloatNode( 0.01 );
            break;

          case 'InstanceIDNode':
            node = new AttributeNode( 'instanceID', 'float' );
            break;

          case 'InstanceCountNode':
            node = new FloatNode( 1.0 );
            instanceCountNodes.push( node );
            break;

        }

        if ( ! node && ! skipped ) {

          console.warn( `[THREE.ShadeLoader] Node type "${nodeDef.class}" not implemented.` );
          return null;

        }

        if ( node.setLabel ) {

          node.setLabel( sanitizeLabel( nodeDef.options.userLabel ) );

        }

        return node;


      } );



    }

    function createParameter ( nodeDef, inputs, paramName ) {

      if ( inputs[ paramName ] ) return inputs[ paramName ];

      const value = nodeDef.inputs[ paramName ].value;

      switch ( Array.isArray( value ) ? value.length : 1 ) {
        case 1:
          return new FloatNode( value );
        case 2:
          return new Vector2Node( value[ 0 ], value[ 1 ] );
        case 3:
          return new Vector3Node( value[ 0 ], value[ 1 ], value[ 2 ] );
        case 4:
          return new Vector4Node( value[ 0 ], value[ 1 ], value[ 2 ], value[ 3 ] );
      }

      throw new Error( `THREE.ShadeLoader: Could not create parameter, "${paramName}".` );

    }

    json.connections.forEach( ( connection ) => {

      const [ leftID, leftProp, rightID, rightProp, swizzle, mode ] = connection;

      if ( dependencies[ rightID ] === undefined ) dependencies[ rightID ] = [];

      dependencies[ rightID ].push( connection );

      // debug
      const leftNodeDef = json.nodes.find( ( node ) => node.id === leftID );
      const rightNodeDef = json.nodes.find( ( node ) => node.id === rightID );
      console.log( `${leftNodeDef.options.userLabel}.${leftProp} --> ${rightNodeDef.options.userLabel}.${rightProp} <${mode}>` );

    } );

    const surfaceNodeDef = json.nodes.find( ( nodeDef ) => nodeDef.class === 'SurfaceNode' );

    createNode( surfaceNodeDef.id ).then( ( material ) => {

      if ( surfaceNodeDef.options.instanceCount > 1 ) {

        instanceCountNodes.forEach( ( node ) => ( node.value = surfaceNodeDef.options.instanceCount ) );

      }

      material.userData.instanceCount = surfaceNodeDef.options.instanceCount;
      material.userData.needsDerivatives = needsDerivatives;
      material.userData.timerNodes = timerNodes;
      onLoad( material );
    } ).catch( onError );

  }

}

const labels = {};

function sanitizeLabel ( label ) {

  label = label
    .replace(/[^\w_-]+/g, '' )
    .toLowerCase();

  let i = 1;

  while ( labels[ `${label}_${i}` ] === true ) i++;

  label = `${label}_${i}`;

  labels[ label ] = true;

  return label;

}

export { ShadeLoader };
