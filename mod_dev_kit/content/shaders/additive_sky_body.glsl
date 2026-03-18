#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;

out vec2 vertex_coord_0_out;
out float vertex_y;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

uniform float visibility_factor_v;

void main()
{
	vertex_coord_0_out = vertex_coord_0_in;

	float scale = mix(1.0, 4.0, 1.0 - visibility_factor_v);
	vec4 vertex_world_pos = mat_world * vec4(vertex_position_in * scale, 1);
	gl_Position = mat_proj * mat_view * vertex_world_pos;

	vertex_y = vertex_world_pos.y;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec2 vertex_coord_0_out;
in float vertex_y;
in float logz;

out vec4 color_out;

uniform sampler2D texture_light_gradient;

uniform vec3 object_color;
uniform float day_time_factor;
uniform float saturation_intensity;
uniform float far_plane_coefficient;

uniform float visibility_factor_f;

#define LIGHT_TEXTURE_HALF_PIXEL_SIZE 0.0078125
#define LIGHT_TEXTURE_SUBREGION_FOG 0.0
#define LIGHT_TEXTURE_SUBREGION_SKY 0.25
#define LIGHT_TEXTURE_SUBREGION_SUN 0.5
#define LIGHT_TEXTURE_SUBREGION_INCIDENCE 0.75

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
	float distance_to_center = clamp(length(vertex_coord_0_out - vec2(0.5, 0.5)) * 2.0, 0.0, 1.0);
	float circle_size = mix(0.2, 0.0, 1.0 - visibility_factor_f);
	float distance_to_edge = clamp((distance_to_center - circle_size) / (1.0 - circle_size), 0.004, 1.0);

	float focus = (1.0 - visibility_factor_f) * 12.0;
	float multiplier = mix(10.0, 1.0, visibility_factor_f);
	float curve = 800.0;
	float intensity = clamp(((2.0 * ((distance_to_edge * curve) + focus)) / (((distance_to_edge * curve) + focus + focus) * ((distance_to_edge * curve) + focus + focus))) - (2.0 / curve), 0.0, 1.0);;

	float horizon_factor = clamp(vertex_y / 10000.0, 0.0, 1.0);

	vec3 sun_sample = sample_light_gradient(LIGHT_TEXTURE_SUBREGION_SUN, 0.5);

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(intensity * horizon_factor * multiplier * sun_sample * object_color, 1.0);
}