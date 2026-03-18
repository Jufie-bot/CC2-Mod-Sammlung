#vertex_shader

in vec3 vertex_position_in;

void main()
{
	gl_Position = vec4(vertex_position_in * 2.0, 1.0);
}

#fragment_shader

out vec4 gcolor_out;
out vec4 gnormal_out;

uniform vec4 color;
uniform float smokescreen_factor;
uniform vec2 target_size;
uniform float far_plane_coefficient;

uniform sampler2D texture_depth;

mat4 thresholdMatrix = mat4
(
1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
);

float linearize_depth(float log_depth)
{
    float exponent = log_depth / far_plane_coefficient;
    return (pow(2.0, exponent) - 1.0);
}

void main()
{
	int pix_x = int(gl_FragCoord.x);
    int pix_y = int(gl_FragCoord.y);
    float dither_threshold = thresholdMatrix[pix_x & 3][pix_y & 3];

	vec2 screen_coord = gl_FragCoord.xy / target_size;

	float base_depth = linearize_depth(texture(texture_depth, screen_coord).x) * 1.0;
	base_depth = clamp(base_depth / 10.0, 0.0, 1.0);

	if(clamp(smokescreen_factor * base_depth, 0.0, 1.0) < dither_threshold)
	{
		discard;
	}

	gl_FragDepth = 0.0;
	gcolor_out = vec4(color.xyz, 1.0);
	gnormal_out = vec4(0.0, 0.0, 0.0, 0.0);
}
