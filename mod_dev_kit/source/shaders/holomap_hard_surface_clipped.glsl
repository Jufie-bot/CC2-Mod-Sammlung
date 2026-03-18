#vertex_shader

in vec3 vertex_position_in;
in vec4 vertex_color_in;

out vec4 vertex_color_out;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

uniform mat4 uni_clip_box_transform_inverse;
uniform vec3 uni_clip_box_half_size;

out float gl_ClipDistance[6];

void main()
{
	vec4 vertex_position_world = mat_world * vec4(vertex_position_in, 1);
	vec4 vertex_position_view = mat_view * vertex_position_world;
	
	vertex_color_out = vertex_color_in;
	gl_Position = mat_proj * vertex_position_view;
	logz = 1.0 + gl_Position.w;
	
	vec3 vertex_position_clip_box = (uni_clip_box_transform_inverse * vertex_position_world).xyz;

	gl_ClipDistance[0] = uni_clip_box_half_size.x - vertex_position_clip_box.x;
	gl_ClipDistance[1] = uni_clip_box_half_size.y - vertex_position_clip_box.y;
	gl_ClipDistance[2] = uni_clip_box_half_size.z - vertex_position_clip_box.z;
	gl_ClipDistance[3] = vertex_position_clip_box.x + uni_clip_box_half_size.x;
	gl_ClipDistance[4] = vertex_position_clip_box.y + uni_clip_box_half_size.y;
	gl_ClipDistance[5] = vertex_position_clip_box.z + uni_clip_box_half_size.z;
}

#fragment_shader

in vec4 vertex_color_out;
in float logz;

out vec4 color_out;

uniform vec4 object_color;
uniform float far_plane_coefficient;

void main()
{
	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(object_color.xyz * vertex_color_out.xyz, 0.0);
}