#vertex_shader

in vec3 vertex_position_in;
in vec4 vertex_color_in;
in vec3 vertex_normal_in;

out vec4 vertex_color_out;
out vec3 vertex_position_out; 
out vec3 vertex_normal_out; 
out float vertex_view_depth_out; 
out float vertex_offset_out; 
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;
uniform float time_factor;

void main()
{
	vec3 channel_factors;
	channel_factors.x = sin((time_factor + 0.0000) * 6.28318530718);
	channel_factors.y = sin((time_factor + 0.3333) * 6.28318530718);
	channel_factors.z = sin((time_factor + 0.6666) * 6.28318530718);
	vec3 scale_factors = vertex_color_in.xyz * channel_factors * 0.1;
	vertex_offset_out = scale_factors.x + scale_factors.y + scale_factors.z;

	vec4 vertex_position_world = mat_world * vec4(vertex_position_in * (1.0 + vertex_offset_out), 1);
	vertex_position_out = vertex_position_world.xyz;
	vertex_normal_out = normalize((mat_view * mat_world * vec4(vertex_normal_in, 0)).xyz);
	vec4 vertex_position_view = mat_view * vertex_position_world;
	vertex_view_depth_out = vertex_position_view.z;
	vertex_color_out.xyz = vertex_color_in.xyz;
	gl_Position = mat_proj * vertex_position_view;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec4 vertex_color_out;
in vec3 vertex_position_out;
in vec3 vertex_normal_out; 
in float vertex_view_depth_out; 
in float vertex_offset_out; 
in float logz;

out vec4 gcolor_out;
out vec4 gnormal_out;

uniform vec4 object_color;
uniform float life_factor;
uniform float far_plane_coefficient;

void main()
{
	if((vertex_offset_out + 0.08) / 0.16 < 1.0 - life_factor)
	{
		discard;
	}

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	gcolor_out = vec4(object_color.rgb, 1.0);
	gnormal_out = vec4(vertex_normal_out.xyz * object_color.a, -vertex_view_depth_out);
}