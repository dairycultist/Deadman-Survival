shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, blend_mix;

uniform sampler2D tex : source_color;
uniform sampler2D tex_reflective : source_color;
uniform vec3 color : source_color;
uniform float metallic : hint_range(0.0, 1.0);

uniform float highlight_amt : hint_range(0.0, 1.0);

void fragment() {
	METALLIC = metallic;
	ROUGHNESS = texture(tex_reflective, UV).r;
	SPECULAR = ROUGHNESS;
	
	vec4 f = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	float highlight = abs(sin(TIME * 5.0));
	
	ALBEDO = mix(texture(tex, UV).rgb * color, vec3(1.,1.,1.), highlight * 0.1 * highlight_amt);
}