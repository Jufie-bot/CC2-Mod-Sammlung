#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;
 
out vec2 vertex_coord_0_out;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	vec4 vertex_position_world = mat_world * vec4(vertex_position_in, 1);
	vec4 vertex_position_view = mat_view * vertex_position_world;
	vertex_coord_0_out = vertex_coord_0_in;
	gl_Position = mat_proj * vertex_position_view;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec2 vertex_coord_0_out;
in float logz;

out vec4 color_out;

uniform sampler2D texture_diffuse;

uniform float flame_factor;
uniform float scroll_time;
uniform float far_plane_coefficient;

void main()
{
	vec4 color_sample = texture(texture_diffuse, (vertex_coord_0_out - vec2(0.0, scroll_time)) * vec2(1.0, 2.0));

    float center_line_factor = 1.0 - (abs(vertex_coord_0_out.x - 0.5) * 2.0);
    center_line_factor -= color_sample.x * 4.0 * vertex_coord_0_out.y;

	if(center_line_factor < 0.f)
	{
		discard;
	}

	float heat_factor = clamp(flame_factor - vertex_coord_0_out.y, 0.0, 1.0) / flame_factor;
	vec3 heat_color;
	heat_color.r = pow(heat_factor, 2.4) * 4.0;
	heat_color.g = pow(heat_factor, 4.0) * 4.0;
	heat_color.b = pow(heat_factor, 8.0) * 4.0;

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(heat_color, 0.0);
}