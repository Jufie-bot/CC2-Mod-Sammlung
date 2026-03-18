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

uniform float scroll_time;

void main()
{
	vec4 color_sample = texture(texture_diffuse, (vertex_coord_0_out - vec2(0.0, scroll_time)) * vec2(1.0, 2.0));

    float center_line_factor = 1.0 - (abs(vertex_coord_0_out.x - 0.5) * 2.0);
    center_line_factor -= color_sample.x * 4.0 * vertex_coord_0_out.y;

	if(center_line_factor < 0.f)
	{
		discard;
	}
}