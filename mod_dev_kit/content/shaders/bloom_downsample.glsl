#vertex_shader

in vec3 vertex_position_in;
in vec2 vertex_coord_0_in;

out vec2 coord_0;

void main()
{
	coord_0 = vertex_coord_0_in;
	gl_Position = vec4(vertex_position_in * 2.0, 1.0);
}

#fragment_shader

in vec2 coord_0;

out vec4 color_out;

uniform sampler2D texture_source;
uniform vec2 source_pixel_size;
uniform float sample_radius;

void main()
{
	vec2 coord_delta = source_pixel_size * sample_radius;
	
	vec3 colour_accum = vec3(0.0, 0.0, 0.0);
	colour_accum += texture(texture_source, coord_0 + vec2(-coord_delta.x,  -coord_delta.y)).xyz;
	colour_accum += texture(texture_source, coord_0 + vec2( coord_delta.x,  -coord_delta.y)).xyz;
	colour_accum += texture(texture_source, coord_0 + vec2(-coord_delta.x,   coord_delta.y)).xyz;
	colour_accum += texture(texture_source, coord_0 + vec2( coord_delta.x,   coord_delta.y)).xyz;
	
	color_out = vec4(colour_accum * 0.25, 1.0);
}