uniform vec2 light_pos;
uniform vec2 screen_size;

vec2 uv_from_screen(vec2 screen) {
    return screen / screen_size;
}

vec4 effect(vec4 color, Image sdf, vec2 texture_coords, vec2 screen_coords) {
    vec2 ray = screen_coords - light_pos;
    float max_dist = length(ray);
    ray /= max_dist;

    int max_steps = 200;
    float s = 0;

    float alpha = 1.0;
    float energy = 1.0;
    float w = 0.03;

    while (s <= max_dist) {
        vec2 pos = ray * s + light_pos;
        float d = Texel(sdf, uv_from_screen(pos)).r;
        float step_size =  max(abs(d), 1.0);

        energy = min( energy, 0.5 + 0.5 * d / (w * s));
        if (energy < 0) {
            break;
        }

        s += step_size;
    }

    energy = max(energy, 0.0);

    energy = energy* energy *(3.0 - 2.0 * energy);

    return vec4(vec3(1.0 - energy, energy, 0), 1.0);
}
