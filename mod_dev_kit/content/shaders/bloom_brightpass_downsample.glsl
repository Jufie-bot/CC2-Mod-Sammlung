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
uniform float threshold;

#define BRIGHT_FILTER_2

vec3 bright_filter_threshold(vec3 colour)
{
	float brightness = max(colour.r, max(colour.g, colour.b));
	float contribution = max(0, brightness - threshold);
	contribution /= max(brightness, 0.00001);
	return colour * contribution;
}

vec3 bright_filter(vec3 colour)
{
	return bright_filter_threshold(colour);
}

void main()
{
	//BRIGHT_FILTER_1 will apply bright filter at the full source resolution, and average down.
	//BRIGHT_FILTER_2 will apply bright filter at half source resolution, and average down.
	//BRIGHT_FILTER_4 will apply bright filter at quarter source resolution.

#if defined (BRIGHT_FILTER_1)
	
	ivec2 load_coord = ivec2(coord_0 / source_pixel_size);
	vec3 bright_accum = vec3(0.0, 0.0, 0.0);
	
	for(int dX = -2; dX <= 2; ++dX)
	{
		for(int dY = -2; dY <= 2; ++dY)
		{
			ivec2 load_offset = ivec2(dX, dY);
			bright_accum += bright_filter(texelFetchOffset(texture_source, load_coord, 0, load_offset).xyz);
		}
	}
	color_out = vec4(bright_accum * 0.0625, 1.0);
	
#elif defined (BRIGHT_FILTER_2)

	vec2 delta_coord = (source_pixel_size, source_pixel_size);
	vec3 bright_accum = vec3(0.0, 0.0, 0.0);
	bright_accum += bright_filter(texture(texture_source, coord_0 + vec2(-delta_coord.x, -delta_coord.y)).xyz);
	bright_accum += bright_filter(texture(texture_source, coord_0 + vec2(delta_coord.x, -delta_coord.y)).xyz);
	bright_accum += bright_filter(texture(texture_source, coord_0 + vec2(-delta_coord.x, delta_coord.y)).xyz);
	bright_accum += bright_filter(texture(texture_source, coord_0 + vec2(delta_coord.x, delta_coord.y)).xyz);
	color_out = vec4(bright_accum * 0.25, 1.0);
	
#elif defined (BRIGHT_FILTER_4)
	
	vec2 delta_coord = (source_pixel_size, source_pixel_size);
	vec3 colour_accum = vec3(0.0, 0.0, 0.0);
	colour_accum += texture(texture_source, coord_0 + vec2(-delta_coord.x, -delta_coord.y)).xyz;
	colour_accum += texture(texture_source, coord_0 + vec2(delta_coord.x, -delta_coord.y)).xyz;
	colour_accum += texture(texture_source, coord_0 + vec2(-delta_coord.x, delta_coord.y)).xyz;
	colour_accum += texture(texture_source, coord_0 + vec2(delta_coord.x, delta_coord.y)).xyz;
	color_out = vec4(bright_filter(colour_accum * 0.25), 1.0);
	
#endif
}