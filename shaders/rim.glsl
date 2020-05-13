uniform vec2 inv_size;
uniform vec2 light_pos;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = screen_coords * inv_size;
    vec4 normal_tex = Texel(tex, uv);

    if (normal_tex.a < 0.5) discard;

    vec2 normal = normal_tex.rg;
    normal = 2.0 * (normal - vec2(0.5));

    vec2 dir = normalize(screen_coords - light_pos);

    float amp = max(0.0, dot(normal, dir));

    return vec4(color.rgb,  vec3(amp * 3.0));
}
