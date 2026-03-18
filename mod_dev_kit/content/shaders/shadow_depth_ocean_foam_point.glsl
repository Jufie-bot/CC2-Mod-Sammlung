#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;

out vec2 vertex_coord_0_out;
out vec2 vertex_ocean_coord_out;
out vec3 vertex_normal_out;
out float vertex_view_depth_out; 
out vec4 vertex_proj_position_out; 
out float vertex_foam_factor_out;

uniform sampler2D texture_ocean_prev;
uniform sampler2D texture_ocean_next;
uniform sampler2D texture_ocean_magnitude;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform float blend_factor;
uniform float effect_factor;

uniform vec3 uni_graphics_offset;

void main()
{
	float scale_factor = pow(effect_factor, 0.5);
	vec3 vertex_position_world = vertex_position_in;

	vec2 ocean_tile_coord = ((vertex_position_world.xz - uni_graphics_offset.xz) / vec2(8192.0, 8192.0)) + vec2(0.5 / 256.0, 0.5 / 256.0);
	vertex_ocean_coord_out = ocean_tile_coord;
	vec4 ocean_sample_prev = texture(texture_ocean_prev, ocean_tile_coord);
	vec4 ocean_sample_next = texture(texture_ocean_next, ocean_tile_coord);
	vec3 offset = mix(ocean_sample_prev.xyz, ocean_sample_next.xyz, blend_factor);
	vec2 ocean_world_coord = ((vertex_position_world.xz - uni_graphics_offset.xz) / vec2(1024.0 * 512.0, 1024.0 * 512.0)) + vec2(0.5, 0.5) + vec2(0.5 / 512.0, 0.5 / 512.0);
	float ocean_sample_magnitude = texture(texture_ocean_magnitude, ocean_world_coord).r;
	ocean_sample_magnitude = mix(0.1, 1.0, ocean_sample_magnitude);
	offset.y *= ocean_sample_magnitude;
	offset.y += uni_graphics_offset.y;
	vertex_position_world.xyz += offset;
	vertex_foam_factor_out = mix(ocean_sample_prev.w, ocean_sample_next.w, blend_factor);

	vec4 vertex_position_view = mat_view * vec4(vertex_position_world, 1.0);
	vertex_coord_0_out = vertex_coord_0_in;
	vertex_proj_position_out = mat_proj * vertex_position_view;
	gl_Position = vertex_proj_position_out;
}

#fragment_shader

in vec2 vertex_coord_0_out;
in vec2 vertex_ocean_coord_out;
in vec4 vertex_proj_position_out; 
in float vertex_foam_factor_out;

uniform sampler2D texture_foam;

uniform vec4 object_color;
uniform float blend_factor;

float camera_near = 0.2;
float camera_far = 100000.0;

void main()
{
	const float peak_foam_factor = 0.1;

	float foam_texture_a = texture(texture_foam, vertex_ocean_coord_out * 100.0).x;
	float foam_texture_b = texture(texture_foam, vertex_ocean_coord_out * 10.0).x;
	float foam_texture_c = texture(texture_foam, vertex_ocean_coord_out * 1.0).x;
	float foam_texture_factor = (foam_texture_a + foam_texture_b + foam_texture_c) * 0.75;

	float distance_factor = 1.0 - (abs(vertex_coord_0_out.x - 0.5) * 2.0);

	distance_factor = distance_factor - foam_texture_factor;

	float time_factor = 0.0;

	if(vertex_coord_0_out.y < peak_foam_factor)
	{
		time_factor = vertex_coord_0_out.y / peak_foam_factor;
	}
	else
	{
		time_factor = (1.0 - vertex_coord_0_out.y) / (1.0 - peak_foam_factor);
	}

	distance_factor *= time_factor;

	if(distance_factor < 0.01)
	{
		discard;
	}
}