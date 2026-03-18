#vertex_shader

in vec3 vertex_position_in;
in vec3 vertex_normal_in;

out vec4 vertex_color_out;
out vec3 vertex_normal_out; 
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	vertex_normal_out = normalize((mat_view * mat_world * vec4(vertex_normal_in, 0)).xyz);
	gl_Position = mat_proj * mat_view * mat_world * vec4(vertex_position_in, 1);
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec3 vertex_normal_out; 
in float logz;

out vec4 color_out;

uniform vec2 target_size;
uniform mat4 mat_projection;
uniform mat4 mat_projection_inverse;
uniform vec3 object_color;
uniform vec3 up_dir_view_space;
uniform float day_time_factor;
uniform float saturation_intensity;
uniform float far_plane_coefficient;
uniform vec2 inv_resolution_scale;

uniform sampler2D texture_light_gradient;

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
	vec2 screen_coord = gl_FragCoord.xy / target_size;
	vec3 ndc_pos = vec3((vec2(2.0, 2.0) * screen_coord * inv_resolution_scale) - vec2(1.0, 1.0), 1.0);
    vec4 clip_pos;
    clip_pos.w = mat_projection[3][2] / (ndc_pos.z - (mat_projection[2][2] / mat_projection[2][3]));
    clip_pos.xyz = ndc_pos * clip_pos.w;

	vec3 camera_to_fragment_projected = (mat_projection_inverse * clip_pos).xyz;
	camera_to_fragment_projected /= -camera_to_fragment_projected.z;
	vec3 camera_to_fragment = normalize(camera_to_fragment_projected);
	
	vec3 fragment_reflect = reflect(camera_to_fragment, vertex_normal_out);

	float fragment_dot_up = dot(fragment_reflect, up_dir_view_space) * 0.5 + 0.5;
	vec3 sky_sample = sample_light_gradient(LIGHT_TEXTURE_SUBREGION_SKY, fragment_dot_up);

	float reflect_factor = 1.0 - abs(dot(camera_to_fragment, vertex_normal_out));
	reflect_factor = pow(reflect_factor, 2.0);

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(sky_sample, 1.0) * reflect_factor;
}