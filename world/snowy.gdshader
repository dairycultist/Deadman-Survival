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

vec3 triplanar_tritexture(sampler2D tex, vec3 d, vec3 n) {
	
	n = n * n;
    return (
		texture(tex, d.zy).xyz * n.x +
		texture(tex, d.xz).xyz * n.y +
		texture(tex, d.xy).xyz * n.z
	) / (n.x + n.y + n.z);
}

void fragment() {
	
	vec3 world_vertex = (INV_VIEW_MATRIX * vec4(VERTEX, 1.)).xyz;
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.)).xyz;
	
	vec3      a = triplanar_tritexture(albedo, world_vertex, world_normal).rgb;
	vec3 snow_a = triplanar_tritexture(snow_albedo, world_vertex * 0.2, world_normal).rgb;
	
	vec3      n = TBN * normalize(triplanar_tritexture(normal, world_vertex, world_normal).xyz * 2.0 - 1.0);
	vec3 snow_n = TBN * normalize(triplanar_tritexture(snow_normal, world_vertex * 0.2, world_normal).xyz * 2.0 - 1.0);
	
	float fac = smoothstep(-blend + bias, blend + bias, (INV_VIEW_MATRIX * vec4(n, 0.0)).y);
	
	ALBEDO    = mix(a, snow_a, fac);
	SPECULAR  = mix(0.5, 0.7, fac);
	ROUGHNESS = mix(1.0, 0.9, fac);
	NORMAL    = mix(n, snow_n, fac);
}
