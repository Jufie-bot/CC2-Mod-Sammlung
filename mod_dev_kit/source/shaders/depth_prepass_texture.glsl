#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;

out vec2 vertex_coord_0_out;
out float logz;

uniform mat4 mat_view_proj;
uniform mat4 mat_world;

void main()
{
	vertex_coord_0_out = vertex_coord_0_in;
	gl_Position = mat_view_proj * mat_world * vec4(vertex_position_in, 1);
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec2 vertex_coord_0_out;
in float logz;

out vec4 color_out;

uniform float far_plane_coefficient;

uniform sampler2D texture_diffuse;

void main()
{
    float alpha = texture(texture_diffuse, vertex_coord_0_out).a;

    if(alpha < 0.5)
    {
        discard;
    }

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(1.0, 1.0, 1.0, 1.0);
}