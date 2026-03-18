#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;

out vec2 vertex_coord_0_out;

uniform mat4 mat_view_proj;
uniform mat4 mat_world;

void main()
{
    vertex_coord_0_out = vertex_coord_0_in;
    gl_Position = mat_view_proj * mat_world * vec4(vertex_position_in, 1);
}

#fragment_shader

in vec2 vertex_coord_0_out;

uniform sampler2D texture_diffuse;

void main()
{
	vec4 color_sample = texture(texture_diffuse, vertex_coord_0_out);

	if(color_sample.a < 0.5)
	{
		discard;
	}
}