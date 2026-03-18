#vertex_shader

in vec3 vertex_position_in;

uniform mat4 mat_view_proj;
uniform mat4 mat_world;

void main()
{
    gl_Position = mat_view_proj * mat_world * vec4(vertex_position_in, 1);
}



#fragment_shader

void main()
{
}
