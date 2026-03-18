#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;

out vec2 coord_0;

void main()
{
	coord_0 = vertex_coord_0_in;
	gl_Position = vec4(vertex_position_in * 2.0, 1.0);
}

#fragment_shader

in vec2 coord_0;

out vec4 color_out;

uniform sampler2D texture_source;

void main()
{
	color_out = texture(texture_source, coord_0);
}