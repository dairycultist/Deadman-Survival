shader_type spatial;

uniform sampler2D albedo : source_color;
uniform sampler2D normal : hint_normal;
uniform sampler2D snow_albedo : source_color;
uniform sampler2D snow_normal : hint_normal;

uniform float blend = 0.1;
uniform float bias = 0.0;

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
	
	vec3      n = TBN *  normalize(texture(     normal, UV).xyz * 2.0 - 1.0);
	vec3 snow_n = TBN * -normalize(texture(snow_normal, UV).xyz * 2.0 - 1.0);
	                 // ^ I think my normal texture is inverted
	
	float fac = smoothstep(-blend + bias, blend + bias, (INV_VIEW_MATRIX * vec4(n, 0.0)).y);
	
	ALBEDO    = mix(texture(albedo, UV).rgb, texture(snow_albedo, UV).rgb, fac);
	SPECULAR  = mix(0.5, 1., fac);
	ROUGHNESS = mix(1.0, .7, fac);
	NORMAL    = mix(n, snow_n, fac);
}
