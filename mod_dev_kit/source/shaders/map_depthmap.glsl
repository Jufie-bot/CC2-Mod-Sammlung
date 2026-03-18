#vertex_shader

in vec3 vertex_position_in;

out vec3 vertex_world_pos;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	vec4 vertex_position_world = mat_world * vec4(vertex_position_in, 1);
	vertex_world_pos = vertex_position_world.xyz;

	gl_Position = mat_proj * mat_view * vertex_position_world;
}

#fragment_shader

in vec3 vertex_world_pos;

out vec4 color_out;

uniform sampler2D texture_ocean_world_magnitude;
uniform sampler2D texture_noise;
uniform float ocean_world_size;

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
	float cutoff_height = -0.0;

	if(vertex_world_pos.y > cutoff_height)
	{
		color_out = vec4(vec3(0.0), 1.0);
	}
	else
	{
		vec2 ocean_sample_pos = vec2(
			(0.5 + (vertex_world_pos.x / ocean_world_size)),
			(0.5 + (vertex_world_pos.z / ocean_world_size))
		);
		
		float ocean_sample_magnitude = texture(texture_ocean_world_magnitude, ocean_sample_pos).r;
		ocean_sample_magnitude = mix(0.1, 1.0, ocean_sample_magnitude);
		float noise_sample = texture(texture_noise, ocean_sample_pos * 10.0).r;
		
		ocean_sample_magnitude += noise_sample * 0.05;

		float ocean_sample_height = -10.0 - (ocean_sample_magnitude * 40.0);
		float world_height = max(vertex_world_pos.y, ocean_sample_height);

		float depth_min = -10.0;
		float depth_max = -50.0;
		float depth_factor = pow(clamp((world_height - depth_min) / (depth_max - depth_min), 0.0, 1.0), 0.8);

		vec3 color = hsv2rgb(vec3(mix(0.0, 0.7, smoothstep(0.0, 1.0, depth_factor)), 1.0, mix(1.0, 0.1, depth_factor)));
		color_out = vec4(color, 1.0);
	}
}
