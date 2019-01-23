/**
 * @author sunag / http://www.sunag.com.br/
 */

import { TempNode } from './node_modules/three/examples/js/nodes/core/TempNode.js';
import { FunctionNode } from './node_modules/three/examples/js/nodes/core/FunctionNode.js';
import { turb_snoise3D } from './lib/noise3D.glsl.js';

function Noise3DNode( node, lacunarity, gain ) {

  TempNode.call(this, 'f');

  this.value = node;
  this.lacunarity = lacunarity;
  this.gain = gain;

}

Noise3DNode.prototype = Object.create(TempNode.prototype);
Noise3DNode.prototype.constructor = Noise3DNode;
Noise3DNode.prototype.nodeType = "Noise3D";

Noise3DNode.Nodes = (function () {

  return {
    turb_snoise3D: new FunctionNode(turb_snoise3D)
  };

})();

Noise3DNode.prototype.generate = function (builder, output) {

  var turb_snoise3D = builder.include( Noise3DNode.Nodes.turb_snoise3D );

  // TODO(donmccurdy): Because the source contains multiple functions,
  // automatic name detection is unhappy. Better fix?
  turb_snoise3D = 'turb_snoise3D';

  return builder.format( turb_snoise3D + '( ' + [
    this.value.build( builder, 'v3'),
    this.lacunarity.build(builder, 'f'),
    this.gain.build(builder, 'f')
  ].join(', ') + ' )', this.getType( builder ), output );

};

Noise3DNode.prototype.copy = function (source) {

  TempNode.prototype.copy.call(this, source);

  this.uv = source.uv;

};

Noise3DNode.prototype.toJSON = function (meta) {

  var data = this.getJSONNode(meta);

  if (!data) {

    data = this.createJSONNode(meta);

    data.node = this.value.toJSON(meta).uuid;

  }

  return data;

};

export { Noise3DNode };
