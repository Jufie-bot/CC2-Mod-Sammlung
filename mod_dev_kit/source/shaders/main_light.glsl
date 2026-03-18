#vertex_shader

in vec3 vertex_position_in;

void main()
{
	gl_Position = vec4(vertex_position_in * 2.0, 1.0);
}

#fragment_shader

out vec4 color_out;

uniform sampler2D texture_color;
uniform sampler2D texture_normal;
uniform sampler2DShadow texture_shadow;
uniform sampler2D texture_light_gradient;

uniform vec2 target_size;
uniform vec3 light_dir_view_space;
uniform vec3 up_dir_view_space;
uniform vec4 light_far_view_distance;
uniform mat4 mat_projection;
uniform mat4 mat_projection_inverse;
uniform mat4 mat_view_to_shadow[4];
uniform float fog_half_distance_inv;
uniform float day_time_factor;
uniform float light_factor;
uniform float saturation_intensity;
uniform vec2 inv_resolution_scale;

#define PI 3.1415926535
#define PI_2 (PI * 2.0)
#define LIGHT_TEXTURE_HALF_PIXEL_SIZE 0.0078125
#define LIGHT_TEXTURE_SUBREGION_FOG 0.0
#define LIGHT_TEXTURE_SUBREGION_SKY 0.25
#define LIGHT_TEXTURE_SUBREGION_SUN 0.5
#define LIGHT_TEXTURE_SUBREGION_INCIDENCE 0.75

float sample_shadow(vec2 base_uv, in float u, in float v, in vec2 blur_size, in float depth)
{
	vec3 uvz = vec3(base_uv + vec2(u, v) * blur_size, depth);

	return texture(texture_shadow, uvz);
}

float pcf_filter(vec3 uvz)
{
    vec2 blur_size = vec2(1.0) / textureSize(texture_shadow, 0);
    
    vec2 o = mod(floor(gl_FragCoord.xy), 2.0);
	
	float shadow = 0.0;
	shadow += sample_shadow(uvz.xy, -1.5,  1.5, blur_size, uvz.z);
	shadow += sample_shadow(uvz.xy,  0.5,  1.5, blur_size, uvz.z);
	shadow += sample_shadow(uvz.xy, -1.5, -0.5, blur_size, uvz.z);
	shadow += sample_shadow(uvz.xy,  0.5, -0.5, blur_size, uvz.z);
	shadow *= 0.25;

    return shadow;
}

