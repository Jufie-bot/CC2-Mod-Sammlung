#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;

out vec2 vertex_coord_0_out;
out float fragment_distance_out;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	vertex_coord_0_out = vertex_coord_0_in;

	vec4 view_pos = mat_view * mat_world * vec4(vertex_position_in, 1);
	fragment_distance_out = -view_pos.z;

	gl_Position = mat_proj * view_pos;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec2 vertex_coord_0_out;
in float fragment_distance_out;
in float logz;

out vec4 color_out;

uniform vec3 object_color;
uniform sampler2D texture_color;
uniform sampler2D texture_noise;
uniform vec2 screen_resolution;
uniform float animation_time;
uniform float animation_rand;
uniform float screen_brightness;
uniform float far_plane_coefficient;
uniform float warp_factor;
uniform float screen_warp_power;
uniform float screen_warp_intensity;
uniform float crt_effect_factor;

void main()
{
	vec2 pixel_size = vec2(1.0 / screen_resolution.x, 1.0 / screen_resolution.y);

	const float pi = 3.14159265359;

	// warp vertex coords at edges of screen
	float warp_intensity = screen_warp_intensity * warp_factor;
	float vignette_x = pow(abs(sin(vertex_coord_0_out.x * pi)), screen_warp_power);
	float vignette_y = pow(abs(sin(vertex_coord_0_out.y * pi)), screen_warp_power);
	float vignette_factor = mix(1.0, vignette_x * vignette_y, crt_effect_factor);
	vec2 warped_vertex_coord = mix(vertex_coord_0_out, vec2(0.5), vignette_factor * warp_intensity);

	// scanlines
	float scanline_distance_factor = clamp(fragment_distance_out / 4.0, 0.0, 1.0); 
	float pixel_factor_y = mod(warped_vertex_coord.y / pixel_size.y, 1.0);
	float scanline_brightness = sin(animation_time * 5.0 + warped_vertex_coord.y * 10.0) * 0.5 + 0.5;
	float factor_scanline = scanline_brightness * 0.1 + 0.9;

	// offset color samples for chromatic aberration
	float aberration_factor = 1.0 * crt_effect_factor;
	float uv_shift = (pixel_size.x * 0.3) * aberration_factor;	

	vec2 coord_r = vec2(clamp(warped_vertex_coord.x - uv_shift, 0.0, 1.0), warped_vertex_coord.y);
	vec2 coord_g = vec2(warped_vertex_coord.x, warped_vertex_coord.y);
	vec2 coord_b = vec2(clamp(warped_vertex_coord.x + uv_shift, 0.0, 1.0), warped_vertex_coord.y);

	vec2 noise_to_pixel_scale = screen_resolution / vec2(256.0);

	float noise_sample = texture(texture_noise, (warped_vertex_coord + vec2(animation_rand)) * noise_to_pixel_scale).r;
	float noise_sample_2 = texture(texture_noise, ((warped_vertex_coord + vec2(animation_rand)) * 10.0) * noise_to_pixel_scale).r;
	float noise_factor = mix(1.0, noise_sample * 0.1 + 0.9, crt_effect_factor);

	float color_noise_amount = 0.0005 * crt_effect_factor;
	vec2 coord_noise_offset = vec2(noise_sample_2 * color_noise_amount);
	float color_sample_r = texture(texture_color, coord_r + coord_noise_offset).r;
	float color_sample_g = texture(texture_color, coord_g + coord_noise_offset).g;
	float color_sample_b = texture(texture_color, coord_b + coord_noise_offset).b;

	vec3 backlight_color = vec3(0.02, 0.025, 0.04) * crt_effect_factor;

	color_sample_r = mix(backlight_color.r, 1.0, color_sample_r);
	color_sample_g = mix(backlight_color.g, 1.0, color_sample_g);
	color_sample_b = mix(backlight_color.b, 1.0, color_sample_b);

	vec3 color_sample = vec3(color_sample_r, color_sample_g, color_sample_b);

	// rounded edges
	if(vignette_factor < 0.2)
	{
		vignette_factor = 0.0;
	}

	// combine effects
	color_sample = color_sample * object_color * factor_scanline * vignette_factor * noise_factor * screen_brightness;

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(color_sample, 1.0);
}