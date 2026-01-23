shader_type spatial;
render_mode world_vertex_coords;

uniform sampler2D Depth : hint_depth_texture, repeat_disable, filter_nearest;
uniform float noise_scale = 1.0;
uniform sampler3D Noise : repeat_enable;
uniform vec3 Color : source_color = vec3(1.0, 0.5, 0.0);

uniform float water_depth = 2.0;
uniform float wave_height = 1.0;

varying vec3 sample_pos;

void vertex() {

	// do displacement stuff
	sample_pos = vec3(VERTEX.x, 0, VERTEX.z) * noise_scale;

	float sample = texture(Noise, TIME * 0.01 + sample_pos).r;

	VERTEX.y += sample * wave_height;
	
	sample_pos *= 25.0;
	sample_pos += TIME * 0.01;
}

void fragment() {
	
	float sample_px = texture(Noise, sample_pos + vec3( 0.05, 0, 0)).r;
	float sample_nx = texture(Noise, sample_pos + vec3(-0.05, 0, 0)).r;
	float sample_pz = texture(Noise, sample_pos + vec3(0, 0,  0.05)).r;
	float sample_nz = texture(Noise, sample_pos + vec3(0, 0, -0.05)).r;

	NORMAL = (VIEW_MATRIX * vec4(normalize(vec3((sample_nx - sample_px) / 2.0, 1.0, (sample_nz - sample_pz) / 2.0)), 0.0)).xyz;

	METALLIC = 0.0;
	SPECULAR = 0.2;
	ROUGHNESS = 0.1;

	// use depth texture to make shallow areas more translucent
	float depth = texture(Depth, SCREEN_UV).x;
	vec4 view = INV_PROJECTION_MATRIX * vec4(vec3(SCREEN_UV * 2.0 - 1.0, depth), 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;

	float object_depth = FRAGCOORD.z;
	vec4 object_view = INV_PROJECTION_MATRIX * vec4(vec3(SCREEN_UV * 2.0 - 1.0, object_depth), 1.0);
	object_view.xyz /= object_view.w;
	float linear_object_depth = -object_view.z;

	float fade_fac = smoothstep(0.0, water_depth, linear_depth - linear_object_depth);
	float foam_fac = pow(smoothstep(0.0, water_depth * 0.2, linear_depth - linear_object_depth + sin(TIME * 2.0 + NORMAL.y * 10.0) * 0.05), 1.2);

	ALBEDO = mix(vec3(1.0), Color, foam_fac);
	
	float depth_fade = (fade_fac + (1.0 - foam_fac) + 1.0) / 2.0;
	float dist_fade = smoothstep(400.0, 500.0, distance((INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz, CAMERA_POSITION_WORLD));
	ALPHA = mix(depth_fade, 0.0, dist_fade);
}
