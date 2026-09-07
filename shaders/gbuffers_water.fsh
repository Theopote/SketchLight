#version 120

uniform sampler2D texture;

varying vec2 texcoord;
varying vec3 viewNormal;
varying vec4 vertexColor;

/* DRAWBUFFERS:01 */

void main() {
    vec4 albedo = texture2D(texture, texcoord) * vertexColor;
    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(viewNormal * 0.5 + 0.5, 1.0);
}
