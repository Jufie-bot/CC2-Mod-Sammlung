#vertex_shader

in vec3 vertex_position_in;
in vec4 vertex_color_in;
in vec2 vertex_coord_0_in;
in mat4 instance_transform_in;

out vec2 vertex_coord_0_out;

uniform mat4 mat_view_proj;
uniform float animation_time;

uniform vec3 uni_bucket_world_offset;

void main()
{
	const float pi = 3.1415926535;

	vec2 wind_normal = normalize(vec2(1.0, 1.0));
	float wind_magnitude = 5.0;
	float wind_wavelength_low = 32.0;
	float wind_wavelength_high = 4.0;
	float low_factor = clamp(vertex_color_in.r * 12.0, 0.0, 1.0) * 0.01;
	float high_factor = clamp(vertex_color_in.r * 2.0 - 0.5, 0.0, 1.0) * 0.005;

	vec4 vertex_position_world = instance_transform_in * vec4(vertex_position_in, 1);
	vertex_position_world.xyz += uni_bucket_world_offset.xyz;

	float vertex_phase_low = (dot(vertex_position_world.xz, wind_normal) + vertex_position_world.y * 0.25) / wind_wavelength_low;
	vertex_phase_low = mod(vertex_phase_low + animation_time * 3.0, 1.0);
	
	float vertex_phase_high = (dot(vertex_position_world.xz, wind_normal) + vertex_position_world.y) / wind_wavelength_high;
	vertex_phase_high = mod(vertex_phase_high + animation_time * 7.0, 1.0);

	float vertex_offset_low = cos(vertex_phase_low * 2.0 * pi) * low_factor;
	float vertex_offset_high = cos(vertex_phase_high * 2.0 * pi) * high_factor;
	vertex_position_world.xz += wind_normal * (vertex_offset_low + vertex_offset_high) * wind_magnitude;

	vertex_coord_0_out = vertex_coord_0_in;
	gl_Position = mat_view_proj * vertex_position_world;
}

#fragment_shader

in vec2 vertex_coord_0_out;

uniform sampler2D texture_diffuse;

void main()
{
	vec4 color_sample = texture(texture_diffuse, vertex_coord_0_out);

	if(color_sample.a < 0.5)
	{
		discard;
	}
}