float main_light_shadow(vec3 view_position, vec3 normal, float linear_depth)
{
    const float blur_threshold = 0.8;
    
	int cascade_index = 0;
    float cascade_mix_factor = 0.0;
    float depth_offset = 0.02;
	
	if(linear_depth < light_far_view_distance.x)
	{
		cascade_index = 0;
        cascade_mix_factor = clamp(linear_depth / light_far_view_distance.x, 0.0, 1.0);
        depth_offset *= 1.0;
	}
	else if(linear_depth < light_far_view_distance.y)
	{
		cascade_index = 1;
        cascade_mix_factor = clamp((linear_depth - light_far_view_distance.x) / (light_far_view_distance.y - light_far_view_distance.x), 0.0, 1.0);
        depth_offset *= 4.0;
	}
	else if(linear_depth < light_far_view_distance.z)
	{
		cascade_index = 2;
        cascade_mix_factor = clamp((linear_depth - light_far_view_distance.y) / (light_far_view_distance.z - light_far_view_distance.y), 0.0, 1.0);
        depth_offset *= 16.0;
	}
	else if(linear_depth < light_far_view_distance.w)
	{
		cascade_index = 3;
        cascade_mix_factor = clamp((linear_depth - light_far_view_distance.z) / (light_far_view_distance.w - light_far_view_distance.z), 0.0, 1.0);
        depth_offset *= 64.0;
	}
	else
	{
		return 1.0;
	}
	
	vec4 light_space_position = mat_view_to_shadow[cascade_index] * vec4(view_position + (normal * depth_offset), 1.0);
	light_space_position.xyz /= light_space_position.w;
	light_space_position.xyz = light_space_position.xyz * 0.5 + 0.5;
	light_space_position.xy *= 0.5;
	light_space_position.xy += vec2(float(cascade_index % 2) * 0.5, float(cascade_index < 2 ? 0 : 1) * 0.5);
	float shadow_value = pcf_filter(light_space_position.xyz);
	
    cascade_mix_factor = clamp((cascade_mix_factor - blur_threshold) / (1.0 - blur_threshold), 0.0, 1.0);
    if(cascade_mix_factor > 0.0)
    {
    	cascade_index += 1;
    	if(cascade_index < 4)
    	{
	    	light_space_position = mat_view_to_shadow[cascade_index] * vec4(view_position + (normal * depth_offset * 4.0), 1.0);
			light_space_position.xyz /= light_space_position.w;
			light_space_position.xyz = light_space_position.xyz * 0.5 + 0.5;
			light_space_position.xy *= 0.5;
			light_space_position.xy += vec2(float(cascade_index % 2) * 0.5, float(cascade_index < 2 ? 0 : 1) * 0.5);
			shadow_value = mix(shadow_value, pcf_filter(light_space_position.xyz), cascade_mix_factor);
		}
		else
		{
			shadow_value = mix(shadow_value, 1.0, cascade_mix_factor);
		}
    }
    
    return shadow_value;
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
	vec2 screen_coord = gl_FragCoord.xy / target_size;
	vec4 color = texture(texture_color, screen_coord);
	vec4 normal = texture(texture_normal, screen_coord);
	
	vec3 ndc_pos = vec3((vec2(2.0, 2.0) * screen_coord * inv_resolution_scale) - vec2(1.0, 1.0), 1.0);
    vec4 clip_pos;
    clip_pos.w = mat_projection[3][2] / (ndc_pos.z - (mat_projection[2][2] / mat_projection[2][3]));
    clip_pos.xyz = ndc_pos * clip_pos.w;

	vec3 camera_to_fragment_projected = (mat_projection_inverse * clip_pos).xyz;
	camera_to_fragment_projected /= -camera_to_fragment_projected.z;
	vec3 camera_to_fragment = normalize(camera_to_fragment_projected);
	vec3 view_position = camera_to_fragment_projected * normal.w;
		
	float shadow_value = main_light_shadow(view_position, normal.xyz, normal.w);
	
	float light_dot_normal = clamp(-dot(normal.xyz, light_dir_view_space), 0.0, 1.0);
	light_dot_normal = light_dot_normal;
	vec3 half_vector = -normalize(camera_to_fragment + light_dir_view_space);
	float light_dot_half_vector = pow(max(0.0, dot(half_vector * light_factor, normal.xyz)), 10.0) * clamp(light_dot_normal * 10.0, 0.0, 1.0);
	
	float light_incidence_factor = clamp(dot(normal.xyz, light_dir_view_space * light_factor) * -0.5 + 0.5, 0.0, shadow_value * 0.5 + 0.5);
	light_incidence_factor = mix(1.0, light_incidence_factor, length(normal.xyz));
	
	vec3 light_incidence_sample = sample_light_gradient(LIGHT_TEXTURE_SUBREGION_INCIDENCE, light_incidence_factor) * color.a;
	
	vec3 main_light_color = color.xyz * light_incidence_sample;

	vec3 specular_color = color.xyz * vec3(0.01, 0.01, 0.01) * light_dot_half_vector;
    
    vec3 surface_color = main_light_color + specular_color;
    
    float fog_factor = 1.0 - (1.0 / ((normal.w * fog_half_distance_inv) + 1.0));
	vec3 fog_sample = sample_light_gradient(LIGHT_TEXTURE_SUBREGION_FOG, fog_factor);
   
    vec3 result_color = mix(surface_color, fog_sample.xyz, fog_factor);
    
	float fragment_dot_up = dot(camera_to_fragment, up_dir_view_space) * 0.5 + 0.5;
	vec3 sky_sample = sample_light_gradient(LIGHT_TEXTURE_SUBREGION_SKY, fragment_dot_up);
	
	float sky_factor = fog_factor * fog_factor;
	
	result_color = mix(result_color, sky_sample, sky_factor);

	color_out = vec4(result_color, 1.0);
}