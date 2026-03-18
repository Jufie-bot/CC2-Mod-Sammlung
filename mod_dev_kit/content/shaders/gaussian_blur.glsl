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
uniform vec2 blur_size;
uniform vec2 rand_offset;

//15x15 sig=2 kernel seperated
const int kernel_step_count = 15;
const float kernel[kernel_step_count] = float[kernel_step_count](0.000489, 0.002403, 0.009246, 0.02784, 0.065602, 0.120999, 0.174697, 0.197448, 0.174697, 0.120999, 0.065602, 0.02784, 0.009246, 0.002403, 0.000489);

float rand(in vec2 xy, in float seed)
{
    return fract(tan(distance(xy*1.61803398874989484820459, xy)*seed)*xy.x);
}

void main()
{
	vec2 coord_delta = blur_size * 0.005;
    vec2 coord_start = coord_0 - (coord_delta * (kernel_step_count / 2));

    vec3 colour_accum = vec3(0.0, 0.0, 0.0);
    for(int i = 0; i < kernel_step_count; i++ )                                                                                                                             
    {
        vec2 sample_coord = coord_start + (coord_delta * (i - 0.5 + rand((coord_start * i) + rand_offset, 1000.0)));
        colour_accum += texture(texture_source, sample_coord).xyz * kernel[i];                                                                                                                         
    } 
    
    color_out = vec4(colour_accum, 1.0);
}