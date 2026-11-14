shader_type spatial;

render_mode unshaded, cull_disabled;

uniform bool active = false;
uniform vec4 flash_color: source_color = vec4(1.0, 0.2, 0.2, 1.0);
uniform sampler2D tex: source_color, filter_nearest_mipmap;

uniform bool use_billboard;
uniform float growth_amt;

void vertex() {
	if (use_billboard){
        MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		vec3 direction = sign(VERTEX);
		VERTEX += direction * vec3(growth_amt, growth_amt + 0.15, growth_amt);
	}
}

uniform float tint : hint_range(0.0, 1.0) = 0.5;
uniform float fade : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	if (active) {
		vec4 color = texture(tex, UV);
		ALPHA = color.a * fade;
		ALBEDO = vec3(flash_color.r, flash_color.g, flash_color.b);
	} else {
		vec4 color = texture(tex, UV);
		ALPHA = color.a;
		ALBEDO = vec3(color.r, color.g, color.b);
	}
}