#vertex_shader

in vec3 vertex_position_in;
in vec3 vertex_vec3_0_in;
in vec3 vertex_vec3_1_in;
in vec2 vertex_coord_0_in;

out vec3 vertex_view_out;
out vec2 vertex_coord_0_out;
out float logz;

uniform float time_factor;
uniform vec3 camera_position;
uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform float snow_factor;
uniform mat4 mat_view_to_rain;
uniform mat4 mat_rain_to_view;
uniform vec3 graphics_offset;

uniform sampler2D texture_rain_depth;

vec3 pos_from_depth(vec3 position)
{
	vec4 camera_coord = (mat_view_to_rain * vec4(position, 1.0));
	camera_coord /= camera_coord.w;
	vec2 tex_coord = camera_coord.xy * 0.5 + 0.5;

	float depth = texture(texture_rain_depth, tex_coord).r - 0.0001;

	vec4 view_position = vec4(tex_coord, depth, 1.0);
	view_position = mat_rain_to_view * ((view_position * 2.0) - 1.0);
	return view_position.xyz / view_position.w;
}

void main()
{
	float position_cycle = mod((vertex_vec3_1_in.x + time_factor) * 128.0, 1.0);
	float position_step = floor(position_cycle * 4.0);
	float frame_step = floor(position_cycle * 16.0);

	const float particle_grid_size = 100.0;
	const vec3 particle_grid_size_vec3 = vec3(particle_grid_size, particle_grid_size, particle_grid_size);
	const vec3 particle_grid_half_size_vec3 = particle_grid_size_vec3 * 0.5;
	vec3 particle_world_position = graphics_offset + ((vertex_vec3_0_in + (position_step * vec3(vertex_vec3_1_in.y, 0.2, vertex_vec3_1_in.z))) * particle_grid_size);
	vec3 particle_offset = camera_position - particle_grid_half_size_vec3;
	particle_world_position = mod(particle_world_position - particle_offset, particle_grid_size_vec3) + particle_offset;

	float particle_scale_factor = clamp((snow_factor) * 10.0, 0.0, 1.0);

	vec3 particle_view_position = (mat_view * vec4(particle_world_position, 1.0)).xyz;
	particle_view_position = pos_from_depth(particle_view_position);

	vertex_view_out = particle_view_position.xyz;
	gl_Position = mat_proj * vec4((particle_scale_factor * vertex_position_in) + particle_view_position, 1);
	vertex_coord_0_out = vertex_coord_0_in * 0.25 + vec2(frame_step * 0.25, position_step * 0.25);
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec3 vertex_view_out;
in vec2 vertex_coord_0_out;
in float logz;

out vec4 gcolor_out;
out vec4 gnormal_out;

uniform vec4 object_color;
uniform float far_plane_coefficient;

uniform sampler2D texture_splash;

void main()
{
	float sample = texture(texture_splash, vertex_coord_0_out).a;

	if(sample < 0.5)
	{
		discard;
	}

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	gcolor_out = vec4(0.2, 0.2, 0.2, 1.0);
	gnormal_out = vec4(0.0, 0.0, 0.0, -vertex_view_out.z);
}