#vertex_shader

in vec3 vertex_position_in;
in vec3 vertex_normal_in;

out vec3 world_normal_out; 
out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{

	world_normal_out = normalize((mat_world * vec4(vertex_normal_in, 0)).xyz);

	vec4 vertex_position_world = mat_world * vec4(vertex_position_in, 1);
	vec4 vertex_position_view = mat_view * vertex_position_world;
	gl_Position = mat_proj * vertex_position_view;
	logz = 1.0 + gl_Position.w;
}

#fragment_shader

in vec3 world_normal_out; 
in float logz;

out vec4 color_out;

uniform float animation_time;
uniform float far_plane_coefficient;

uniform sampler2D texture_noise;

vec4 sample_noise(in ivec2 x)
{
	return texture(texture_noise, vec2(x * 0.1));
}

//https://www.shadertoy.com/view/Xdl3D2
vec3 starfield_colour()
{
	vec3 ray = -world_normal_out.xyz;

	float offset = animation_time * 0.15;	//Speed of streaks
	float streak_length = 3.0;				//Length of streaks
	float streak_length_rgb = 1.0;			//Length of streaks with abberation / red-blueshift
	offset += offset * 0.96;
	offset *= 2.0;
	
	vec3 stp = ray / max(abs(ray.x), abs(ray.y));
	vec3 col = vec3(0);
	
	vec3 pos = 2.0 * stp + 0.5;
	for(int i = 0; i < 12; i++)	//Streak spawn rate
	{
		float z = sample_noise(ivec2(pos.xy)).x;
		z = fract(z - offset);
		float d = 50.0 * z - pos.z;
		float w = pow(max(0.0, 1.0 - 16 * length(fract(pos.xy) - 0.5)), 2.0);	//Width of streaks
		vec3 c = max(vec3(0.0), vec3(1.0 - abs(d+streak_length_rgb * 0.5) / streak_length, 1.0 - abs(d) / streak_length, 1.0 - abs(d - streak_length_rgb * 0.5) / streak_length));
		col += 1.5 * (1.0 - z) * c * w;
		pos += stp;
	}
	
	return col.xyz;
}

void main()
{
	gl_FragDepth = log2(logz) * far_plane_coefficient;

	color_out = vec4(1.0f, 0.f, 1.0f, 1.0f);
	color_out.xyz = starfield_colour();
}