shader_type spatial;

// Placeholder ground for the first farm scene. Not final environment art.
// Flat near the barn and the walk loop; low hills only toward the edges.

varying vec3 local_pos;

uniform vec3 grass_a : source_color = vec3(0.300, 0.480, 0.240);
uniform vec3 grass_b : source_color = vec3(0.160, 0.320, 0.140);
uniform vec3 path_color : source_color = vec3(0.520, 0.370, 0.200);

void vertex() {
	vec3 p = VERTEX;
	float radial = length(p.xz);
	float hills = sin(p.x * 0.13) * cos(p.z * 0.11) * 1.5;
	hills += sin(p.x * 0.05 + p.z * 0.04) * 0.8;
	float edge = smoothstep(12.0, 20.0, radial);
	p.y += hills * edge;
	VERTEX = p;
	local_pos = p;
}

void fragment() {
	float n = sin(local_pos.x * 0.35) * cos(local_pos.z * 0.32);
	vec3 grass = mix(grass_a, grass_b, n * 0.5 + 0.5);
	float band = max(abs(local_pos.x), abs(local_pos.z));
	float on_path = step(5.4, band) * step(band, 7.0);
	ALBEDO = mix(grass, path_color, on_path);
	ROUGHNESS = 0.94;
}
