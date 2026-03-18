#vertex_shader

in vec3 vertex_position_in;
in vec3 vertex_vec3_0_in;
in vec3 vertex_vec3_1_in;
in vec2 vertex_coord_0_in;

out vec3 vertex_view_out;
out float logz;

uniform float time_factor;
uniform vec3 camera_position;
uniform vec2 wind_offset;
uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform float snow_factor;
uniform vec3 graphics_offset;

void main()
{
	const float particle_grid_size = 100.0;
	const vec3 particle_grid_size_vec3 = vec3(particle_grid_size, particle_grid_size, particle_grid_size);
	const vec3 particle_grid_half_size_vec3 = particle_grid_size_vec3 * 0.5;

	vec3 particle_world_position = graphics_offset + ((vertex_vec3_0_in + vec3(wind_offset.x, 0.0, wind_offset.y) + (vertex_vec3_1_in * time_factor)) * particle_grid_size);
	vec3 particle_offset = camera_position - particle_grid_half_size_vec3;
	particle_world_position = mod(particle_world_position - particle_offset, particle_grid_size_vec3) + particle_offset;

	vec3 particle_view_position = (mat_view * vec4(particle_world_position, 1.0)).xyz;

	float particle_scale_factor = clamp((snow_factor - vertex_coord_0_in.x) * 10.0, 0.0, 1.0);

	vec3 vertex_position_view = vertex_position_in * particle_scale_factor + particle_view_position;
	vertex_view_out = vertex_position_view.xyz;
	gl_Position = mat_proj * vec4(vertex_position_view, 1);
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec3 vertex_view_out;
in float logz;

out vec4 gcolor_out;
out vec4 gnormal_out;

uniform vec4 object_color;
uniform mat4 mat_view_to_rain;
uniform float far_plane_coefficient;

uniform sampler2D texture_rain_depth;

void main()
{
	vec4 rain_space_position = mat_view_to_rain * vec4(vertex_view_out, 1.0);
    rain_space_position /= rain_space_position.w;
    rain_space_position.xyz = rain_space_position.xyz * 0.5 + 0.5;
	rain_space_position.z += 0.002;

    float rain_depth_cmp = texture(texture_rain_depth, rain_space_position.xy).x - rain_space_position.z;
    if(rain_depth_cmp <= 0.0)
    {
        discard;
    }

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	gcolor_out = vec4(1.0, 1.0, 1.0, 1.0);
	gnormal_out = vec4(0.0, 0.0, 0.0, -vertex_view_out.z);
}