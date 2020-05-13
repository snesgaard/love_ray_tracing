uniform Image diffuse_tex;

uniform vec2 light;
float radius = 400.0f;
vec2 size = vec2(800, 600);
float step_size = 10.0f;
float power = 1;


vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 dir = light - screen_coords;
    float dist = length(dir);

    vec4 diffuse = Texel(diffuse_tex, texture_coords);
    vec4 base_color = vec4(1.0);

    if (dist < radius) {
        for (float d = 0; d < dist; d += step_size) {
            vec2 p = mix(screen_coords, light, d / dist);
            vec2 uv = p / size;
            vec4 occlusion = Texel(tex, uv);

            base_color *= pow(mix(vec4(1.0), vec4(0.95), occlusion), vec4(step_size));
            //base_color *= mix(vec4(1.0), vec4(0.97), occlusion);
            //if (a < 0.001) break;
        }
    }

    float att = clamp(1.0 - dist/radius, 0.0, 1.0); att *= att;

    base_color.a *= att;

    return power * color * diffuse * base_color;
}
