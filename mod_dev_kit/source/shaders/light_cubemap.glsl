#vertex_shader

in vec3 vertex_position_in;

uniform mat4 mat_camera_transform;

out vec3 vertex_world_normal_out;

void main()
{
	vertex_world_normal_out = (mat_camera_transform * vec4(vertex_position_in * vec3(1.0, -1.0, 1.0) * (33.0 / 32.0) + vec3(0.0, 0.0, 0.5), 0.0)).xyz;
	gl_Position = vec4(vertex_position_in * 2.0, 1.0);
}

#fragment_shader

in vec3 vertex_world_normal_out;

out vec4 color_out;

uniform vec3 light_dir;

#define PI 3.1415926535
#define PI_2 (PI * 2.0)

#define EPSILON 1e-5

#define SAMPLES_NUMS 16

const float sun_radius = 2000.0;
const float sun_radiance = 20.0;

const float mie_g = 0.76;
const float mie_height = 1200.0;

const float rayleigh_height = 8000.0;

const vec3 wave_lambda_mie = vec3(2e-7);
const vec3 wave_lambda_ozone = vec3(1.36820899679147, 3.31405330400124, 0.13601728252538) * 0.6e-6 * 2.504;

const float earth_radius = 6360000.0;
const float earth_atm_top_radius = 6420000.0;
const vec3 earth_center = vec3(0, -earth_radius, 0);

vec3 compute_sphere_normal(vec2 coord, float phi_start, float phi_length, float theta_start, float theta_length)
{
	vec3 normal;
	normal.x = -sin(theta_start + coord.y * theta_length) * sin(phi_start + coord.x * phi_length);
	normal.y = -cos(theta_start + coord.y * theta_length);
	normal.z = -sin(theta_start + coord.y * theta_length) * cos(phi_start + coord.x * phi_length);
	return normalize(normal);
}

vec2 compute_ray_sphere_intersection(vec3 position, vec3 dir, vec3 center, float radius)
{
	vec3 origin = position - center;
	float B = dot(origin, dir);
	float C = dot(origin, origin) - radius * radius;
	float D = B * B - C;

	vec2 minimax_intersections;
	if (D < 0.0)
	{
		minimax_intersections = vec2(-1.0, -1.0);
	}
	else
	{
		D = sqrt(D);
		minimax_intersections = vec2(-B - D, -B + D);
	}

	return minimax_intersections;
}

vec3 compute_wave_lambda_rayleigh(vec3 lambda)
{
	const float n = 1.0003;
	const float N = 2.545E25;
	const float pn = 0.035;
	const float n2 = n * n;
	const float pi3 = PI * PI * PI;
	const float rayleigh_const = (8.0 * pi3 * pow(n2 - 1.0,2.0)) / (3.0 * N) * ((6.0 + 3.0 * pn) / (6.0 - 7.0 * pn));
	return rayleigh_const / (lambda * lambda * lambda * lambda);
}

float compute_phase_mie(float theta, float g)
{
	float g2 = g * g;
	return (1.0 - g2) / pow(1.0 + g2 - 2.0 * g * clamp(theta, 0.0, 1.0), 1.5) / (4.0 * PI);
}

float compute_phase_rayleigh(float theta)
{
	float theta2 = theta * theta;
	return (theta2 * 0.75 + 0.75) / (4.0 * PI);
}

float chapman_approximation(float X, float h, float cos_zenith)
{
	float c = sqrt(X + h);
	float c_exp_h = c * exp(-h);

	if (cos_zenith >= 0.0)
	{
		return c_exp_h / (c * cos_zenith + 1.0);
	}
	else
	{
		float x0 = sqrt(1.0 - cos_zenith * cos_zenith) * (X + h);
		float c0 = sqrt(x0);

		return 2.0 * c0 * exp(X - x0) - c_exp_h / (1.0 - c * cos_zenith);
	}
}

float get_optical_depth_schueler(float h, float H, float earth_radius, float cos_zenith)
{
	return H * chapman_approximation(earth_radius / H, h / H, cos_zenith);
}

vec3 get_transmittance(vec3 L, vec3 V, vec3 wave_lambda_rayleigh)
{
	float ch = get_optical_depth_schueler(L.y, rayleigh_height, earth_radius, V.y);
	return exp(-(wave_lambda_mie + wave_lambda_rayleigh) * ch);
}

