#vertex_shader

in vec3 vertex_position_in;

out vec3 light_position_view;
out float logz;

uniform mat4 mat_world;
uniform mat4 mat_view;
uniform mat4 mat_proj;

uniform vec3 light_position;
uniform float light_radius;

void main()
{
	//Sphere geometry is -0.5 to 0.5, so double the radius value
	light_position_view = (mat_view * vec4(light_position, 1)).xyz;
	gl_Position = mat_proj * mat_view * mat_world * vec4(vertex_position_in * light_radius * 2.0, 1.0);
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec3 light_position_view;
in float logz;

out vec4 color_out;

uniform sampler2D texture_normal;
uniform sampler2D texture_light_gradient;

uniform mat4 mat_projection;
uniform mat4 mat_projection_inverse;
uniform vec2 target_size;

uniform vec3 light_position;
uniform vec3 light_color;
uniform float light_intensity;
uniform float light_radius;
uniform float light_radius_inv;

uniform float volume_scale;
uniform float fog_half_distance_inv;
uniform float day_time_factor;
uniform float far_plane_coefficient;
uniform vec2 inv_resolution_scale;

float attenuate(float dist)
{
	return -((dist - light_radius) / (light_radius* (dist + 1.0)));
}

void main()
{
	vec2 screen_coord = gl_FragCoord.xy / target_size;
	vec4 normal = texture(texture_normal, screen_coord);
	
	vec3 ndc_pos = vec3((vec2(2.0, 2.0) * screen_coord * inv_resolution_scale) - vec2(1.0, 1.0), 1.0);
    vec4 clip_pos;
    clip_pos.w = mat_projection[3][2] / (ndc_pos.z - (mat_projection[2][2] / mat_projection[2][3]));
    clip_pos.xyz = ndc_pos * clip_pos.w;

	vec3 camera_to_fragment_projected = (mat_projection_inverse * clip_pos).xyz;
	camera_to_fragment_projected /= -camera_to_fragment_projected.z;
	
	float light_to_surface_depth = normal.w + light_position_view.z;
	vec3 light_plane_position = camera_to_fragment_projected * max(-light_position_view.z, 0.0);
	float light_to_plane_length = length(light_plane_position - light_position_view);
	light_to_plane_length = max(light_to_plane_length, -light_to_surface_depth);
	float depth_factor = clamp((light_to_surface_depth * light_radius_inv) + 1.0, 0.0, 1.0);
	
	float volume_magnitude = attenuate(light_to_plane_length);
	vec3 volume_color = volume_magnitude * depth_factor * light_color * fog_half_distance_inv * volume_scale;
	
	//Fog
	float fog_factor = 1.0 - (1.0 / (abs(-light_position_view.z * fog_half_distance_inv) + 1.0));
    
    float light_texture_half_pixel_size = 0.5 / textureSize(texture_light_gradient, 0).x;
    vec3 fog_sample = texture(texture_light_gradient, vec2
    	(
    		mix(light_texture_half_pixel_size, 0.25 - light_texture_half_pixel_size, day_time_factor), 
    		mix(light_texture_half_pixel_size, 1.0 - light_texture_half_pixel_size, fog_factor))
    	).xyz;
    fog_sample = pow(fog_sample, vec3(2.2));
   
    volume_color *= mix(vec3(1.0), fog_sample.xyz, fog_factor);
	
	gl_FragDepth = log2(logz) * far_plane_coefficient;
    color_out = vec4(max((volume_color * (1.0 - fog_factor)), 0.0), 0.0);
}