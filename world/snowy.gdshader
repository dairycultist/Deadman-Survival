shader_type spatial;

uniform sampler2D snow_albedo : source_color;
uniform sampler2D snow_normal : source_color;

uniform float blend = 0.1;

void fragment() {
	
	vec3 normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz + texture(snow_normal, UV).rgb;
	
	float fac = smoothstep(-blend, blend, normal.y);
	
	ALBEDO = mix(vec3(0.), mix(texture(snow_albedo, UV).rgb, vec3(1.), fac * 0.5), fac);
	
	SPECULAR = 1.0;
	ROUGHNESS = 1.0;
}