vec2 compute_optical_depth(vec3 sample_point, vec3 V, vec3 L, float neg)
{
	float rl = length(sample_point);
	float h = rl - earth_radius;
	vec3 r = sample_point / rl;

	float cos_chi_sun = dot(r, L);
	float cos_chi_ray = dot(r, V * neg);

	float optical_depth_sun = get_optical_depth_schueler(h, rayleigh_height, earth_radius, cos_chi_sun);
	float optical_depth_camera = get_optical_depth_schueler(h, rayleigh_height, earth_radius, cos_chi_ray) * neg;

	return vec2(optical_depth_sun, optical_depth_camera);
}

void aerial_perspective(vec3 start, vec3 end, vec3 V, vec3 L, vec3 wave_lambda_rayleigh, bool infinite, out vec3 transmittance, out vec3 insctr_mie, out vec3 insctr_rayleigh)
{
	float inf_neg = infinite ? 1.0 : -1.0;

	vec3 sample_step = (end - start) / float(SAMPLES_NUMS);
	vec3 sample_point = end - sample_step;
	vec3 sample_lambda = wave_lambda_mie + wave_lambda_rayleigh + wave_lambda_ozone;

	float sampleLength = length(sample_step);

	vec3 scattering = vec3(0.0);
	vec2 last_optical_depth = compute_optical_depth(end, V, L, inf_neg);

	for (int i = 1; i < SAMPLES_NUMS; i++, sample_point -= sample_step)
	{
		vec2 optical_depth = compute_optical_depth(sample_point, V, L, inf_neg);

		vec3 segment_s = exp(-sample_lambda * (optical_depth.x + last_optical_depth.x));
		vec3 segment_t = exp(-sample_lambda * (optical_depth.y - last_optical_depth.y));
		
		transmittance *= segment_t;
		
		scattering = scattering * segment_t;
		scattering += exp(-(length(sample_point) - earth_radius) / rayleigh_height) * segment_s;

		last_optical_depth = optical_depth;
	}

	insctr_mie = scattering * wave_lambda_mie * sampleLength;
	insctr_rayleigh = scattering * wave_lambda_rayleigh * sampleLength;
}

float compute_skybox_chapman(vec3 eye, vec3 V, vec3 L, vec3 wave_lambda_rayleigh, out vec3 transmittance, out vec3 insctr_mie, out vec3 insctr_rayleigh)
{
	bool neg = true;

	vec2 outerIntersections = compute_ray_sphere_intersection(eye, V, earth_center, earth_atm_top_radius);
	if (outerIntersections.y < 0.0) return 0.0;

	vec2 innerIntersections = compute_ray_sphere_intersection(eye, V, earth_center, earth_radius);
	if (innerIntersections.x > 0.0)
	{
		neg = false;
		outerIntersections.y = innerIntersections.x;
	}

	eye -= earth_center;

	vec3 start = eye + V * max(0.0, outerIntersections.x);
	vec3 end = eye + V * outerIntersections.y;

	aerial_perspective(start, end, V, L, wave_lambda_rayleigh, neg, transmittance, insctr_mie, insctr_rayleigh);

	bool intersection_test = innerIntersections.x < 0.0 && innerIntersections.y < 0.0;
	return intersection_test ? 1.0 : 0.0;
}

vec4 compute_sky_inscattering(vec3 eye, vec3 V, vec3 L)
{
    vec3 wave_lambda_rayleigh = compute_wave_lambda_rayleigh(vec3(680e-9, 550e-9, 450e-9));
	vec3 insctr_mie = vec3(0.0);
	vec3 insctr_rayleigh = vec3(0.0);
	vec3 insctr_optical_length = vec3(1.0);
	float intersection_test = compute_skybox_chapman(eye, V, L, wave_lambda_rayleigh, insctr_optical_length, insctr_mie, insctr_rayleigh);

	float phase_theta = dot(V, L);
	float phase_mie = compute_phase_mie(phase_theta, mie_g);
	float phase_rayleigh = compute_phase_rayleigh(phase_theta);
	float phase_night = 1.0 - clamp(insctr_optical_length.x * EPSILON, 0.0, 1.0);

	vec3 insctrTotalMie = insctr_mie * phase_mie;
	vec3 insctrTotalRayleigh = insctr_rayleigh * phase_rayleigh;

	vec3 sky = (insctrTotalMie + insctrTotalRayleigh) * sun_radiance;

	return vec4(sky, phase_night * intersection_test);
}

void main()
{
	vec3 world_normal = normalize(vertex_world_normal_out);

	vec3 V = world_normal;
    vec3 L = -light_dir;
    vec3 eye = vec3(0,1000.0,0);
    
   	vec3 atmosphere_color = compute_sky_inscattering(eye, V, L).xyz;

	color_out = vec4(atmosphere_color, 1.0);
}