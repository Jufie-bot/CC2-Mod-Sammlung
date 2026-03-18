#vertex_shader

in vec3 vertex_position_in;
in vec4 vertex_color_in;
in vec3 vertex_normal_in;
in vec2 vertex_coord_0_in;

out vec4 vertex_color_out;
out vec3 vertex_position_out; 
out vec3 vertex_normal_out; 
out vec2 vertex_coord_0_out;
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
	vertex_coord_0_out = vertex_coord_0_in;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec4 vertex_color_out;
in vec3 vertex_position_out;
in vec3 vertex_normal_out; 
in vec2 vertex_coord_0_out;
in float vertex_view_depth_out; 
in float logz;

out vec4 gcolor_out;
out vec4 gnormal_out;

uniform sampler2D texture_diffuse;
uniform sampler2D texture_ambient;

uniform vec4 object_color;
uniform float far_plane_coefficient;

void main()
{
	vec4 color_sample = texture(texture_diffuse, vertex_coord_0_out);

	if(color_sample.a < 0.5)
	{
		discard;
	}
	
	float ambient_sample = texture(texture_ambient, vertex_coord_0_out).r;
	
	ambient_sample = pow(ambient_sample, 2.0);

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	gcolor_out = vec4(object_color.xyz * vertex_color_out.xyz * color_sample.xyz, ambient_sample);
	gnormal_out = vec4(vertex_normal_out.xyz, -vertex_view_depth_out);
}