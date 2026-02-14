#vertex_shader

in vec3 vertex_position_in;

out vec3 vertex_world_position_gs; 
out float logz_gs;

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
uniform float saturation_intensity;

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
	vec3 offset_prev = textureLod(texture_ocean_prev, ocean_tile_coord, lod_base_level + lod_blend_factor).xyz;
	vec3 offset_next = textureLod(texture_ocean_next, ocean_tile_coord, lod_base_level + lod_blend_factor).xyz;
	vec3 offset = mix(offset_prev, offset_next, blend_factor);
	vec2 ocean_world_coord = ((vertex_position_world.xz - uni_graphics_offset.xz) / vec2(1024.0 * 512.0, 1024.0 * 512.0)) + vec2(0.5, 0.5) + vec2(0.5 / 512.0, 0.5 / 512.0);
	float ocean_sample_magnitude = texture(texture_ocean_magnitude, ocean_world_coord).r;
	ocean_sample_magnitude = mix(0.1, 1.0, ocean_sample_magnitude);
	offset.y *= ocean_sample_magnitude;
	vertex_position_world.xyz += offset;
	
	vertex_world_position_gs = vertex_position_world.xyz;
	gl_Position = mat_proj * mat_view * vertex_position_world;
	logz_gs = 1.0 + gl_Position.w;
}

#geometry_shader

layout (triangles) in;
layout(triangle_strip, max_vertices = 3) out;

in vec3 vertex_world_position_gs[3]; 
in float logz_gs[3];

out float vertex_world_height; 
flat out vec3 normal;
out float logz;

uniform mat4 mat_view;
uniform vec3 uni_graphics_offset;
uniform float blend_factor;

uniform sampler2D texture_ocean_prev;
uniform sampler2D texture_ocean_next;

void main()
{
	vec2 world_center = (vertex_world_position_gs[0].xz + vertex_world_position_gs[1].xz + vertex_world_position_gs[2].xz) / 3.0;
	normal = cross((vertex_world_position_gs[1] - vertex_world_position_gs[0]), (vertex_world_position_gs[0] - vertex_world_position_gs[2]));
	
	float texture_size = 256.0 / 1.0;
	vec2 ocean_tile_coord = ((world_center - uni_graphics_offset.xz) / vec2(8192.0 / 8.0, 8192.0 / 8.0)) + vec2(0.5 / texture_size, 0.5 / texture_size);
	vec3 offset_prev = texture(texture_ocean_prev, ocean_tile_coord).xyz;
	vec3 offset_next = texture(texture_ocean_next, ocean_tile_coord).xyz;
	vec3 offset = mix(offset_prev, offset_next, blend_factor);
	normal += offset * 0.4;

	normal = normalize(normal);
	normal = (mat_view * vec4(normal, 0)).xyz;

	for(int i = 0; i < 3; i++)
	{
		vertex_world_height = vertex_world_position_gs[i].y;
		logz = logz_gs[i];
		gl_Position = gl_in[i].gl_Position;
    	EmitVertex();
	}

	EndPrimitive();
}

#fragment_shader

in float vertex_world_height; 
flat in vec3 normal;
in float logz;

out vec4 color_out;

uniform sampler2D texture_depth;
uniform sampler2D texture_light_gradient;

uniform vec4 object_color;
uniform vec2 target_size;
uniform float fog_half_distance_inv;
uniform vec3 light_dir_view_space;
uniform vec3 up_dir_view_space;
uniform mat4 mat_projection;
uniform mat4 mat_projection_inverse;
uniform float day_time_factor;
uniform float light_factor;
uniform float saturation_intensity;
uniform vec2 inv_resolution_scale;

uniform float camera_near;
uniform float camera_far;
uniform float far_plane_coefficient;

#define LIGHT_TEXTURE_HALF_PIXEL_SIZE 0.0078125
#define LIGHT_TEXTURE_SUBREGION_FOG 0.0
#define LIGHT_TEXTURE_SUBREGION_SKY 0.25
#define LIGHT_TEXTURE_SUBREGION_SUN 0.5
#define LIGHT_TEXTURE_SUBREGION_INCIDENCE 0.75

float linearize_depth(float log_depth)
{
    float exponent = log_depth / far_plane_coefficient;
    return (pow(2.0, exponent) - 1.0);
}

vec3 saturation(vec3 rgb, float adjustment)
{
    const vec3 w = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(rgb, w));
    return mix(intensity, rgb, adjustment);
}

