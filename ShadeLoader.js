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

const InputOperator = { VALUE: 1, ADD: 2, MUL: 4 };

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

          const [ leftID, leftProp, rightID, rightProp, options, op ] = dependencies[ nodeID ][ depIndex ];

          if ( leftProp === 'sinTime' ) dep = new Math1Node( dep, Math1Node.SIN );
          if ( leftProp === 'cosTime' ) dep = new Math1Node( dep, Math1Node.COS );

          // Two connections can target the same node input property. It appears that the second
          // occurrence contains an operator >1, specifying how to modify the existing value.
          switch ( op ) {

            case InputOperator.VALUE:
              if ( inputs[ rightProp ] ) console.warn( `[THREE.ShadeLoader] Overwriting ".${rightProp}".` );
              inputs[ rightProp ] = dep;
              break;

            case InputOperator.ADD:
              inputs[ rightProp ] = new OperatorNode( dep, inputs[ rightProp ], OperatorNode.ADD );
              break;

            case InputOperator.MUL:
              inputs[ rightProp ] = new OperatorNode( dep, inputs[ rightProp ], OperatorNode.MUL );
              break;

            default:
              console.warn( `[THREE.ShadeLoader] Unknown operator "${op}" for socket ".${rightProp}".` );

          }

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
            node = new TextureNode( texture );
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
            // TODO(donmccurdy): Pretty sure this is just 2D noise.
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
            node = new PositionNode( PositionNode.LOCAL );
            // node = new PositionNode( nodeDef.options.space === 'world' ? PositionNode.WORLD : PositionNode.LOCAL );
            break;

          case 'RemapNode':
            const [ domainLow, domainHigh ] = nodeDef.inputs.arg2.value;
            const [ rangeLow, rangeHigh ] = nodeDef.inputs.arg3.value;
            const factor = ( rangeHigh - rangeLow ) / ( domainHigh - domainLow );
            node = new OperatorNode(
              new OperatorNode(
                new OperatorNode( createParameter( nodeDef, inputs, 'arg1' ), new FloatNode( domainLow ), OperatorNode.SUB ),
                new FloatNode( factor ),
                OperatorNode.MUL
              ),
              new FloatNode( rangeLow ),
              OperatorNode.ADD
            );
            break;

          case 'StepNode':
            node = new Math2Node(
              createParameter( nodeDef, inputs, 'arg1' ),
              createParameter( nodeDef, inputs, 'arg2' ),
              Math2Node.STEP
            );
            break;

          case 'TimeNode':
            node = new TimerNode( 1.0 );
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

      const [ leftID, leftProp, rightID, rightProp, options, op ] = connection;

      if ( dependencies[ rightID ] === undefined ) dependencies[ rightID ] = [];

      dependencies[ rightID ].push( connection );

      const leftNodeDef = json.nodes.find( ( node ) => node.id === leftID );
      const rightNodeDef = json.nodes.find( ( node ) => node.id === rightID );

      console.log( `${leftNodeDef.options.userLabel}.${leftProp} --> ${rightNodeDef.options.userLabel}.${rightProp} <${op}>` );

    } );

    const surfaceNodeDef = json.nodes.find( ( nodeDef ) => nodeDef.class === 'SurfaceNode' );

    createNode( surfaceNodeDef.id ).then( onLoad ).catch( onError );

  }

}

export { ShadeLoader };
