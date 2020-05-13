uniform vec2 radius;
uniform vec2 center;

float sdf(vec2 pos) {
  float k0 = length(pos / radius);
  float k1 = length(pos/ (radius * radius));
  return k0 * (k0 - 1.0) / k1;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 world_coords = screen_coords - center;
    return vec4(sdf(world_coords));
}
