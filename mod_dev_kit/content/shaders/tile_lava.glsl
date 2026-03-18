#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;

out vec3 vertex_position_out; 
out vec2 vertex_coord_0_out;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	vec4 vertex_position_world = mat_world * vec4(vertex_position_in, 1);
	vertex_position_out = vertex_position_world.xyz;
	vertex_coord_0_out = vertex_coord_0_in;

	vec4 vertex_position_view = mat_view * vertex_position_world;
	gl_Position = mat_proj * vertex_position_view;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec3 vertex_position_out;
in vec2 vertex_coord_0_out;
in float logz;

out vec4 color_out;

uniform sampler2D texture_diffuse;
uniform sampler2D texture_noise;

uniform vec3 uni_graphics_offset;
uniform float uni_animation_time;
uniform float far_plane_coefficient;

void main()
{
	float texture_world_scale = 0.04;
	vec3 vertex_position_world = vertex_position_out - uni_graphics_offset;
	vec2 sample_pos = vec2(vertex_position_world.x, vertex_position_world.z) * texture_world_scale;
	
	float animation_speed = 0.005;
	float lava_factor = texture(texture_diffuse, vertex_coord_0_out).r;
	lava_factor = mix(0.05, 1.0, lava_factor);

	float animation_time = uni_animation_time * animation_speed;
	float noise_scale = 0.1;

	float scrolling_noise_offset = texture(texture_noise, sample_pos + vec2(0, 1) * animation_time).r * noise_scale;
	float scrolling_noise = texture(texture_noise, sample_pos * 1.0 + vec2(scrolling_noise_offset)).r * 0.5;
	scrolling_noise += texture(texture_noise, sample_pos * 0.2 + vec2(scrolling_noise_offset)).r * 0.5;

	float ember_noise = texture(texture_noise, sample_pos * 1.0).r;
	ember_noise = pow(ember_noise, 10.0) * 2.0;
	
	float far_distance_noise_a = texture(texture_noise, sample_pos * 0.2).r;
	far_distance_noise_a = pow(min(far_distance_noise_a + 0.1, 1.0), 7.0) * 0.75;
	float far_distance_noise_b = texture(texture_noise, sample_pos * 0.08).r;
	far_distance_noise_b = pow(min(far_distance_noise_b + 0.1, 1.0), 7.0) * 0.75;
	lava_factor = max(lava_factor, far_distance_noise_a * 1.8);
	lava_factor = max(lava_factor, far_distance_noise_b * 1.8);

	float heat_factor = scrolling_noise * pow(max(lava_factor * 0.99 + 0.01, ember_noise), 1.4);

	vec3 lava_color;
	lava_color.r = pow(heat_factor, 1.0);
	lava_color.g = pow(heat_factor, 3.0);
	lava_color.b = pow(heat_factor, 6.0);

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(lava_color * 8.0, 1.0);
}