#vertex_shader

in vec3 vertex_position_in;

out vec3 light_position_view;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;

uniform mat4 spot_light_cone_transform;

void main()
{
	light_position_view = (mat_view * spot_light_cone_transform * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	gl_Position = mat_proj * mat_view * spot_light_cone_transform * vec4(vertex_position_in, 1.0);
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec3 light_position_view;
in float logz;

out vec4 color_out;

uniform sampler2D texture_color;
uniform sampler2D texture_normal;
uniform sampler2D texture_ies;

uniform mat4 mat_projection;
uniform mat4 mat_projection_inverse;
uniform vec2 target_size;
uniform vec3 light_color;
uniform float light_length;

uniform mat4 mat_view_inverse;
uniform mat4 mat_view_to_light_proj;
uniform float far_plane_coefficient;
uniform vec2 inv_resolution_scale;

float attenuate(float dist)
{
	return -((dist - light_length) / (light_length * (dist + 1.0)));
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
	
	vec3 light_to_fragment = view_position - light_position_view;
	float light_to_fragment_length = length(light_to_fragment);
	float light_surface_magnitude = attenuate(light_to_fragment_length);
	
	float normal_factor = clamp(dot(normal.xyz, -light_to_fragment / light_to_fragment_length), 0.0, 1.0);
	normal_factor = mix(0.4, normal_factor, length(normal.xyz));

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(0.0, 0.0, 0.0, 1.0);
	
	// spotlight
	
	vec4 light_space_proj = mat_view_to_light_proj * vec4(view_position, 1.0);
	light_space_proj.xyz /= light_space_proj.w;
	light_space_proj = light_space_proj * 0.5 + 0.5;
	
	if(
		light_space_proj.x > 0.0 && light_space_proj.x < 1.0 && 
		light_space_proj.y > 0.0 && light_space_proj.y < 1.0 && 
		light_space_proj.z > 0.0 && light_space_proj.z < 1.0)
	{
		vec4 sample_ies = texture(texture_ies, clamp(light_space_proj.xy, 0.0, 1.0));
		vec3 surface_color = light_surface_magnitude * normal_factor * color.xyz * light_color * color.a * sample_ies.xyz;

		if(surface_color.x + surface_color.y + surface_color.z > 0.0001)
		{
			color_out = vec4(max(surface_color, 0.0), 1.0);
		}
	}
}