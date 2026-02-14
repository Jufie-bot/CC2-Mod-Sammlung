#vertex_shader

in vec3 vertex_position_in;

out vec2 vertex_coord_0_out;
out vec3 vertex_normal_out;
out vec3 vertex_offset_out;
out float vertex_view_depth_out; 
out vec4 vertex_proj_position_out; 
out float vertex_foam_factor_out; 
out float logz;

uniform sampler2D texture_ocean_prev;
uniform sampler2D texture_ocean_next;
uniform sampler2D texture_ocean_magnitude;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;
uniform float blend_factor;
uniform float lod_distance;
uniform vec3 lod_center;
uniform float lod_base_level;
uniform float lod_min_blend;

uniform vec3 uni_graphics_offset;

void main()
{
	vec3 vertex_position = vertex_position_in;
	vec4 vertex_position_world = mat_world * vec4(vertex_position, 1);

	const float lod_blend_zone_size = 0.25;
	float lod_bounding_size = lod_distance * (1.0 - lod_blend_zone_size);
	vec2 lod_bounding_pos = vertex_position_world.xz;
	lod_bounding_pos = max(lod_bounding_pos, lod_center.xz - vec2(lod_bounding_size));
	lod_bounding_pos = min(lod_bounding_pos, lod_center.xz + vec2(lod_bounding_size));
	float lod_blend_factor = clamp(length(vertex_position_world.xz - lod_bounding_pos) / (lod_distance * lod_blend_zone_size), 0.0, 1.0);
	lod_blend_factor = max(lod_blend_factor, lod_min_blend);

	float texture_size = 256.0 / pow(2.0, lod_base_level + lod_blend_factor);
	vec2 ocean_tile_coord = ((vertex_position_world.xz - uni_graphics_offset.xz) / vec2(8192.0, 8192.0)) + vec2(0.5 / texture_size, 0.5 / texture_size);
	vec4 ocean_sample_prev = textureLod(texture_ocean_prev, ocean_tile_coord, lod_base_level + lod_blend_factor);
	vec4 ocean_sample_next = textureLod(texture_ocean_next, ocean_tile_coord, lod_base_level + lod_blend_factor);
	vec3 offset = mix(ocean_sample_prev.xyz, ocean_sample_next.xyz, blend_factor);
	vec2 ocean_world_coord = ((vertex_position_world.xz - uni_graphics_offset.xz) / vec2(1024.0 * 512.0, 1024.0 * 512.0)) + vec2(0.5, 0.5) + vec2(0.5 / 512.0, 0.5 / 512.0);
	float ocean_sample_magnitude = texture(texture_ocean_magnitude, ocean_world_coord).r;
	ocean_sample_magnitude = mix(0.1, 1.0, ocean_sample_magnitude);
	vertex_offset_out = offset;
	offset.y *= ocean_sample_magnitude;
	vertex_foam_factor_out = mix(ocean_sample_prev.w, ocean_sample_next.w, blend_factor);
	vertex_position_world.xyz += offset;
	
	vertex_normal_out = (mat_view * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	vec4 vertex_position_view = mat_view * vertex_position_world;
	vertex_view_depth_out = vertex_position_view.z;
	vertex_coord_0_out = ocean_tile_coord;
	vertex_proj_position_out = mat_proj * vertex_position_view;
	gl_Position = vertex_proj_position_out;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec2 vertex_coord_0_out;
in vec3 vertex_normal_out;
in vec3 vertex_offset_out;
in float vertex_view_depth_out; 
in vec4 vertex_proj_position_out; 
in float vertex_foam_factor_out;
in float logz;

out vec4 gcolor_out;
out vec4 gnormal_out;

uniform sampler2D texture_depth;
uniform sampler2D texture_foam;

uniform vec4 object_color;
uniform vec2 target_size;
uniform float blend_factor;
uniform float time_factor;

uniform float camera_near;
uniform float camera_far;
uniform float far_plane_coefficient;

float linearize_depth(float log_depth)
{
    float exponent = log_depth / far_plane_coefficient;
    return (pow(2.0, exponent) - 1.0);
}

void main()
{
	float fragment_depth = log2(logz) * far_plane_coefficient;
	vec2 screen_coord = gl_FragCoord.xy / target_size;
	float base_depth = linearize_depth(texture(texture_depth, screen_coord).x);
	float ocean_depth = linearize_depth(fragment_depth);
	float depth_foam_factor = 1.0 - clamp((ocean_depth - base_depth) * -0.4, 0.0, 1.0);

	float foam_texture_a = texture(texture_foam, (vertex_coord_0_out * 4.0) + vec2(time_factor, time_factor)).x * 2.0 - 1.0;
	float foam_texture_b = texture(texture_foam, (vertex_coord_0_out * 16.0) + vec2(time_factor * 2.0, time_factor * 2.0)).x * 2.0 - 1.0;
	float foam_texture_c = texture(texture_foam, (vertex_coord_0_out * 64.0) + vec2(time_factor * 4.0, time_factor * 4.0)).x * 2.0 - 1.0;
	float foam_texture_factor = foam_texture_a * foam_texture_b * foam_texture_c * 8.0;

	float foam_factor = foam_texture_factor * ((vertex_foam_factor_out * 4.0) + depth_foam_factor);

	float xz_velocity = dot(vec2(1.0, 1.0), vertex_offset_out.xz);
	float surface_velocity_factor = xz_velocity > 0.f ? 1.0 - clamp(xz_velocity * 0.02, 0.0, 1.0) : 1.0 - clamp(xz_velocity * -0.08, 0.0, 1.0);
	surface_velocity_factor *= clamp(vertex_offset_out.y * 0.05, 0.0, 1.0) * 0.75;
	surface_velocity_factor += depth_foam_factor;
	surface_velocity_factor += foam_texture_factor * 0.1 * clamp((vertex_offset_out.y + 20.0) * 0.05, 0.0, 1.0);
		
	if(surface_velocity_factor < 0.1)
	{
		discard;
	}

	gl_FragDepth = (fragment_depth * 0.99999) - 0.00001;
	gcolor_out = vec4(0.7, 0.7, 0.7, 1.0);
	gnormal_out = vec4(0.0, 0.0, 0.0, -vertex_view_depth_out);
}