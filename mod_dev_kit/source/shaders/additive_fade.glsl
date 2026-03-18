#vertex_shader

in vec3 vertex_position_in;
in vec3 vertex_normal_in;
in vec2 vertex_coord_0_in;

out vec2 vertex_coord_0_out;
out vec3 vertex_view_normal_out;
out vec3 vertex_view_dir_out;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	vertex_view_normal_out = normalize((mat_view * mat_world * vec4(vertex_normal_in, 0.0)).xyz);
	vec3 view_pos = (mat_view * mat_world * vec4(vertex_position_in, 1)).xyz;
	vertex_view_dir_out = normalize(view_pos);
	vertex_coord_0_out = vertex_coord_0_in;
	gl_Position = mat_proj * vec4(view_pos, 1.0);
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec2 vertex_coord_0_out;
in vec3 vertex_view_normal_out;
in vec3 vertex_view_dir_out;
in float logz;

out vec4 color_out;

uniform vec3 object_color;
uniform float far_plane_coefficient;

uniform sampler2D texture_color;

void main()
{
	float color_magnitude = clamp(abs(dot(vertex_view_normal_out, vertex_view_dir_out)) * 2.0 - 0.4, 0.0, 1.0);

	vec3 color_sample = texture(texture_color, vertex_coord_0_out).xyz * object_color * color_magnitude;
	
	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(color_sample, 1.0);
}