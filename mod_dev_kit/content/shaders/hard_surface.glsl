#vertex_shader

in vec3 vertex_position_in;
in vec4 vertex_color_in;
in vec3 vertex_normal_in;

out vec4 vertex_color_out;
out vec3 vertex_position_out; 
out vec3 vertex_normal_out; 
out float vertex_view_depth_out;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	vec4 vertex_position_world = mat_world * vec4(vertex_position_in, 1);
	vertex_position_out = vertex_position_world.xyz;
	vertex_normal_out = normalize((mat_view * mat_world * vec4(vertex_normal_in, 0)).xyz);
	vec4 vertex_position_view = mat_view * vertex_position_world;
	vertex_view_depth_out = vertex_position_view.z;
	vertex_color_out = vertex_color_in;
	gl_Position = mat_proj * vertex_position_view;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec4 vertex_color_out;
in vec3 vertex_position_out;
in vec3 vertex_normal_out; 
in float vertex_view_depth_out; 
in float logz;

out vec4 gcolor_out;
out vec4 gnormal_out;

uniform vec4 object_color;
uniform float far_plane_coefficient;

void main()
{
	gl_FragDepth = log2(logz) * far_plane_coefficient;
	gcolor_out = vec4(object_color.xyz * vertex_color_out.xyz, 1.0);
	gnormal_out = vec4(vertex_normal_out.xyz * object_color.a, -vertex_view_depth_out);
}