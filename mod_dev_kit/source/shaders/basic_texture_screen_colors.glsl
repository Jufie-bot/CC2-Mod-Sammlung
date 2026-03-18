#vertex_shader

in vec3 vertex_position_in;
in vec4 vertex_color_in;
in vec2 vertex_coord_0_in;

out vec4 vertex_color_out;
out vec2 vertex_coord_0_out;
out float logz;

uniform mat4 mat_view_proj;
uniform mat4 mat_world;

void main()
{
    vertex_color_out = vertex_color_in;
    vertex_coord_0_out = vertex_coord_0_in;
    gl_Position = mat_view_proj * mat_world * vec4(vertex_position_in, 1);
    logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec4 vertex_color_out;
in vec2 vertex_coord_0_out;
in float logz;

out vec4 color_out;

uniform vec4 object_color;
uniform float far_plane_coefficient;
uniform sampler2D texture_diffuse;

void main()
{
	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = texture(texture_diffuse, vertex_coord_0_out) * vertex_color_out * object_color;
    color_out = pow(color_out, vec4(1.0 / 2.2));
    color_out.rgb += vec3(0.02, 0.025, 0.04);
}