shader_type canvas_item;

uniform float pixelize_amount = 40.0;
uniform float lightness = 0.7;
uniform float alpha_cutoff = 0.0;

void fragment() {
	vec2 uv = round(UV * float(pixelize_amount)) / float(pixelize_amount) * 0.01;
	float a = fract(sin(dot(uv, vec2(12.9898, 78.233) * (TIME * 0.2))) * 438.5453) * lightness;
	
	COLOR.r = a;
	COLOR.g = a;
	COLOR.b = a;
	if (a >= alpha_cutoff) {
		COLOR.a = 0.0;
	}
}