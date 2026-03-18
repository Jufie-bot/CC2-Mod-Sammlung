#vertex_shader

in vec3 vertex_position_in;

void main()
{
	gl_Position = vec4(vertex_position_in * 2.0, 1.0);
}

#fragment_shader

out vec4 color_out;

uniform vec4 color;

void main()
{
	color_out = color;
}