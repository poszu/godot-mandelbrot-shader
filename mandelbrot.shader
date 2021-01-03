shader_type canvas_item;

//`limit` was originally uniform, but I get an error in WebGL:
//**ERROR**: CanvasShaderGLES2: Fragment shader compilation failed:
// ERROR: 0:552: 'm_i' : Loop index cannot be compared with non-constant expression
const int limit = 1024;

uniform vec2 upper_left = vec2(-1.2, 0.35);
uniform vec2 lower_right = vec2(-1.0, 0.20);
uniform vec3 color_factor = vec3(1.0, 1.0, 1.0);

float width() {
	return lower_right.x - upper_left.x;
} 

float height() {
	return upper_left.y - lower_right.y;
}

vec2 pixel2point(vec2 pixel_uv) {
	float x = upper_left.x + width() * pixel_uv.x;
	float y = upper_left.y - height() * pixel_uv.y;
	return vec2(x, y);
}

vec2 complex_square(vec2 num) {
	float real = num.x * num.x - num.y * num.y;
	float imag = 2.0 * num.x * num.y;
	return vec2(real, imag);
}

int escape_time(vec2 point) {
	vec2 z = vec2(0.0, 0.0);
	
	for (int i = 0; i < limit; i++) {
		z = complex_square(z) + point;
		if ( z.x * z.x + z.y * z.y >= 4.0) {
			return i;
		}
	}
	return -1;
}

void fragment() {
	
	vec2 point = pixel2point(UV);
	
	int escape_time = escape_time(point);
	
	if (escape_time == -1) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		float fac = float(escape_time) / float(limit);
		COLOR = vec4(color_factor * fac, 1.0);
	}
	
}