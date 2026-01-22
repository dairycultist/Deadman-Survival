shader_type spatial;

uniform sampler2D snow_albedo : source_color;
uniform sampler2D snow_normal : hint_normal;

uniform float blend = 0.1;

// https://godotforums.org/d/27986-custom-normal-map-shader/8
varying mat3 TBN; // from tangent to view

void vertex() {
	
	mat4 m = transpose(inverse(MODELVIEW_MATRIX));
    TBN = mat3(
        (m * vec4(TANGENT, 1.0)).xyz,
		(m * vec4(BINORMAL, 1.0)).xyz,
		-(m * vec4(NORMAL, 1.0)).xyz
    );
}

void fragment() {
	
	NORMAL = TBN * -normalize(texture(snow_normal, UV).xyz * 2.0 - 1.0);
	
	vec3 normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz + texture(snow_normal, UV).rgb;
	
	float fac = smoothstep(-blend + 0.5, blend + 0.5, normal.y);
	
	ALBEDO = mix(vec3(0.), mix(texture(snow_albedo, UV).rgb, vec3(1.), fac * 0.5), fac);
	
	SPECULAR = 1.0;
	ROUGHNESS = 1.0;
}
