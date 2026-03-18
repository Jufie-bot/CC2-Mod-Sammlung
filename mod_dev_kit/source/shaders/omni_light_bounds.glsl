#vertex_shader

in vec3 vertex_position_in;

out vec3 light_position_view;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;

uniform vec3 light_position;
uniform mat4 light_transform;

void main()
{
	vec4 vertex_position_world = light_transform * vec4(vertex_position_in, 1.0);
	light_position_view = (mat_view * vec4(light_position, 1.0)).xyz;
	gl_Position = mat_proj * mat_view * vertex_position_world;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec3 light_position_view;
in float logz;

out vec4 color_out;

uniform sampler2D texture_color;
uniform sampler2D texture_normal;

uniform mat4 mat_projection;
uniform mat4 mat_projection_inverse;
uniform vec2 target_size;
uniform vec3 light_color;
uniform float light_radius;
uniform mat4 light_transform_inv;
uniform float far_plane_coefficient;
uniform vec2 inv_resolution_scale;

float attenuate(float dist)
{
	return -((dist - light_radius) / (light_radius* (dist + 1.0)));
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
	vec3 position_bounds_space = (light_transform_inv * vec4(view_position, 1.0)).xyz;
	vec3 bounds_distance = abs(position_bounds_space) - vec3(0.5, 0.5, 0.5);
	
	gl_FragDepth = log2(logz) * far_plane_coefficient;
	
	if(bounds_distance.x < 0.0 && bounds_distance.y < 0.0 && bounds_distance.z < 0.0)
	{
		vec3 light_to_fragment = view_position - light_position_view;
		float light_to_fragment_length = length(light_to_fragment);
		float light_surface_magnitude = attenuate(light_to_fragment_length);
			
		float normal_factor = clamp(dot(normal.xyz, -light_to_fragment / light_to_fragment_length), 0.0, 1.0);
		normal_factor = mix(0.4, normal_factor, length(normal.xyz));

		vec3 bounds_falloff = min((-bounds_distance * vec3(10.0, 20.0, 10.0)), vec3(1.0, 1.0, 1.0));
		float falloff_factor = bounds_falloff.x * bounds_falloff.y * bounds_falloff.z;

		vec3 surface_color = light_surface_magnitude * normal_factor * color.xyz * light_color * color.a * falloff_factor;
	
		color_out = vec4(max(surface_color, 0.0), 1.0);
	}
	else
	{
		color_out = vec4(0.0, 0.0, 0.0, 0.0);
	}
}