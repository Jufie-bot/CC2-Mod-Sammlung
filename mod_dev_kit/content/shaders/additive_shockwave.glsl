#vertex_shader

in vec3 vertex_position_in;
in vec3 vertex_normal_in;

out vec3 world_pos_out;
out float y_height;
out float normal_dot;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;
uniform vec3 camera_position;
void main()
{
	vec4 world_pos = mat_world * vec4(vertex_position_in, 1);
	vec3 world_normal = (mat_world * vec4(vertex_normal_in, 0)).xyz;
	world_normal /= length(world_normal);

	world_pos_out = world_pos.xyz;
	y_height = abs(vertex_position_in.z);

	vec3 to_vertex = world_pos_out - camera_position;
    to_vertex /= length(to_vertex);
    normal_dot = abs(min(0.75, dot(to_vertex, world_normal)));

	gl_Position = mat_proj * mat_view * world_pos;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec3 world_pos_out;
in float y_height;
in float normal_dot;
in float logz;

out vec4 color_out;

uniform vec3 object_color;
uniform float intensity;
uniform float far_plane_coefficient;

void main()
{
	gl_FragDepth = log2(logz) * far_plane_coefficient;

    float distortion = max(1.0 - (normal_dot * 2.0), 0.0);
    distortion = distortion * distortion;
	float y_factor = max(1.0 - (y_height * 2.5), 0.0);
	y_factor = y_factor * y_factor;

	float distortion_disk = 1.0 - (normal_dot * 0.5);
	distortion_disk = distortion_disk * distortion_disk;
	float y_factor_disk = max((distortion_disk * 2.0) - (y_height * 10), 0.0);
	y_factor_disk = y_factor_disk * y_factor_disk;

	vec3 color_base = max((object_color * y_factor * distortion), (object_color * y_factor_disk * distortion_disk));
	color_base *= intensity * intensity;

    color_out = vec4(color_base, 1.0);
}
