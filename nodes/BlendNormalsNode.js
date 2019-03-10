/**
 * @author Don McCurdy / https://www.donmccurdy.com
 */

import { TempNode } from '../node_modules/three/examples/js/nodes/core/TempNode.js';
import { FunctionNode } from '../node_modules/three/examples/js/nodes/core/FunctionNode.js';

// Source - http://blog.selfshadow.com/publications/blending-in-detail/
const src = `
vec3 blendNormals(vec3 n1, vec3 n2)
{
    mat3 nBasis = mat3(
        vec3(n1.z, n1.y, -n1.x), // +90 degree rotation around y axis
        vec3(n1.x, n1.z, -n1.y), // -90 degree rotation around x axis
        vec3(n1.x, n1.y,  n1.z));

    return normalize(n2.x*nBasis[0] + n2.y*nBasis[1] + n2.z*nBasis[2]);
}
vec3 blendNormals(vec4 n1, vec4 n2)
{
    return blendNormals(n1.xyz, n2.xyz);
}
vec3 blendNormals(vec3 n1, vec4 n2)
{
    return blendNormals(n1, n2.xyz);
}
vec3 blendNormals(vec4 n1, vec3 n2)
{
    return blendNormals(n1.xyz, n2);
}
`;

function BlendNormalsNode( a, b ) {

  TempNode.call(this, 'v3');

  this.a = a;
  this.b = b;

}

BlendNormalsNode.prototype = Object.create(TempNode.prototype);
BlendNormalsNode.prototype.constructor = BlendNormalsNode;
BlendNormalsNode.prototype.nodeType = "BlendNormals";

BlendNormalsNode.Nodes = (function () {

  return {
    blendNormals: new FunctionNode( src.trim() )
  };

})();

BlendNormalsNode.prototype.generate = function (builder, output) {

  var blendNormals = builder.include( BlendNormalsNode.Nodes.blendNormals );

  return builder.format( blendNormals + '( ' + [
    this.a.build( builder ),
    this.b.build( builder ),
  ].join(', ') + ' )', this.getType( builder ), output );

};

BlendNormalsNode.prototype.getType = function ( builder ) {

  return 'v3';

};

BlendNormalsNode.prototype.copy = function (source) {

  TempNode.prototype.copy.call(this, source);

  this.a = source.a;
  this.b = source.b;

};

BlendNormalsNode.prototype.toJSON = function (meta) {

  var data = this.getJSONNode(meta);

  if (!data) {

    data = this.createJSONNode(meta);

    data.a = this.a.toJSON(meta).uuid;
    data.b = this.b.toJSON(meta).uuid;

  }

  return data;

};

export { BlendNormalsNode };
