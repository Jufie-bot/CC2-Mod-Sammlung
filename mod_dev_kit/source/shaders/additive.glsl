#vertex_shader

in vec3 vertex_position_in;

out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	gl_Position = mat_proj * mat_view * mat_world * vec4(vertex_position_in, 1);
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in float logz;

out vec4 color_out;

uniform vec3 object_color;
uniform float far_plane_coefficient;

void main()
{
	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(object_color, 1.0);
}