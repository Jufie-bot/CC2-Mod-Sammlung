#vertex_shader

in vec3 vertex_position_in;

out vec3 vertex_position_out; 
out vec3 vertex_normal_out; 
out float vertex_view_depth_out; 
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

uniform sampler2D texture_ocean_magnitude;

uniform vec3 uni_graphics_offset;

void main()
{
	vec4 vertex_position_world = mat_world * vec4(vertex_position_in, 1);
	
	vec2 ocean_world_coord = ((vertex_position_world.xz - uni_graphics_offset.xz) / vec2(1024.0 * 512.0, 1024.0 * 512.0)) + vec2(0.5, 0.5) + vec2(0.5 / 512.0, 0.5 / 512.0);
	float ocean_sample_magnitude = texture(texture_ocean_magnitude, ocean_world_coord).r;
	ocean_sample_magnitude = mix(0.1, 1.0, ocean_sample_magnitude);
	vertex_position_world.y = -20.0 - (ocean_sample_magnitude * 2000.0) + uni_graphics_offset.y;

	vertex_position_out = vertex_position_world.xyz;
	vec4 vertex_position_view = mat_view * vertex_position_world;
	vertex_normal_out = normalize((mat_view * mat_world * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
	vertex_view_depth_out = vertex_position_view.z;
	gl_Position = mat_proj * vertex_position_view;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

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
	gcolor_out = vec4(object_color.xyz, 1.0);
	gnormal_out = vec4(vertex_normal_out.xyz * object_color.a, -vertex_view_depth_out);
}