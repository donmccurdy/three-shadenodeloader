/**
 * @author sunag / http://www.sunag.com.br/
 */

import { TempNode } from '../node_modules/three/examples/js/nodes/core/TempNode.js';
import { FunctionNode } from '../node_modules/three/examples/js/nodes/core/FunctionNode.js';
import { snoise } from './shaders/noise2D.glsl.js';

function Noise2DNode( node, lacunarity, gain, type ) {

  TempNode.call(this, 'f');

  this.value = node;
  this.lacunarity = lacunarity;
  this.gain = gain;
  this.type = type || Noise2DNode.CLASSIC;

}

Noise2DNode.CLASSIC = 'snoise';
Noise2DNode.PERIODIC = 'snoise';
Noise2DNode.SIMPLEX = 'snoise';

Noise2DNode.prototype = Object.create(TempNode.prototype);
Noise2DNode.prototype.constructor = Noise2DNode;
Noise2DNode.prototype.nodeType = "Noise2D";

Noise2DNode.Nodes = (function () {

  return {
    snoise: new FunctionNode(snoise)
  };

})();

Noise2DNode.prototype.generate = function (builder, output) {

  var snoise = builder.include( Noise2DNode.Nodes.snoise );

  // TODO: Fix this.
  snoise = 'snoise';

  return builder.format( snoise + '( ' + [
    this.value.build( builder, 'v2')
  ].join(', ') + ' )', this.getType( builder ), output );

};

Noise2DNode.prototype.copy = function (source) {

  TempNode.prototype.copy.call(this, source);

  this.value = source.value;
  this.lacunarity = source.lacunarity;
  this.gain = source.gain;
  this.type = source.type;

};

Noise2DNode.prototype.toJSON = function (meta) {

  var data = this.getJSONNode(meta);

  if (!data) {

    data = this.createJSONNode(meta);

    data.value = this.value.toJSON(meta).uuid;
    data.lacunarity = this.lacunarity.toJSON(meta).uuid;
    data.gain = this.gain.toJSON(meta).uuid;
    data.type = this.type;

  }

  return data;

};

export { Noise2DNode };
