uniform float radius;
uniform vec2 center;

float sdf(vec2 pos) {
  return length(pos) - radius;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 world_coords = screen_coords - center;
    return vec4(vec3(sdf(world_coords)), 1.0);
}
