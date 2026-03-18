#vertex_shader

in vec3 vertex_position_in;

out float logz;

uniform mat4 mat_view;
uniform mat4 mat_proj;

uniform mat4 spot_light_cone_transform;

void main()
{
    gl_Position = mat_proj * mat_view * spot_light_cone_transform * vec4(vertex_position_in, 1.0);
	logz = 1.0 + gl_Position.w;
}

#fragment_shader
            
in float logz;

out vec4 color_out;

uniform sampler2D texture_normal;
uniform sampler2D texture_light_gradient;

#if (CAST_SHADOW == 1)
uniform sampler2DShadow texture_depth_shadow;
#endif

uniform mat4 mat_projection;
uniform mat4 mat_projection_inverse;
uniform vec2 target_size;

uniform vec3 light_color;
uniform vec3 light_position_view;
uniform vec3 light_direction_view;
uniform float light_fov;
uniform mat4 mat_view_to_light_proj;


uniform float volume_scale;
uniform float fog_half_distance_inv;
uniform float day_time_factor;
uniform float far_plane_coefficient;
uniform float light_far_plane_coefficient;
uniform vec2 inv_resolution_scale;

bool ray_cone_intersect(vec3 ray_dir, vec3 cone_pos, vec3 cone_dir, float cone_fov, out vec2 out_intersect_factors)
{
    const float max_distance = 10000;
    vec3 ray_start = cone_dir - cone_pos;
    float a = dot(ray_dir, cone_dir);
    float b = dot(ray_dir, ray_dir);
    float c = dot(ray_start, cone_dir);
    float d = dot(ray_start, ray_dir);
    float e = dot(ray_start, ray_start);

    float cos_fov = cos(cone_fov * 0.5);
    cos_fov *= cos_fov;
    float A = a*a - b*cos_fov;
    float B = 2 * (c*a - d*cos_fov);
    float C = c*c - e*cos_fov;
    float D = B*B - 4*A*C;

    if (D > 0)
    {
        D = sqrt(D);
        vec2 t = (-B + sign(A)*vec2(-D, +D)) / (2 * A);
        bvec2 b2_is_correct;
        b2_is_correct.x = c + a * t.x > 0 && t.x > 0;
        b2_is_correct.y = c + a * t.y > 0 && t.y > 0;
        t.x = t.x * (b2_is_correct.x ? 1 : 0) + (!b2_is_correct.x ? 1 : 0) * (max_distance);
        t.y = t.y * (b2_is_correct.y ? 1 : 0) + (!b2_is_correct.y ? 1 : 0) * (max_distance);
        t = clamp(t, vec2(0.0), vec2(max_distance));
        out_intersect_factors = t;
        return true;
    }
    else
    {
        out_intersect_factors = vec2(max_distance, max_distance);
        return false;
    }
}

bool get_light_volume_intersection(vec3 ray_dir, vec3 cone_pos, vec3 cone_dir, float cone_fov, out vec3 intersect_start, out float intersect_length)
{
    vec2 cone_intersect_factors;

    bool is_hit_cone = ray_cone_intersect(ray_dir, cone_pos, cone_dir, cone_fov, cone_intersect_factors);
    
    intersect_start = ray_dir * min(cone_intersect_factors.x, cone_intersect_factors.y);
    intersect_length = abs(cone_intersect_factors.x - cone_intersect_factors.y);
    //intersect_start = vec3(0.0);
    //intersect_length = max(cone_intersect_factors.x, cone_intersect_factors.y);

    return is_hit_cone;
}

void main()
{
	gl_FragDepth = log2(logz) * far_plane_coefficient;
    
    vec2 screen_coord = gl_FragCoord.xy / target_size;
    vec4 normal = texture(texture_normal, screen_coord);
    
	vec3 ndc_pos = vec3((vec2(2.0, 2.0) * screen_coord * inv_resolution_scale) - vec2(1.0, 1.0), 1.0);
    vec4 clip_pos;
    clip_pos.w = mat_projection[3][2] / (ndc_pos.z - (mat_projection[2][2] / mat_projection[2][3]));
    clip_pos.xyz = ndc_pos * clip_pos.w;

	vec3 camera_to_fragment_projected = (mat_projection_inverse * clip_pos).xyz;
	camera_to_fragment_projected /= -camera_to_fragment_projected.z;
    vec3 camera_to_fragment = normalize(camera_to_fragment_projected);
    vec3 view_position = camera_to_fragment_projected * normal.w;

    // cone intersection

    vec3 intersect_start;
    float intersect_length;
    if(get_light_volume_intersection(camera_to_fragment, light_position_view, light_direction_view, light_fov, intersect_start, intersect_length))
    {
        float light_accumulation = 0.0;

        int num_steps = 16;
        for(int i = 0; i < num_steps; i++)
        {
            vec3 sample_position = intersect_start + (camera_to_fragment * intersect_length * float(i) / num_steps);

            if(sample_position.z > view_position.z * 1.001)
            {
                vec4 coord =  mat_view_to_light_proj * vec4(sample_position, 1.0);
                coord.xyz /= coord.w;
                coord.xyz = coord.xyz * 0.5 + 0.5;
                float cone_distance_factor = 1.0 - coord.z;
	            coord.z = log2(1.0 + coord.w) * light_far_plane_coefficient;

                if(coord.z > 0.0 && coord.z < 1.0)
                {
#if CAST_SHADOW == 1
                    float shadow_sample = texture(texture_depth_shadow, clamp(coord.xyz, 0.0, 1.0));

                    if(shadow_sample > 0.0)
#endif
                    {
                        float center_factor = max((0.5 - length(vec2(0.5, 0.5) - coord.xy)) * 2.0, 0.0);
                        light_accumulation += center_factor * center_factor * cone_distance_factor;
                    }
                }
            }
        }

        light_accumulation /= float(num_steps);

        // fog
        float fog_factor = 1.0 - (1.0 / ((-intersect_start.z * fog_half_distance_inv) + 1.0));
        float light_texture_half_pixel_size = 0.5 / textureSize(texture_light_gradient, 0).x;
        vec3 fog_sample = texture(texture_light_gradient, vec2
            (
                mix(light_texture_half_pixel_size, 0.25 - light_texture_half_pixel_size, day_time_factor), 
                mix(light_texture_half_pixel_size, 1.0 - light_texture_half_pixel_size, fog_factor))
            ).xyz;
        fog_sample = pow(fog_sample, vec3(2.2));
    
        vec3 fog_light_color = mix(vec3(1.0), fog_sample.xyz, fog_factor);
        vec3 result_color = light_color * fog_light_color * fog_factor * light_accumulation * volume_scale * 0.2;

        color_out = vec4(result_color, 0.0);
    }
    else
    {
        color_out = vec4(0.0, 0.0, 0.0, 0.0);
    }
}