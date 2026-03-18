#vertex_shader

in vec3 vertex_position_in;

void main()
{
	gl_Position = vec4(vertex_position_in * 2.0, 1.0);
}

#fragment_shader

out vec4 color_out;

uniform sampler2D texture_diffuse;
uniform vec2 target_size;
uniform int debug_mode;

void main()
{
	if(debug_mode == 1)
	{
		vec4 sample_texture = texture(texture_diffuse, gl_FragCoord.xy / target_size);
		color_out = vec4(sample_texture.xyz, 1.0);
	}
	else if(debug_mode == 2)
	{
		vec4 sample_texture = texture(texture_diffuse, gl_FragCoord.xy / target_size);
		color_out = vec4(sample_texture.xyz * 0.25 + 0.25, 1.0);
	}
	else if(debug_mode == 3)
	{
		vec4 sample_texture = texture(texture_diffuse, gl_FragCoord.xy / target_size);
		float depth_value = sample_texture.w / 1000.0;
		color_out = vec4(depth_value, depth_value, depth_value, 1.0);
	}
	else if(debug_mode == 4)
	{
		vec4 sample_texture = texture(texture_diffuse, gl_FragCoord.xy / target_size);
		color_out = vec4(vec3(sample_texture.a), 1.0);
	}
	else
	{
		color_out = vec4(1.0, 0.0, 0.0, 1.0);
	}
}