shader_type canvas_item;

uniform sampler2D screen_texture:hint_screen_texture, repeat_disable;
uniform sampler2D color_lut:source_color;

void fragment() {
	
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (c.a > 0.0001) {
		c.rgb = texture(color_lut, vec2(c.r, 0)).rgb / c.a;
	}
	
	COLOR *= c;
}
