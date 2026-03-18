#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;
in vec2 vertex_coord_1_in;

out vec2 vertex_data_out;

uniform mat4 mat_view;
uniform mat4 mat_proj;

uniform sampler2D texture_velocity;
uniform float ocean_world_size;
uniform vec2 camera_position;
uniform float camera_size;
uniform float time_factor;

void main()
{
	float particle_size = camera_size * 0.0032;
	float path_size = camera_size * 0.06;
	const float tail_factor = 0.4;

	const float time_center = 1.0 - ((1.0 - tail_factor) * 0.5);
	const float time_high_size = time_center - tail_factor - tail_factor;

	vec2 camera_position_factor = mod((camera_position / camera_size) + vec2(0.5) + (vertex_coord_0_in * 0.5), 1.0) - vec2(0.5);

	vec3 particle_world_center = vec3(camera_position.x, 0.0, camera_position.y) - (vec3(camera_position_factor.x, 0.0, camera_position_factor.y) * camera_size);

	float vertex_time = mod(vertex_coord_1_in.x - (vertex_coord_1_in.y * tail_factor) + time_factor, 1.0);
	float particle_time = mod(vertex_coord_1_in.x + time_factor, 1.0);

	float visibility_factor = 1.0 - clamp((abs(particle_time - time_center) - time_high_size) / tail_factor, 0.0, 1.0);
	visibility_factor *= 1.0 - vertex_coord_1_in.y;
	
	vec2 source_ocean_sample_pos = vec2(
				(0.5 + (particle_world_center.x / ocean_world_size)),
				(0.5 + (particle_world_center.z / ocean_world_size))
			);

	vec2 source_ocean_current_velocity = texture(texture_velocity, source_ocean_sample_pos).xy;

	for(int i = 0; i < 16; ++i)
	{
		vec2 ocean_sample_pos = vec2(
				(0.5 + (particle_world_center.x / ocean_world_size)),
				(0.5 + (particle_world_center.z / ocean_world_size))
			);
		
		vec2 ocean_current_velocity = texture(texture_velocity, ocean_sample_pos).xy;

		float time_factor = clamp(vertex_time - (float(i) / 16.0), 0.0, 1.0 / 16.0);

		particle_world_center.xz += ocean_current_velocity * path_size * time_factor;
	}

	vec3 vertex_position_scaled = vertex_position_in.xzy * vec3(particle_size);

	vec3 vertex_position_world = vertex_position_scaled + particle_world_center;

	gl_Position = mat_proj * mat_view * vec4(vertex_position_world, 1.0);
	vertex_data_out = vec2(length(source_ocean_current_velocity), visibility_factor * 0.8);
}

#fragment_shader

in vec2 vertex_data_out;

out vec4 color_out;

uniform int render_mode;

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
	if(render_mode == 5)
	{
		float velocity = vertex_data_out.x * 0.36;

		color_out = vec4(0.0, pow(velocity, 4.0), pow(velocity, 2.0), vertex_data_out.y);
	}
	else
	{
		float velocity = vertex_data_out.x * 0.24;

		color_out = vec4(hsv2rgb(vec3(mix(0.2, 1.2, velocity), velocity, pow(velocity, 3.0))), vertex_data_out.y);
	}
}
