uniform float exposure;
uniform float gamma;


vec3 Uncharted2ToneMapping(vec3 color)
{
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	color *= exposure;
	color = ((color * (A * color + C * B) + D * E) / (color * (A * color + B) + D * F)) - E / F;
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	color /= white;
	color = pow(color, vec3(1. / gamma));
	return color;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec3 texel = Texel(tex, texture_coords).rgb;
    vec3 mapped = Uncharted2ToneMapping(texel);

    return vec4(mapped, 1.0);
}
