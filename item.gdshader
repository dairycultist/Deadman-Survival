shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, blend_mix;

uniform sampler2D tex : filter_nearest, source_color;
uniform vec3 color : source_color;
uniform float metallic : hint_range(0.0, 1.0);

uniform float highlight_amt : hint_range(0.0, 1.0);

void fragment() {
	METALLIC = metallic;
	ROUGHNESS = 0.5;
	
	vec4 f = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	float highlight = float(int((f.x + f.y + f.z + TIME * 0.1 + 1.0) * 20.0) % 2);
	
	ALBEDO = mix(color, vec3(1.,1.,1.), highlight * 0.1 * highlight_amt);
}