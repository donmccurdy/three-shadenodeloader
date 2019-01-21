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

    function createNode ( nodeID ) {

      if ( nodeCache[ nodeID ] ) return nodeCache[ nodeID ];

      const nodeDef = json.nodes.find( ( def ) => def.id === nodeID );

      const pendingDeps = ( dependencies[ nodeID ] || [] ).map( ( [ leftID ] ) => createNode( leftID ) );

      return Promise.all( pendingDeps ).then( ( deps ) => {

        const inputs = {};

        deps.forEach( ( dep, depIndex ) => {

          const [ leftID, leftProp, rightID, rightProp, options, _ ] = dependencies[ nodeID ][ depIndex ];

          if ( leftProp === 'sinTime' ) dep = new Math1Node( dep, Math1Node.SIN );
          if ( leftProp === 'cosTime' ) dep = new Math1Node( dep, Math1Node.COS );

          inputs[ rightProp ] = dep;

        } );

        let node;
        let skipped = true;

        switch ( nodeDef.class ) {
          case 'SurfaceNode':
            node = new StandardNodeMaterial();
            node.opacity = createParameter( nodeDef, inputs, 'opacity' );
            node.alphaTest = createParameter( nodeDef, inputs, 'opacityClip' );
            node.emissive = createParameter( nodeDef, inputs, 'emissionColor' );
            break;

          case 'ColorNode':
            node = new ColorNode( new THREE.Color().fromArray ( nodeDef.inputs.value.value ) );
            break;

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
            // TODO(donmccurdy): Implement GradientNode.
            node = new FloatNode( 1.0 );
            break;

          case 'GroupNode':
            skipped = true;
            break;

          case 'MultiplyNode':
            node = new OperatorNode(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              OperatorNode.MUL
            );
            break;

          case 'Noise3DNode':
            node = new NoiseNode();
            break;

          case 'NumberNode':
            node = new FloatNode( nodeDef.inputs.value.value );
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

          case 'RemapNode':
            // TODO(donmccurdy): Implement RemapNode.
            return createParameter( nodeDef, inputs, 'arg1' );
            break;

          case 'StepNode':
            node = new Math2Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              Math2Node.STEP
            );
            break;

          case 'TimeNode':
            node = new TimerNode();
            break;
        }

        if ( ! node && ! skipped ) {

          console.warn( `[THREE.ShadeLoader] Node type "${nodeDef.class}" not implemented.` );
          return null;

        }

        if ( node.setName ) {

          node.setName( `${nodeDef.options.userLabel} <${nodeDef.name}>` );

        }

        nodeCache[ nodeID ] = node;

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
          return new Vector3Node( value[ 0 ], value[ 1 ], value[ 1 ] );
      }

      throw new Error( `THREE.ShadeLoader: Could not create parameter, "${paramName}".` );

    }

    json.connections.forEach( ( connection ) => {

      const [ leftID, leftProp, rightID, rightProp, options, _ ] = connection;

      if ( dependencies[ rightID ] === undefined ) dependencies[ rightID ] = [];

      dependencies[ rightID ].push( connection );

      const leftNodeDef = json.nodes.find( ( node ) => node.id === leftID );
      const rightNodeDef = json.nodes.find( ( node ) => node.id === rightID );

      console.log( `${leftNodeDef.options.userLabel}.${leftProp} --> ${rightNodeDef.options.userLabel}.${rightProp}` );

    } );

    // json.nodes.forEach( ( nodeDef, nodeIndex ) => {

    //   console.log( `${nodeDef.class}:${nodeDef.name}:${nodeDef.options.userLabel}:${nodeIndex}` );

    // } );

    const surfaceNodeDef = json.nodes.find( ( nodeDef ) => nodeDef.class === 'SurfaceNode' );

    createNode( surfaceNodeDef.id ).then( onLoad ).catch( onError );

    // material.color = new ColorNode( 0xff0000 );
    // material.roughness = new FloatNode( 1.0 );
    // material.metalness = new FloatNode( 0.0 );

    // onLoad( material );

  }

}

export { ShadeLoader };
