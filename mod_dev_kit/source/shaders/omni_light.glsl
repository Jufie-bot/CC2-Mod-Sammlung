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


uniform sampler2D texture_color;
uniform sampler2D texture_normal;

uniform mat4 mat_projection;
uniform mat4 mat_projection_inverse;
uniform vec2 target_size;
uniform vec3 light_color;
uniform float light_radius;
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
	
	vec3 light_to_fragment = view_position - light_position_view;
	float light_to_fragment_length = length(light_to_fragment);
	float light_surface_magnitude = attenuate(light_to_fragment_length);
	
	float normal_factor = clamp(dot(normal.xyz, -light_to_fragment / light_to_fragment_length), 0.0, 1.0);
	normal_factor = mix(0.4, normal_factor, length(normal.xyz));
	
	vec3 surface_color = light_surface_magnitude * normal_factor * color.xyz * light_color * color.a;

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(max(surface_color, 0.0), 1.0);
}