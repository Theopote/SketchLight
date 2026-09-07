/*
 * final — output pass
 * Currently: reads the outlined scene from colortex0 and lays a
 * cheap procedural grain over it to fake "paper texture". This is
 * a placeholder — replace with a proper cel-shading quantization
 * pass (ideally its own composite1 stage) plus a real paper/canvas
 * texture sampled via a custom texture declared in shaders.properties.
 *
 * TODO for you / Cursor:
 *   - Move cel-shading (lighting quantized to N bands) into its own
 *     composite1.fsh BEFORE the edge pass, so edges are drawn on top
 *     of already-flattened lighting, not on raw scene color.
 *   - Swap the procedural `hash()` grain for a tiled paper texture.
 *   - Add a subtle vignette / desaturation to sell the sketch look.
 */
#version 120

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

varying vec2 texcoord;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void main() {
    vec3 color = texture2D(colortex0, texcoord).rgb;

    float grain = hash(texcoord * vec2(viewWidth, viewHeight));
    color += (grain - 0.5) * 0.02;

    gl_FragColor = vec4(color, 1.0);
}
