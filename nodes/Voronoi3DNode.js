/**
 * @author Don McCurdy / https://www.donmccurdy.com
 */

import { TempNode } from '../node_modules/three/examples/js/nodes/core/TempNode.js';
import { FunctionNode } from '../node_modules/three/examples/js/nodes/core/FunctionNode.js';

// Source - Shade for iPad
const src = `
float frac(float v) {
  return mod(v, 1.0);
}
vec2 frac(vec2 v) {
  return vec2(frac(v.x), frac(v.y));
}
vec3 frac(vec3 v) {
  return vec3(frac(v.x), frac(v.y), frac(v.z));
}

vec3 hash(vec3 p) {
  return frac(
      sin(vec3(dot(p, vec3(1.0, 57.0, 113.0)), dot(p, vec3(57.0, 113.0, 1.0)),
               dot(p, vec3(113.0, 1.0, 57.0)))) *
      43758.5453);
}

vec3 voronoi3D(const in vec3 x) {
  vec3 p = floor(x);
  vec3 f = frac(x);

  float id = 0.0;
  vec2 res = vec2(100.0);
  for (int k = -1; k <= 1; k++) {
    for (int j = -1; j <= 1; j++) {
      for (int i = -1; i <= 1; i++) {
        vec3 b = vec3(float(i), float(j), float(k));
        vec3 r = vec3(b) - f + hash(p + b);
        float d = dot(r, r);

        float cond = max(sign(res.x - d), 0.0);
        float nCond = 1.0 - cond;

        float cond2 = nCond * max(sign(res.y - d), 0.0);
        float nCond2 = 1.0 - cond2;

        id = (dot(p + b, vec3(1.0, 57.0, 113.0)) * cond) + (id * nCond);
        res = vec2(d, res.x) * cond + res * nCond;

        res.y = cond2 * d + nCond2 * res.y;
      }
    }
  }

  return vec3(sqrt(res), abs(id));
}
`;

function Voronoi3DNode( point ) {

  TempNode.call(this, 'v3');

  this.point = point;

}

Voronoi3DNode.prototype = Object.create(TempNode.prototype);
Voronoi3DNode.prototype.constructor = Voronoi3DNode;
Voronoi3DNode.prototype.nodeType = "Voronoi3D";

Voronoi3DNode.Nodes = (function () {

  return {
    voronoi3D: new FunctionNode( src.trim() )
  };

})();

Voronoi3DNode.prototype.generate = function (builder, output) {

  var voronoi3D = builder.include( Voronoi3DNode.Nodes.voronoi3D );

  return builder.format( voronoi3D + '( ' + [
    this.point.build( builder, 'vec3' ),
  ].join(', ') + ' )', this.getType( builder ), output );

};

Voronoi3DNode.prototype.getType = function ( builder ) {

  return 'v3';

};

Voronoi3DNode.prototype.copy = function (source) {

  TempNode.prototype.copy.call(this, source);

  this.point = source.point;

};

Voronoi3DNode.prototype.toJSON = function (meta) {

  var data = this.getJSONNode(meta);

  if (!data) {

    data = this.createJSONNode(meta);

    data.point = this.point.toJSON(meta).uuid;

  }

  return data;

};

export { Voronoi3DNode };
