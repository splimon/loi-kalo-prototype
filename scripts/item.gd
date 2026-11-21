extends Node3D
## A carryable thing: huli, kalo, poi, an ipu, etc. Placeholder meshes only.

var main
var kind := ""
var vis: Node3D
var label: Label3D


func setup(m, k: String) -> void:
	main = m
	label = main.label3d(self, "", Vector3(0, 0.75, 0), 30, Color(1, 1, 0.85), true)
	label.pixel_size = 0.006
	set_kind(k)


func set_kind(k: String) -> void:
	kind = k
	if vis:
		vis.queue_free()
	vis = Node3D.new()
	add_child(vis)
	match k:
		"huli":
			main.add_mesh(vis, main.sphere(0.1), Color(0.5, 0.36, 0.4), Vector3(0, 0.08, 0))
			main.add_mesh(vis, main.cyl(0.03, 0.05, 0.5), Color(0.45, 0.6, 0.3), Vector3(0, 0.33, 0))
			main.add_mesh(vis, main.cyl(0.02, 0.04, 0.4), Color(0.45, 0.6, 0.3), Vector3(0.06, 0.28, 0), Vector3(0, 0, -0.35))
		"kalo":
			main.add_mesh(vis, main.sphere(0.22), Color(0.45, 0.32, 0.26), Vector3(0, 0.24, 0), Vector3.ZERO, Vector3(1, 1.25, 1))
			main.add_mesh(vis, main.cyl(0.04, 0.07, 0.25), Color(0.45, 0.6, 0.3), Vector3(0, 0.55, 0))
		"kalo_cooked":
			main.add_mesh(vis, main.sphere(0.22), Color(0.62, 0.5, 0.66), Vector3(0, 0.24, 0), Vector3.ZERO, Vector3(1, 1.2, 1))
		"lau":
			main.add_mesh(vis, main.sphere(0.32), Color(0.3, 0.7, 0.3), Vector3(0, 0.15, 0), Vector3(0.2, 0, 0), Vector3(1, 0.12, 1.25))
		"luau":
			main.add_mesh(vis, main.sphere(0.22), Color(0.14, 0.32, 0.12), Vector3(0, 0.15, 0), Vector3.ZERO, Vector3(1.2, 0.55, 1.2))
		"paiai":
			main.add_mesh(vis, main.sphere(0.24), Color(0.68, 0.58, 0.74), Vector3(0, 0.17, 0), Vector3.ZERO, Vector3(1.2, 0.7, 1.2))
		"paiai_wrapped":
			main.add_mesh(vis, main.sphere(0.26), Color(0.22, 0.6, 0.28), Vector3(0, 0.2, 0), Vector3.ZERO, Vector3(1.1, 0.8, 1.4))
			main.add_mesh(vis, main.torus(0.17, 0.22), Color(0.5, 0.35, 0.2), Vector3(0, 0.2, 0), Vector3(PI / 2, 0, 0))
		"poi":
			main.add_mesh(vis, main.cyl(0.3, 0.2, 0.22), Color(0.45, 0.28, 0.15), Vector3(0, 0.11, 0))
			main.add_mesh(vis, main.cyl(0.27, 0.27, 0.03), Color(0.72, 0.62, 0.8), Vector3(0, 0.22, 0))
		"ipu_empty", "ipu_full":
			main.add_mesh(vis, main.sphere(0.26), Color(0.82, 0.7, 0.45), Vector3(0, 0.26, 0))
			main.add_mesh(vis, main.cyl(0.07, 0.1, 0.18), Color(0.78, 0.66, 0.42), Vector3(0, 0.56, 0))
			if k == "ipu_full":
				main.add_mesh(vis, main.sphere(0.08), Color(0.3, 0.65, 0.95), Vector3(0, 0.66, 0))
		_:
			main.add_mesh(vis, main.box(0.3, 0.3, 0.3), Color.MAGENTA, Vector3(0, 0.15, 0))
	if label:
		label.text = main.item_name(k)
