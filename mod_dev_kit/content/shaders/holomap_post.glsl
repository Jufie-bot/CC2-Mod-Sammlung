#vertex_shader

in vec3 vertex_position_in;

out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	vec4 vertex_position_world = mat_world * vec4(vertex_position_in, 1);
	vec4 vertex_position_view = mat_view * vertex_position_world;
	gl_Position = mat_proj * vertex_position_view;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in float logz;

out vec4 color_out;

uniform sampler2D texture_color;
uniform sampler2D texture_noise;
uniform vec2 screen_resolution;
uniform float animation_time;
uniform float animation_rand;
uniform float far_plane_coefficient;

void main()
{
	gl_FragDepth = log2(logz) * far_plane_coefficient;

	vec2 pixel_size = vec2(1.0 / screen_resolution.x, 1.0 / screen_resolution.y);

	const float pi = 3.14159265359;

	// offset color samples for chromatic aberration
	float aberration_factor = 1.0;
	float uv_shift = pixel_size.x * 0.3;	

	vec2 uv = gl_FragCoord.xy / screen_resolution;

	vec2 coord_r = vec2(clamp(uv.x - uv_shift * aberration_factor, 0.0, 1.0), uv.y);
	vec2 coord_g = vec2(uv.x, uv.y);
	vec2 coord_b = vec2(clamp(uv.x + uv_shift * aberration_factor, 0.0, 1.0), uv.y);

	vec2 noise_to_pixel_scale = screen_resolution / vec2(256.0);

	float noise_sample = texture(texture_noise, (uv + vec2(animation_rand)) * noise_to_pixel_scale).r;
	float noise_sample_2 = texture(texture_noise, ((uv + vec2(animation_rand)) * 10.0) * noise_to_pixel_scale).r;
	float noise_factor = noise_sample * 0.1 + 0.9;

	float color_noise_amount = 0.0005;
	vec2 coord_noise_offset = vec2(noise_sample_2 * color_noise_amount);
	float color_sample_r = texture(texture_color, coord_r + coord_noise_offset).r;
	float color_sample_g = texture(texture_color, coord_g + coord_noise_offset).g;
	float color_sample_b = texture(texture_color, coord_b + coord_noise_offset).b;

	vec3 color_sample = vec3(color_sample_r, color_sample_g, color_sample_b);

	// combine effects
	color_sample = color_sample * noise_factor;

	color_out = vec4(color_sample * 2.0, 1.0);
}