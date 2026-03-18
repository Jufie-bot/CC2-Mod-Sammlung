#vertex_shader

in vec3 vertex_position_in;
in vec3 vertex_normal_in;
in vec2 vertex_coord_0_in;

out vec2 vertex_coord_0_out;
out float vertex_height_out;
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

uniform mat4 uni_clip_box_transform_inverse;
uniform vec3 uni_clip_box_half_size;

uniform float uni_line_thickness;

out float gl_ClipDistance[6];

void main()
{
	vec4 vertex_position_world = mat_world * vec4(vertex_position_in + vertex_normal_in * uni_line_thickness, 1);
	vec4 vertex_position_view = mat_view * vertex_position_world;
	vertex_coord_0_out = vertex_coord_0_in;
	vertex_height_out = vertex_position_in.y;
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

in vec2 vertex_coord_0_out;
in float vertex_height_out;
in float logz;

out vec4 color_out;

uniform sampler2D texture_diffuse;

uniform vec4 color_low;
uniform vec4 color_high;
uniform float far_plane_coefficient;

void main()
{
	vec2 coord = vec2(vertex_coord_0_out.x, 0.5);
	float alpha_sample = texture(texture_diffuse, coord).a;

	vec4 color = color_high;
	
	if(vertex_coord_0_out.y != 0)
	{
		color.a = clamp(0.5 - (vertex_coord_0_out.y * 0.0157), 0.0, 1.0);
	}
	
	if(vertex_height_out < 0.0)
	{
		color.rgb = color_low.rgb;
		color.a = color.a * clamp((vertex_height_out + 20.0) / 20.0, 0.25, 1.0);
	}

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	color_out = vec4(color.xyz, alpha_sample * color.a);
}