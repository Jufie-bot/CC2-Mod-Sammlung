#vertex_shader

in vec3 vertex_position_in;

out vec3 vertex_world_pos;

uniform mat4 mat_view;
uniform mat4 mat_proj;
uniform mat4 mat_world;

void main()
{
	vec4 vertex_position_world = mat_world * vec4(vertex_position_in, 1);
	vertex_world_pos = vertex_position_world.xyz;

	gl_Position = mat_proj * mat_view * vertex_position_world;
}

#fragment_shader

in vec3 vertex_world_pos;

out vec4 color_out;

uniform sampler2D texture_weather;
uniform sampler2D texture_ocean_currents;

uniform sampler2D texture_ocean_world_magnitude;
uniform float ocean_world_size;

uniform sampler2D texture_weather_properties;

uniform int render_mode;

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float floor_step(float value, float step)
{
	return floor(value / step) * step;
}

void main()
{
	vec2 ocean_sample_pos = vec2(
			(0.5 + (vertex_world_pos.x / ocean_world_size)),
			(0.5 + (vertex_world_pos.z / ocean_world_size))
		);

	if(render_mode == 1 || render_mode == 7)
	{
		// cartographic
		
		color_out = vec4(0.0, 0.01, 0.02, 1.0);
	}
	else if(render_mode == 8)
	{
		discard;
	}
	else if(render_mode == 2)
	{
		// wind speed

		vec3 weather_sample = texture(texture_weather, ocean_sample_pos).xyz;

		float wind_velocity = length(weather_sample.xy) * 0.22;

		color_out = vec4(hsv2rgb(vec3(mix(0.2, 1.2, wind_velocity), wind_velocity, pow(wind_velocity, 3.0))), 1.0);
	}
	else if(render_mode == 3)
	{
		// precipitation

		vec3 weather_sample = texture(texture_weather_properties, ocean_sample_pos).xyz;

		float lightning = clamp((weather_sample.x * weather_sample.z - 0.25) * 2.0, 0.0, 1.0);
		float precipitation = clamp((weather_sample.z - 0.66) * 3.0, 0.0, 1.0);

		lightning = floor_step(lightning, 0.1);
		precipitation = floor_step(precipitation, 0.1);

		if(lightning > 0)
		{
			color_out = vec4(lightning, 1.0, 0.0, 1.0);
		}
		else
		{
			color_out = vec4(precipitation, pow(precipitation, 8.0), pow(precipitation, 2.0), 1.0);
		}
		
		color_out = mix(vec4(0.0, 0.0, 0.0, 1.0), mix(vec4(0.0, 0.0, 1.0, 1.0), vec4(1.0, 0.0, 0.0, 1.0), lightning), precipitation);
	}
	else if(render_mode == 4)
	{
		// fog

		vec3 weather_sample = texture(texture_weather_properties, ocean_sample_pos).xyz;

		float fog = weather_sample.y;

		color_out = vec4(hsv2rgb(vec3(round(fog * 40.0) / 40.0, 1.0 - fog, pow(1.0 - fog, 4.0))), 1.0);
	}
	else if(render_mode == 5)
	{
		// ocean current flow

		vec3 ocean_current_sample = texture(texture_ocean_currents, ocean_sample_pos).xyz;

		float ocean_current_velocity = length(ocean_current_sample.xy) * 0.24;

		ocean_current_sample.z *= 0.2;
		ocean_current_sample.z += 0.5;

		color_out = vec4(pow(ocean_current_sample.z * 0.1, 8.0), pow(ocean_current_velocity, 4.0), pow(ocean_current_velocity, 2.0), 1.0);
	}
	else if(render_mode == 6)
	{
		// ocean depth

		float ocean_sample_magnitude = texture(texture_ocean_world_magnitude, ocean_sample_pos).r;
		ocean_sample_magnitude = mix(0.1, 1.0, ocean_sample_magnitude);

		ocean_sample_magnitude = floor_step(ocean_sample_magnitude, 0.02);

		float ocean_sample_height = -10.0 - (ocean_sample_magnitude * 40.0);

		float depth_min = -10.0;
		float depth_max = -50.0;
		float depth_factor = pow(clamp((ocean_sample_height - depth_min) / (depth_max - depth_min), 0.0, 1.0), 0.8);

		color_out = vec4(hsv2rgb(vec3(mix(0.26, 1.0, smoothstep(0.0, 1.0, depth_factor)), 1.0, mix(1.0, 0.0, depth_factor))), 1.0);
	}
	else
	{
		color_out = vec4(1.0, 0.0, 0.0, 1.0);
	}
}
