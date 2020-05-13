

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec4 texel = Texel(tex, texture_coords);
    float truncation = 100.0;
    return vec4(vec3(texel.r) / truncation, 1.0);
}
