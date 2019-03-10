/**
 * @author Don McCurdy / https://www.donmccurdy.com
 */

import { TempNode } from '../node_modules/three/examples/js/nodes/core/TempNode.js';
import { FunctionNode } from '../node_modules/three/examples/js/nodes/core/FunctionNode.js';

// Source - https://stackoverflow.com/questions/5281261/generating-a-normal-map-from-a-height-map
const src = `
vec3 heightToNormal(vec2 uv, float strength, vec2 texelSize, vec2 offset)
{
    const vec2 size = vec2(2.0,0.0);
    const vec3 off = vec3(-1.0,0.0,1.0);

    vec2 delta = texelSize;

    float s11 = sampleHeightN(uv + offset);
    float s01 = sampleHeightN(uv + delta * off.xy + offset);
    float s21 = sampleHeightN(uv + delta * off.zy + offset);
    float s10 = sampleHeightN(uv + delta * off.yx + offset);
    float s12 = sampleHeightN(uv + delta * off.yz + offset);

    vec3 va = normalize(vec3(size.x, size.y, (s21-s01) * strength));
    vec3 vb = normalize(vec3(size.y, size.x, (s12-s10) * strength));

    return cross(va,vb);
}

// float sampleHeightN(vec2 uv)
// {
//     return sin((distance(uv, vec2(0.5, 0.5))*50.0+_Time.y));
// }
`;

function HeightToNormalNode( height, uv, strength, texelSize, offset ) {

  TempNode.call(this, 'v3');

  this.height = height;
  this.uv = uv;
  this.strength = strength;
  this.texelSize = texelSize;
  this.offset = offset;

}

HeightToNormalNode.prototype = Object.create(TempNode.prototype);
HeightToNormalNode.prototype.constructor = HeightToNormalNode;
HeightToNormalNode.prototype.nodeType = "HeightToNormal";

HeightToNormalNode.Nodes = (function () {

  return {
    heightToNormal: new FunctionNode( src.trim() )
  };

})();

HeightToNormalNode.prototype.generate = function (builder, output) {

  var heightToNormal = builder.include( HeightToNormalNode.Nodes.heightToNormal );

  return builder.format( heightToNormal + '( ' + [
    this.height.build( builder ),
    this.uv.build( builder ),
    this.strength.build( builder ),
    this.texelSize.build( builder ),
    this.offset.build( builder ),
  ].join(', ') + ' )', this.getType( builder ), output );

};

HeightToNormalNode.prototype.getType = function ( builder ) {

  return 'v3';

};

HeightToNormalNode.prototype.copy = function (source) {

  TempNode.prototype.copy.call(this, source);

  this.height = source.height;
  this.uv = source.uv;
  this.strength = source.strength;
  this.texelSize = source.texelSize;
  this.offset = source.offset;

};

HeightToNormalNode.prototype.toJSON = function (meta) {

  var data = this.getJSONNode(meta);

  if (!data) {

    data = this.createJSONNode(meta);

    data.height = this.height.toJSON(meta).uuid;
    data.uv = this.uv.toJSON(meta).uuid;
    data.strength = this.strength.toJSON(meta).uuid;
    data.texelSize = this.texelSize.toJSON(meta).uuid;
    data.offset = this.offset.toJSON(meta).uuid;

  }

  return data;

};

export { HeightToNormalNode };
