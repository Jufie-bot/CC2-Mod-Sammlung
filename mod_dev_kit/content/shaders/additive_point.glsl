#vertex_shader

in vec3 vertex_position_in;

out vec3 world_position;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	world_position = (mat_world * vec4(vertex_position_in, 1)).xyz;
	gl_Position = mat_proj * mat_view * mat_world * vec4(vertex_position_in, 1);
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec3 world_position;
in float logz;

out vec4 color_out;

uniform vec3 object_color;
uniform float far_plane_coefficient;
uniform vec3 point_position;

void main()
{
	float fragment_point_distance = length(world_position - point_position);
	float fragment_point_factor = 1.0 - clamp(fragment_point_distance / 2.0, 0.0, 1.0);
	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(object_color * fragment_point_factor * 0.02 / fragment_point_distance, 1.0);
}