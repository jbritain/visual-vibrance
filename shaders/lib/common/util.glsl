#ifndef UTIL_GLSL
#define UTIL_GLSL

float luminance(vec3 color){
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

// https://blog.demofox.org/2022/01/01/interleaved-gradient-noise-a-different-kind-of-low-discrepancy-sequence/
// adapted with help from balint and hardester
float interleavedGradientNoise(vec2 coord){
	return fract(52.9829189 * fract(0.06711056 * coord.x + (0.00583715 * coord.y)));
}

float interleavedGradientNoise(vec2 coord, int frame){
	return interleavedGradientNoise(coord + 5.588238 * (frame & 63));
}

mat2 rotate(float a) {
    vec2 m;
    m.x = sin(a);
    m.y = cos(a);
	return mat2(m.y, -m.x,  m.x, m.y);
}


vec2 sincos(float x) { return vec2(sin(x), cos(x)); }

vec2 rotate(vec2 vector, float angle) {
	vec2 sc = sincos(angle);
	return vec2(sc.y * vector.x + sc.x * vector.y, sc.y * vector.y - sc.x * vector.x);
}

vec3 rotate(vec3 vector, vec3 axis, float angle) {
	// https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula
	vec2 sc = sincos(angle);
	return sc.y * vector + sc.x * cross(axis, vector) + (1.0 - sc.y) * dot(axis, vector) * axis;
}

vec3 rotate(vec3 vector, vec3 from, vec3 to) {
	// where "from" and "to" are two unit vectors determining how far to rotate
	// adapted version of https://en.wikipedia.org/wiki/Rodrigues%27_rotation_formula

	float cosTheta = dot(from, to);
	if (abs(cosTheta) >= 0.9999) { return cosTheta < 0.0 ? -vector : vector; }
	vec3 axis = normalize(cross(from, to));

	vec2 sc = vec2(sqrt(1.0 - cosTheta * cosTheta), cosTheta);
	return sc.y * vector + sc.x * cross(axis, vector) + (1.0 - sc.y) * dot(axis, vector) * axis;
}

#endif // UTIL_GLSL