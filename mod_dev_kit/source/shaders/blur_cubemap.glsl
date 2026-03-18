#vertex_shader

in vec3 vertex_position_in;

out vec3 vertex_normal_out;

void main()
{
	vertex_normal_out = vertex_position_in * vec3(1.0, -1.0, 1.0) * (33.0 / 32.0) + vec3(0.0, 0.0, 0.5);
	gl_Position = vec4(vertex_position_in * 2.0, 1.0);
}

#fragment_shader

in vec3 vertex_normal_out;

out vec4 color_out;

uniform samplerCube texture_cubemap;

uniform mat4 mat_camera_transform;

void main()
{
	vec3 screen_normal = normalize(vertex_normal_out);
	
	vec3 color_accumulation = vec3(0.0, 0.0, 0.0);
	
	const int half_sample_count = 2;
	const float blur_offset = 2.0 / 32.0;
			
	for(int x = -half_sample_count; x <= half_sample_count; ++x)
	{
		for(int y = -half_sample_count; y <= half_sample_count; ++y)
		{		
			vec3 world_normal = (mat_camera_transform * vec4(screen_normal + vec3(float(x) * blur_offset, float(y) * blur_offset, 0.0), 0.0)).xyz;
	
			color_accumulation += texture(texture_cubemap, world_normal).xyz;
		}
	}
	
	color_accumulation /= float((half_sample_count + half_sample_count + 1) * (half_sample_count + half_sample_count + 1));
	

	color_out = vec4(color_accumulation, 1.0);
}