vec3 sample_light_gradient(float light_texture_subregion, float factor)
{
	vec3 sample = texture(texture_light_gradient, vec2
    	(
    		mix(light_texture_subregion + LIGHT_TEXTURE_HALF_PIXEL_SIZE, light_texture_subregion + 0.25 - LIGHT_TEXTURE_HALF_PIXEL_SIZE, day_time_factor), 
    		mix(LIGHT_TEXTURE_HALF_PIXEL_SIZE, 1.0 - LIGHT_TEXTURE_HALF_PIXEL_SIZE, factor))
    	).xyz;
    sample = saturation(pow(sample, vec3(2.2)), saturation_intensity);
	return sample;
}

void main()
{
	float fragment_depth = log2(logz) * far_plane_coefficient;
	vec2 screen_coord = gl_FragCoord.xy / target_size;
	float base_depth = linearize_depth(texture(texture_depth, screen_coord).x);
	float ocean_depth = linearize_depth(fragment_depth);
	float delta_depth = base_depth - ocean_depth;
	float height_factor = clamp((vertex_world_height + 40.0) * 0.01, 0.0, 1.0);

	float light_texture_half_pixel_size = 0.5 / textureSize(texture_light_gradient, 0).x;

	float foam_factor = 1.0 - clamp((delta_depth) * -0.01, 0.0, 1.0);
	foam_factor = clamp((delta_depth) * 0.01, 0.0, 1.0);
	foam_factor = pow(foam_factor, 0.2);
	
	float ocean_transparency = 1.0 - (1.0 / (delta_depth * 0.2 + 1.0));
	
	vec4 ocean_color = vec4(mix(vec3(0.0, 0.05, 0.119), vec3(0.0, 0.2627, 0.6314), height_factor), ocean_transparency);

	vec3 ndc_pos = vec3((vec2(2.0, 2.0) * screen_coord * inv_resolution_scale) - vec2(1.0, 1.0), 1.0);
    vec4 clip_pos;
    clip_pos.w = mat_projection[3][2] / (ndc_pos.z - (mat_projection[2][2] / mat_projection[2][3]));
    clip_pos.xyz = ndc_pos * clip_pos.w;

	vec3 camera_to_fragment_projected = (mat_projection_inverse * clip_pos).xyz;
	camera_to_fragment_projected /= -camera_to_fragment_projected.z;
	vec3 camera_to_fragment = normalize(camera_to_fragment_projected);

	float light_dot_normal = clamp(-dot(normal, light_dir_view_space), 0.0, 1.0);
	light_dot_normal = light_dot_normal;
	vec3 half_vector = -normalize(camera_to_fragment + light_dir_view_space);
	float light_dot_half_vector = pow(max(0.0, dot(half_vector, normal)), 30.0) * clamp(light_dot_normal * 10.0, 0.0, 1.0);
	
    float light_incidence_factor = 1.0;
    vec3 light_incidence_sample = sample_light_gradient(LIGHT_TEXTURE_SUBREGION_INCIDENCE, light_incidence_factor);
	ocean_color.xyz *= light_incidence_sample;

	vec3 reflection_dir = reflect(camera_to_fragment, normal);
	float reflection_dot_up = dot(reflection_dir, up_dir_view_space) * 0.5 + 0.5;
	vec3 reflection_sky_sample = sample_light_gradient(LIGHT_TEXTURE_SUBREGION_SKY, reflection_dot_up);
	float fresnel_factor = dot(camera_to_fragment, normal);
	fresnel_factor = pow(max(0.0, 1.0 - abs(fresnel_factor)), 25);

	vec3 sun_sample = sample_light_gradient(LIGHT_TEXTURE_SUBREGION_SUN, 0.5);
	vec3 specular_color = sun_sample * light_dot_half_vector * light_factor;
    ocean_color.xyz += (specular_color + reflection_sky_sample) * fresnel_factor;

    float fog_factor = 1.0 - (1.0 / ((ocean_depth * fog_half_distance_inv) + 1.0));
	vec3 fog_sample = sample_light_gradient(LIGHT_TEXTURE_SUBREGION_FOG, fog_factor);
    vec4 result_color = mix(ocean_color, vec4(fog_sample, 1.0), fog_factor);
   
	float fragment_dot_up = dot(camera_to_fragment, up_dir_view_space) * 0.5 + 0.5;
	vec3 sky_sample = sample_light_gradient(LIGHT_TEXTURE_SUBREGION_SKY, fragment_dot_up);

	float sky_factor = fog_factor * fog_factor;

	result_color = mix(result_color, vec4(sky_sample, 1.0), sky_factor);

	gl_FragDepth = fragment_depth;
	color_out = result_color;
}