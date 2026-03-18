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

uniform vec4 uni_sand_color_high;
uniform vec4 uni_sand_color_low;
uniform vec4 uni_grass_color;

uniform vec3 uni_graphics_offset;
uniform float far_plane_coefficient;

vec4 get_grass_color(vec3 world_position)
{
	float sand_min = -8.0;
	float sand_max = 4.0;

	float world_y = world_position.y - uni_graphics_offset.y;

	if(world_y < sand_max)
	{
		float sand_step_count = 8.0;
		float sand_step = (sand_max - sand_min) / sand_step_count;
		float height = floor(world_y / sand_step) * sand_step;
		float height_factor = clamp((height - sand_min) / (sand_max - sand_min), 0.0, 1.0);
		
		vec4 sand_color_height = mix(uni_sand_color_low, uni_sand_color_high, height_factor);
		
		return sand_color_height;
	}
	else
	{
		return uni_grass_color;
	}
}

void main()
{
	float ambient_sample = texture(texture_ambient, vertex_coord_0_out).r;
	ambient_sample = pow(ambient_sample, 4.0);

	if(vertex_color_out.r > 0.5)
	{
		vec4 grass_color = get_grass_color(vertex_position_out);
		if(grass_color.a < 0.5)
		{
			discard;
		}
		
		gcolor_out = vec4(grass_color.rgb, ambient_sample);
	}
	else
	{
		gcolor_out = vec4(texture(texture_diffuse, vertex_coord_0_out).rgb, ambient_sample);	
	}
	
	gl_FragDepth = log2(logz) * far_plane_coefficient;
	gnormal_out = vec4(vertex_normal_out.xyz, -vertex_view_depth_out);
}