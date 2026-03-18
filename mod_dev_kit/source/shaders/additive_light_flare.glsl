#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;

out vec2 vertex_coord_0_out;
out float flare_visibility;
out float logz;

uniform sampler2D texture_depth;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;
uniform vec3 flare_world_position;
uniform vec2 source_pixel_size;
uniform float far_plane_coefficient;
uniform vec2 resolution_scale;

float linearize_depth(float log_depth)
{
    float exponent = log_depth / far_plane_coefficient;
    return (pow(2.0, exponent) - 1.0);
}

void main()
{
	vertex_coord_0_out = vertex_coord_0_in;
	gl_Position = mat_proj * mat_view * mat_world * vec4(vertex_position_in, 1);

 	vec4 flare_view_pos = mat_view * vec4(flare_world_position, 1);
	vec4 flare_proj_pos = mat_proj * flare_view_pos;

	vec2 flare_uv = ((flare_proj_pos.xy / flare_proj_pos.w) + 1.0) * 0.5;
	flare_uv *= resolution_scale;
	vec2 delta_uv = source_pixel_size * 1.5;

	float depth_a = linearize_depth(texture(texture_depth, flare_uv + (delta_uv * vec2( 0.125,  0.375))).x);
	float depth_b = linearize_depth(texture(texture_depth, flare_uv + (delta_uv * vec2(-0.375,  0.125))).x);
	float depth_c = linearize_depth(texture(texture_depth, flare_uv + (delta_uv * vec2( 0.375, -0.125))).x);
	float depth_d = linearize_depth(texture(texture_depth, flare_uv + (delta_uv * vec2(-0.125, -0.375))).x);
	float depth_threshold = -flare_view_pos.z * 0.98;

	float depth_factor = clamp((length(flare_world_position) - 10.0) / 50.0, 0.0, 1.0);

	flare_visibility = (float(depth_threshold < depth_a) + float(depth_threshold < depth_b) + float(depth_threshold < depth_c) + float(depth_threshold < depth_d)) * 0.25 * depth_factor; 

	if(flare_visibility == 0)
	{
		gl_Position.w = -100.0;
	}

	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec2 vertex_coord_0_out;
in float flare_visibility;
in float logz;

out vec4 color_out;

uniform vec3 object_color;
uniform float far_plane_coefficient;

uniform sampler2D texture_color;

void main()
{
	float sample_to_center_distance = length(vec2(0.5, 0.5) - vertex_coord_0_out) + 0.001;
	sample_to_center_distance = min(1.0, sample_to_center_distance * 2.0);

	float magic_number = 0.01;
	vec3 color_sample = object_color * flare_visibility * ((magic_number / sample_to_center_distance) - magic_number);

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(color_sample.rgb, 1.0);
}