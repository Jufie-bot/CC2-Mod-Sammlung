#vertex_shader

in vec3 vertex_position_in;
in vec4 vertex_color_in;
in vec3 vertex_normal_in;
in vec2 vertex_coord_0_in;

out vec4 vertex_color_out;
out vec3 vertex_position_out; 
out vec3 vertex_normal_out; 
out vec2 vertex_coord_0_out;
out float vertex_view_depth_out; 
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;
uniform float animation_time;

void main()
{
	const float pi = 3.1415926535;

	vec2 wind_normal = normalize(vec2(1.0, 1.0));
	float wind_magnitude = 5.0;
	float wind_wavelength_low = 32.0;
	float wind_wavelength_high = 4.0;
	float low_factor = clamp(vertex_color_in.r * 12.0, 0.0, 1.0) * 0.01;
	float high_factor = clamp(vertex_color_in.r * 2.0 - 0.5, 0.0, 1.0) * 0.005;

	vec4 vertex_position_world = mat_world * vec4(vertex_position_in, 1);

	float vertex_phase_low = (dot(vertex_position_world.xz, wind_normal) + vertex_position_world.y * 0.25) / wind_wavelength_low;
	vertex_phase_low = mod(vertex_phase_low + animation_time * 3.0, 1.0);
	
	float vertex_phase_high = (dot(vertex_position_world.xz, wind_normal) + vertex_position_world.y) / wind_wavelength_high;
	vertex_phase_high = mod(vertex_phase_high + animation_time * 7.0, 1.0);

	float vertex_offset_low = cos(vertex_phase_low * 2.0 * pi) * low_factor;
	float vertex_offset_high = cos(vertex_phase_high * 2.0 * pi) * high_factor;
	vertex_position_world.xz += wind_normal * (vertex_offset_low + vertex_offset_high) * wind_magnitude;

	vertex_position_out = vertex_position_world.xyz;
	vertex_normal_out = normalize((mat_view * mat_world * vec4(vertex_normal_in, 0)).xyz);
	vec4 vertex_position_view = mat_view * vertex_position_world;
	vertex_view_depth_out = vertex_position_view.z;
	vertex_color_out = vertex_color_in;
	vertex_coord_0_out = vertex_coord_0_in;
	gl_Position = mat_proj * vertex_position_view;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec4 vertex_color_out;
in vec3 vertex_position_out;
in vec3 vertex_normal_out; 
in vec2 vertex_coord_0_out;
in float vertex_view_depth_out; 
in float logz;

out vec4 gcolor_out;
out vec4 gnormal_out;

uniform vec2 dither_range;
uniform float far_plane_coefficient;

uniform sampler2D texture_diffuse;

mat4 thresholdMatrix = mat4
(
1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
);

void main()
{
	int pix_x = int(gl_FragCoord.x);
    int pix_y = int(gl_FragCoord.y);
    float dither_threshold = thresholdMatrix[pix_x & 3][pix_y & 3];

	float fade =  clamp((-vertex_view_depth_out - dither_range.x) / (dither_range.y - dither_range.x), 0.0, 1.0);
    if(1.0 - fade - dither_threshold < 0.0)
    {
        discard;
    }

	vec4 color_sample = texture(texture_diffuse, vertex_coord_0_out);
	if(color_sample.a < 0.5)
	{
		discard;
	}

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	gcolor_out = vec4(color_sample.xyz, 1.0);
	gnormal_out = vec4(vertex_normal_out.xyz, -vertex_view_depth_out);
}