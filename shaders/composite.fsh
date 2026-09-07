/*
 * composite — cel-shading pass
 *
 * Quantizes the scene-color luminance before the outline pass in
 * composite1.fsh. Iris runs composite programs in numeric order, so
 * composite1 is necessarily the later pass.
 */
#version 120

uniform sampler2D colortex0;

varying vec2 texcoord;

#define CEL_STEPS 3 // [2 3]

/* DRAWBUFFERS:0 */

void main() {
    vec4 sceneColor = texture2D(colortex0, texcoord);
    float luminance = dot(sceneColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    float steps = float(CEL_STEPS);
    float quantizedLuminance = clamp(
        floor(luminance * steps) / max(steps - 1.0, 1.0),
        0.0,
        1.0
    );

    vec3 celColor = sceneColor.rgb * (quantizedLuminance / max(luminance, 0.001));
    gl_FragData[0] = vec4(celColor, sceneColor.a);
}
