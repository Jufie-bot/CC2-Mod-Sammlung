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
	vertex_coord_0_out = vertex_coord_0_in;
	gl_Position = mat_proj * vertex_position_view;
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
uniform sampler2D texture_paint_mask;
uniform sampler2D texture_dirt_mask;
uniform sampler2D texture_pattern;

uniform vec4 object_color;
uniform float dirt_factor;
uniform vec4 dirt_color;
uniform float pattern_scale;
uniform float uv_offset;
uniform float far_plane_coefficient;

void main()
{
	vec4 color_sample = texture(texture_diffuse, vertex_coord_0_out + vec2(0.0, uv_offset));

	if(color_sample.a < 0.5)
	{
		discard;
	}
	
	float ambient_sample = texture(texture_ambient, vertex_coord_0_out).r;
	float paint_mask_sample = texture(texture_paint_mask, vertex_coord_0_out + vec2(0.0, uv_offset)).r;
	float dirt_mask_sample = texture(texture_dirt_mask, vertex_coord_0_out + vec2(0.0, uv_offset)).r;
	vec4 pattern_sample = texture(texture_pattern, vertex_coord_0_out * pattern_scale);

	vec3 surface_result_color = color_sample.xyz;

	if(paint_mask_sample > 0.5)
	{
		surface_result_color = clamp(pattern_sample.xyz + color_sample.xyz - vec3(0.5), vec3(0.0), vec3(1.0));
	}

	if(dirt_mask_sample > 1.0 - (dirt_factor * 0.9))
	{
		surface_result_color = vec3(dirt_color.xyz);
	}
	
	ambient_sample = pow(ambient_sample, 4.0);

	gl_FragDepth = log2(logz) * far_plane_coefficient;
	gcolor_out = vec4(object_color.xyz * vertex_color_out.xyz * surface_result_color, ambient_sample);
	gnormal_out = vec4(vertex_normal_out.xyz, -vertex_view_depth_out);
}