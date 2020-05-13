uniform vec2 inv_size;

float x_kernel[9] = float[](
    1, 0, -1,
    2, 0, -2,
    1, 0, -1
);

float y_kernel[9] = float[](
    1, 2, 1,
    0, 0, 0,
    -1, -2, -1
);

float x_kernel_value(int x, int y) {
    int r = y + 1;
    int c = x + 1;
    return x_kernel[c + r * 3];
}

float y_kernel_value(int x, int y) {
    int r = y + 1;
    int c = x + 1;
    return y_kernel[c + r * 3];
}

vec4 effect(vec4 color, Image tex, vec2 _uv, vec2 screen_coords) {
    float dx = 0;
    float dy = 0;
    vec2 uv = screen_coords * inv_size;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            float occ = Texel(tex, uv + vec2(x, y) * inv_size).a;
            dx += occ * x_kernel_value(x, y);
            dy += occ * y_kernel_value(x, y);
        }
    }

    vec2 d = vec2(dx, dy);
    vec2 normal = -normalize(d);

    return vec4(0.5 * (normal + vec2(1.0)), 0.0, length(d));
}
