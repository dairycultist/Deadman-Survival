shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, blend_mix;

uniform sampler2D tex : source_color;
uniform sampler2D tex_reflective : source_color;
uniform sampler2D tex_metallic : source_color;
uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);

uniform float highlight_amt : hint_range(0.0, 1.0);

void fragment() {
	ROUGHNESS = texture(tex_reflective, UV).r;
	SPECULAR = 1.0 - ROUGHNESS;
	METALLIC = 1.0 - texture(tex_metallic, UV).r;
	
	vec4 f = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	float highlight = abs(sin(TIME * 5.0));
	
	ALBEDO = min(texture(tex, UV).rgb * color + highlight * 0.2 * highlight_amt, vec3(1.0, 1.0, 1.0));
}