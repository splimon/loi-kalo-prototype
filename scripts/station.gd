extends Node3D
## Every interactive spot in the level: planting spots in the loʻi, the imu,
## the papa kuʻi ʻai, the poʻo wai gate, debris in the ʻauwai, and so on.
## One script with a `kind` keeps the prototype easy to read and tweak.

const COOK_TIME := 12.0
const COOKED := {"kalo": "kalo_cooked", "lau": "luau"}
const WORK_TIME := {
	"Pull mauʻu (weeds)": 1.0,
	"Harvest kalo": 1.4,
	"Pick lau (leaves)": 0.8,
	"Pound kalo": 4.0,
	"Mix with wai": 2.0,
	"Clear ʻōpala": 1.3,
	"Rebuild kuāuna": 3.0,
	"Take ALL the water": 0.9,
	"Share the water": 0.9,
}

var main
var kind := ""
var reach := 1.3
var progress := 0.0
var work_tag := ""
var bar: Node3D
var bar_fill: MeshInstance3D
var slot_item = null
var slot_pos := Vector3(0, 0.8, 0)
var sway := 0.0

# plot
var loi := 0
var planted := false
var growth := 0.0
var weed := false
var plant_root: Node3D
var stalks: Array = []
var weed_node: Node3D
var ring: MeshInstance3D
# imu
var imu_slots: Array = []
var imu_bars: Array = []
var steam: Array = []
# huli pile
var count := 0
var pile_nodes: Array = []
# gate
var gate_board: MeshInstance3D
var gate_label: Label3D
# wai stand
var wai_dots: Array = []
# papa
var pounder: Node3D
var pound_anim := 0.0


func setup(m, k: String, opts: Dictionary) -> void:
	main = m
	kind = k
	sway = randf() * TAU
	match kind:
		"plot":
			loi = opts.get("loi", 0)
			planted = opts.get("planted", false)
			growth = opts.get("growth", 0.0)
			reach = 1.15
			_build_plot()
		"huli_pile":
			count = opts.get("count", 2)
			_build_huli_pile()
		"gate":
			reach = 1.6
			_build_gate()
		"clog":
			reach = 1.3
			_build_clog()
		"breach":
			reach = 1.6
			_build_breach()
		"imu":
			reach = 1.6
			_build_imu()
		"papa":
			reach = 1.3
			slot_pos = Vector3(-0.25, 0.12, 0)
			_build_papa()
		"wai_stand":
			_build_wai_stand()
		"umeke":
			slot_pos = Vector3(0, 0.55, 0)
			_build_umeke()
		"counter":
			reach = 1.1
			slot_pos = Vector3(0, 0.72, 0)
			main.add_mesh(self, main.cyl(0.45, 0.5, 0.7), Color(0.5, 0.33, 0.2), Vector3(0, 0.35, 0))
		"kahawai":
			reach = 1.6
			main.add_mesh(self, main.cyl(0.6, 0.7, 0.15), Color(0.5, 0.5, 0.48), Vector3(0, 0.05, 0))
			main.label3d(self, "Kahawai\n(fill ipu here)", Vector3(0, 1.4, 0), 40, Color(0.75, 0.9, 1))
		"ki":
			reach = 1.5
			_build_ki()
		"aha":
			reach = 2.2
			_build_aha()
		"tutu":
			reach = 1.4
			_build_tutu()
	_build_bar()


# ---------------------------------------------------------------- visuals

func _build_bar() -> void:
	bar = Node3D.new()
	bar.position = Vector3(0, 1.8, 0)
	bar.rotation.x = -0.7
	add_child(bar)
	main.add_mesh(bar, main.box(1.04, 0.16, 0.05), Color(0.1, 0.1, 0.1))
	bar_fill = main.add_mesh(bar, main.box(1.0, 0.12, 0.07), Color(0.4, 0.9, 0.35))
	bar.visible = false


func _set_bar(frac: float) -> void:
	bar.visible = frac > 0.0 and frac < 1.0
	var f := clampf(frac, 0.01, 1.0)
	bar_fill.scale.x = f
	bar_fill.position.x = -0.5 + 0.5 * f


func _build_plot() -> void:
	main.add_mesh(self, main.cyl(0.55, 0.6, 0.08), Color(0.3, 0.2, 0.12), Vector3(0, 0.02, 0))
	plant_root = Node3D.new()
	add_child(plant_root)
	for k in 4:
		var g := Node3D.new()
		g.rotation.y = k * PI / 2.0 + 0.4
		plant_root.add_child(g)
		main.add_mesh(g, main.cyl(0.03, 0.05, 1.0), Color(0.42, 0.55, 0.3), Vector3(0.12, 0.5, 0), Vector3(0, 0, -0.25))
		main.add_mesh(g, main.sphere(0.38), Color(0.2, 0.55, 0.25), Vector3(0.34, 1.0, 0), Vector3(0, 0, 0.55), Vector3(1.0, 0.12, 0.85))
		stalks.append(g)
	weed_node = Node3D.new()
	add_child(weed_node)
	for k in 6:
		var a := k * TAU / 6.0
		main.add_mesh(weed_node, main.box(0.05, 0.6, 0.05), Color(0.7, 0.8, 0.2),
			Vector3(cos(a) * 0.45, 0.3, sin(a) * 0.45), Vector3(sin(a) * 0.4, 0, cos(a) * 0.4))
	ring = main.add_mesh(self, main.torus(0.6, 0.72), Color(1, 0.9, 0.25), Vector3(0, 0.3, 0), Vector3.ZERO, Vector3(1, 0.3, 1))


func _build_huli_pile() -> void:
	main.add_mesh(self, main.cyl(0.6, 0.65, 0.12), Color(0.45, 0.3, 0.18), Vector3(0, 0.06, 0))
	for k in 8:
		var n := Node3D.new()
		n.position = Vector3((k % 4) * 0.25 - 0.37, 0.12, (k / 4) * 0.3 - 0.15)
		add_child(n)
		main.add_mesh(n, main.sphere(0.08), Color(0.5, 0.36, 0.4), Vector3(0, 0.05, 0))
		main.add_mesh(n, main.cyl(0.025, 0.04, 0.4), Color(0.45, 0.6, 0.3), Vector3(0, 0.25, 0))
		pile_nodes.append(n)
	main.label3d(self, "Huli\n(kalo tops for planting)", Vector3(0, 1.4, 0), 36)


func _build_gate() -> void:
	var frame := Vector3(0.1, 0, -0.9)
	main.add_mesh(self, main.box(0.18, 1.4, 0.18), Color(0.4, 0.27, 0.15), frame + Vector3(0, 0.3, -0.55))
	main.add_mesh(self, main.box(0.18, 1.4, 0.18), Color(0.4, 0.27, 0.15), frame + Vector3(0, 0.3, 0.55))
	main.add_mesh(self, main.box(0.18, 0.15, 1.3), Color(0.4, 0.27, 0.15), frame + Vector3(0, 1.0, 0))
	gate_board = main.add_mesh(self, main.box(0.12, 0.7, 1.0), Color(0.55, 0.38, 0.2), frame + Vector3(0, 0.0, 0))
	for k in 5:
		main.add_mesh(self, main.sphere(0.25), Color(0.45, 0.45, 0.43), Vector3(-1.2 - k * 0.1, -0.5, -0.9 - k * 0.45 + 0.9), Vector3.ZERO, Vector3(1, 0.7, 1))
	main.label3d(self, "Poʻo wai\n(stream diversion)", Vector3(0, 2.1, -0.6), 40, Color(0.75, 0.9, 1))
	gate_label = main.label3d(self, "", Vector3(0, 1.45, -0.6), 34, Color(1, 1, 0.7))


func _build_clog() -> void:
	for k in 6:
		main.add_mesh(self, main.box(0.9, 0.1, 0.1), Color(0.35, 0.24, 0.14),
			Vector3(randf_range(-0.2, 0.2), 0.1 + k * 0.06, randf_range(-0.2, 0.2)), Vector3(0, randf() * PI, 0.2))
	for k in 5:
		main.add_mesh(self, main.sphere(0.18), Color(0.55, 0.5, 0.2),
			Vector3(randf_range(-0.35, 0.35), 0.3, randf_range(-0.3, 0.3)), Vector3.ZERO, Vector3(1, 0.3, 1))
	main.label3d(self, "ʻŌpala!", Vector3(0, 1.2, 0), 40, Color(1, 0.8, 0.5))


func _build_breach() -> void:
	for k in 7:
		main.add_mesh(self, main.sphere(0.22), Color(0.4, 0.28, 0.16),
			Vector3(randf_range(-0.7, 0.7), 0.1, randf_range(-0.5, 0.5)), Vector3.ZERO, Vector3(1, 0.6, 1))
	for k in 4:
		main.add_mesh(self, main.box(0.3, 0.06, 0.8), Color(0.4, 0.7, 0.95, 0.8), Vector3(k * 0.3 - 0.45, 0.15, 0.2), Vector3(-0.3, 0, 0))
	main.label3d(self, "Broken kuāuna!", Vector3(0, 1.4, 0), 40, Color(1, 0.6, 0.5))


func _build_imu() -> void:
	main.add_mesh(self, main.sphere(1.0), Color(0.35, 0.25, 0.17), Vector3(0, 0.0, 0), Vector3.ZERO, Vector3(1.0, 0.32, 1.0))
	for k in 10:
		var a := k * TAU / 10.0
		main.add_mesh(self, main.sphere(0.2), Color(0.38, 0.38, 0.36), Vector3(cos(a) * 1.05, 0.08, sin(a) * 1.05))
	for k in 3:
		main.add_mesh(self, main.sphere(0.35), Color(0.3, 0.55, 0.25), Vector3(k * 0.5 - 0.5, 0.25, -0.1), Vector3.ZERO, Vector3(1, 0.25, 1.4))
		var s = main.add_mesh(self, main.sphere(0.18), Color(1, 1, 1, 0.55), Vector3(k * 0.45 - 0.45, 0.6, 0))
		s.visible = false
		steam.append(s)
		var b := Node3D.new()
		b.position = Vector3(k * 0.62 - 0.62, 1.25, 0.3)
		b.rotation.x = -0.7
		add_child(b)
		main.add_mesh(b, main.box(0.5, 0.12, 0.05), Color(0.1, 0.1, 0.1))
		var f = main.add_mesh(b, main.box(0.48, 0.09, 0.07), Color(1, 0.6, 0.2))
		b.visible = false
		imu_bars.append([b, f])
	main.label3d(self, "Imu\n(earth oven)", Vector3(0, 2.2, 0), 40)


func _build_papa() -> void:
	main.add_mesh(self, main.box(1.5, 0.14, 0.7), Color(0.55, 0.36, 0.2), Vector3(0, 0.07, 0))
	pounder = Node3D.new()
	pounder.position = Vector3(0.45, 0.35, 0.1)
	add_child(pounder)
	main.add_mesh(pounder, main.cyl(0.08, 0.2, 0.4), Color(0.4, 0.4, 0.42), Vector3.ZERO)
	main.add_mesh(pounder, main.sphere(0.1), Color(0.4, 0.4, 0.42), Vector3(0, 0.22, 0))
	main.label3d(self, "Papa kuʻi ʻai\n(pounding board)", Vector3(0, 1.4, 0), 36)


func _build_wai_stand() -> void:
	main.add_mesh(self, main.box(1.0, 0.5, 0.6), Color(0.5, 0.33, 0.2), Vector3(0, 0.25, 0))
	main.add_mesh(self, main.sphere(0.32), Color(0.82, 0.7, 0.45), Vector3(-0.22, 0.75, 0))
	main.add_mesh(self, main.sphere(0.28), Color(0.82, 0.7, 0.45), Vector3(0.25, 0.72, 0))
	for k in 6:
		var d = main.add_mesh(self, main.sphere(0.07), Color(0.3, 0.65, 1.0), Vector3(k * 0.17 - 0.42, 1.15, 0.0))
		wai_dots.append(d)
	main.label3d(self, "Wai (water)\nfor pounding & poi", Vector3(0, 1.75, 0), 34, Color(0.75, 0.9, 1))


func _build_umeke() -> void:
	main.add_mesh(self, main.box(1.2, 0.5, 0.8), Color(0.5, 0.33, 0.2), Vector3(0, 0.25, 0))
	for k in 3:
		main.add_mesh(self, main.cyl(0.25, 0.17, 0.16), Color(0.45, 0.28, 0.15), Vector3(0.38, 0.58 + k * 0.1, -0.2))
	main.label3d(self, "ʻUmeke\n(poi bowls)", Vector3(0, 1.5, 0), 36)


func _build_ki() -> void:
	for k in 4:
		var p := Vector3(cos(k * 1.7) * 0.4, 0, sin(k * 1.7) * 0.4)
		var h := 1.2 + k * 0.2
		main.add_mesh(self, main.cyl(0.04, 0.06, h), Color(0.4, 0.35, 0.25), p + Vector3(0, h / 2, 0))
		for j in 5:
			var a := j * TAU / 5.0
			var leaf_col := Color(0.2, 0.55, 0.25) if (j + k) % 3 else Color(0.55, 0.15, 0.2)
			main.add_mesh(self, main.sphere(0.3), leaf_col, p + Vector3(cos(a) * 0.25, h, sin(a) * 0.25), Vector3(sin(a) * 0.6, a, cos(a) * 0.6), Vector3(0.3, 0.08, 1.0))
	main.label3d(self, "Kī (ti plant)\nwrap paʻiʻai in lāʻī", Vector3(0, 2.4, 0), 36)


func _build_aha() -> void:
	main.add_mesh(self, main.box(4.0, 0.05, 1.8), Color(0.85, 0.75, 0.5), Vector3(0, 0.03, 0))
	for k in 3:
		var c: Color = [Color(0.9, 0.35, 0.3), Color(0.3, 0.7, 0.5), Color(0.95, 0.75, 0.3)][k]
		var p := Vector3(k * 1.3 - 1.3, 0, 1.4)
		main.add_mesh(self, main.capsule(0.3, 0.8), c, p + Vector3(0, 0.4, 0))
		main.add_mesh(self, main.sphere(0.23), Color(0.55, 0.38, 0.27), p + Vector3(0, 0.95, 0))
	main.label3d(self, "ʻAha ʻāina\n(serve food here)", Vector3(0, 2.2, 0.6), 42, Color(1, 0.9, 0.6))


func _build_tutu() -> void:
	main.add_mesh(self, main.capsule(0.36, 1.1), Color(0.55, 0.35, 0.6), Vector3(0, 0.55, 0))
	main.add_mesh(self, main.sphere(0.27), Color(0.55, 0.38, 0.27), Vector3(0, 1.3, 0))
	main.add_mesh(self, main.sphere(0.29), Color(0.92, 0.92, 0.92), Vector3(0, 1.4, -0.07), Vector3.ZERO, Vector3(1, 0.75, 1))
	main.add_mesh(self, main.torus(0.22, 0.34), Color(0.95, 0.95, 0.9), Vector3(0, 1.06, 0))
	main.label3d(self, "Tūtū", Vector3(0, 2.0, 0), 42, Color(1, 0.85, 1))


# ---------------------------------------------------------------- per-frame

func tick(delta: float) -> void:
	sway += delta
	match kind:
		"plot":
			if planted and growth < 3.0 and not weed:
				growth = minf(3.0, growth + main.growth_rate(loi) * delta)
			if planted and not weed and randf() < delta / 100.0:
				weed = true
				main.tip("weeds")
			plant_root.visible = planted
			var s := 0.3 + 0.24 * growth
			plant_root.scale = Vector3(s, s, s)
			plant_root.rotation.z = sin(sway * 1.3) * 0.04
			for k in stalks.size():
				stalks[k].visible = k < 1 + int(growth)
			weed_node.visible = weed
			ring.visible = planted and growth >= 3.0
			if ring.visible:
				var p := 1.0 + sin(sway * 5.0) * 0.08
				ring.scale = Vector3(p, 0.3, p)
		"imu":
			for k in 3:
				var on := k < imu_slots.size()
				steam[k].visible = on and imu_slots[k]["t"] < COOK_TIME
				if steam[k].visible:
					steam[k].position.y = 0.6 + fmod(sway * 0.8 + k * 0.33, 1.0)
				imu_bars[k][0].visible = steam[k].visible
				if on:
					var sl = imu_slots[k]
					sl["t"] += delta
					var f := clampf(sl["t"] / COOK_TIME, 0.01, 1.0)
					imu_bars[k][1].scale.x = f
					imu_bars[k][1].position.x = -0.24 + 0.24 * f
					if sl["t"] >= COOK_TIME and COOKED.has(sl["kind"]):
						sl["kind"] = COOKED[sl["kind"]]
						sl["node"].set_kind(sl["kind"])
		"huli_pile":
			for k in pile_nodes.size():
				pile_nodes[k].visible = k < count
		"gate":
			var target_y := -0.05
			if main.gate_open:
				target_y = 0.75 if main.gate_all else 0.4
			gate_board.position.y = lerpf(gate_board.position.y, target_y, delta * 6.0)
			gate_label.text = main.gate_text()
		"wai_stand":
			for k in wai_dots.size():
				wai_dots[k].visible = k < main.wai
		"papa":
			pound_anim = maxf(0.0, pound_anim - delta)
			pounder.position.y = 0.35 + (absf(sin(sway * 14.0)) * 0.35 if pound_anim > 0.0 else 0.0)
	if work_tag != "":
		_set_bar(progress / float(WORK_TIME.get(work_tag, 1.0)))
	else:
		bar.visible = false


func _imu_ready() -> int:
	for k in imu_slots.size():
		if not COOKED.has(imu_slots[k]["kind"]):
			return k
	return -1


func _layout_imu() -> void:
	for k in imu_slots.size():
		imu_slots[k]["node"].position = Vector3(k * 0.62 - 0.62, 0.32, 0.25)


# ---------------------------------------------------------------- interaction

func grab_prompt(p) -> String:
	var h: String = p.held_kind()
	match kind:
		"plot":
			if h == "huli" and not planted:
				return "Plant huli"
		"huli_pile":
			if h == "" and count > 0:
				return "Take huli"
			if h == "huli":
				return "Put huli back"
		"gate":
			return "Close poʻo wai" if main.gate_open else "Open poʻo wai"
		"counter":
			if h != "" and slot_item == null:
				return "Put down"
			if h == "" and slot_item != null:
				return "Pick up " + main.item_name(slot_item.kind)
		"papa":
			if h == "kalo_cooked" and slot_item == null:
				return "Put kalo on papa"
			if h == "" and slot_item != null:
				return "Pick up " + main.item_name(slot_item.kind)
		"umeke":
			if h == "paiai" and slot_item == null:
				return "Put paʻiʻai in ʻumeke"
			if h == "" and slot_item != null:
				return "Pick up " + main.item_name(slot_item.kind)
		"imu":
			if (h == "kalo" or h == "lau") and imu_slots.size() < 3:
				return "Put in imu"
			if h == "" and _imu_ready() >= 0:
				return "Take " + main.item_name(imu_slots[_imu_ready()]["kind"])
		"wai_stand":
			if h == "ipu_full" and main.wai < 6:
				return "Pour wai"
		"kahawai":
			if h == "ipu_empty":
				return "Fill ipu"
		"ki":
			if h == "paiai":
				return "Wrap in lāʻī"
		"aha":
			if main.ORDER_INFO.has(h):
				return "Serve " + main.item_name(h)
		"tutu":
			if h == "":
				return "Talk to Tūtū"
	return ""


func grab(p) -> bool:
	var h: String = p.held_kind()
	match kind:
		"plot":
			if h == "huli" and not planted:
				p.consume()
				planted = true
				growth = 0.0
				main.tip("plant")
				main.float_text("Planted!", global_position)
				return true
		"huli_pile":
			if h == "":
				if count > 0:
					count -= 1
					p.give("huli")
				else:
					main.tip("nohuli", true)
					main.float_text("No huli left!", global_position)
				return true
			if h == "huli":
				count += 1
				p.consume()
				return true
		"gate":
			main.toggle_gate()
			return true
		"counter", "papa", "umeke":
			if h == "" and slot_item != null:
				var it = slot_item
				slot_item = null
				work_tag = ""
				progress = 0.0
				p.attach(it)
				return true
			if h != "" and slot_item == null and _accepts(h):
				slot_item = p.release_to(self, slot_pos)
				return true
			if kind == "papa" and h == "kalo":
				main.tip("raw", true)
				main.float_text("Cook it first!", global_position)
				return true
			if kind == "umeke" and h == "kalo_cooked":
				main.float_text("Pound it first!", global_position)
				return true
		"imu":
			if (h == "kalo" or h == "lau") and imu_slots.size() < 3:
				var it = p.release_to(self, Vector3.ZERO)
				imu_slots.append({"kind": it.kind, "t": 0.0, "node": it})
				_layout_imu()
				main.tip("imu")
				return true
			if h == "" and _imu_ready() >= 0:
				var sl = imu_slots[_imu_ready()]
				imu_slots.erase(sl)
				p.attach(sl["node"])
				_layout_imu()
				return true
		"wai_stand":
			if h == "ipu_full" and main.wai < 6:
				main.wai = mini(6, main.wai + 3)
				p.held.set_kind("ipu_empty")
				main.tip("wai")
				main.float_text("+3 wai", global_position)
				return true
			if h == "ipu_empty":
				main.tip("fill_ipu", true)
				return true
		"kahawai":
			if h == "ipu_empty":
				if main.stream_level(position.z) > 0.25:
					p.held.set_kind("ipu_full")
					main.float_text("Ipu filled!", global_position)
				else:
					main.tip("low", true)
					main.float_text("Too little water!", global_position)
				return true
		"ki":
			if h == "paiai":
				p.held.set_kind("paiai_wrapped")
				main.tip("wrap")
				return true
		"aha":
			if main.ORDER_INFO.has(h):
				if main.serve(h):
					p.consume()
				else:
					main.float_text("Nobody ordered that yet", global_position)
				return true
		"tutu":
			if h == "":
				main.tutu_talk()
				return true
	return false


func _accepts(h: String) -> bool:
	match kind:
		"counter":
			return true
		"papa":
			return h == "kalo_cooked"
		"umeke":
			return h == "paiai"
	return false


func work_prompt(p) -> String:
	if p.held != null and kind != "gate":
		return ""
	match kind:
		"plot":
			if weed:
				return "Pull mauʻu (weeds)"
			if planted and growth >= 3.0:
				return "Harvest kalo"
			if planted and growth >= 2.0:
				return "Pick lau (leaves)"
		"papa":
			if slot_item != null and slot_item.kind == "kalo_cooked" and main.wai >= 1:
				return "Pound kalo"
		"umeke":
			if slot_item != null and slot_item.kind == "paiai" and main.wai >= 1:
				return "Mix with wai"
		"clog":
			return "Clear ʻōpala"
		"breach":
			return "Rebuild kuāuna"
		"gate":
			if main.gate_open:
				return "Share the water" if main.gate_all else "Take ALL the water"
	return ""


func hint(p) -> String:
	match kind:
		"plot":
			if weed:
				return "Weeds are stopping the kalo from growing!"
			if not planted:
				return "Empty — plant a huli" if p.held_kind() != "huli" else ""
			if growth < 3.0 and not main.loi_flow[loi]:
				return "No flowing water — not growing!"
			if growth < 2.0:
				return "Growing… %d%%" % int(growth / 3.0 * 100.0)
			if growth < 3.0:
				return "Growing… %d%% (leaves ready)" % int(growth / 3.0 * 100.0)
		"imu":
			var cooking := 0
			for sl in imu_slots:
				if COOKED.has(sl["kind"]):
					cooking += 1
			if cooking > 0:
				return "Cooking %d…" % cooking
			if imu_slots.is_empty():
				return "Cook raw kalo or lau here"
		"papa":
			if slot_item != null and slot_item.kind == "kalo_cooked" and main.wai < 1:
				return "Needs wai! Fill an ipu at the kahawai"
			if slot_item == null:
				return "Bring cooked kalo"
		"umeke":
			if slot_item != null and slot_item.kind == "paiai" and main.wai < 1:
				return "Needs wai! Fill an ipu at the kahawai"
			if slot_item == null:
				return "Bring paʻiʻai to make poi"
		"wai_stand":
			return "Wai: %d / 6" % main.wai
		"huli_pile":
			return "%d huli left" % count
		"aha":
			if not main.ORDER_INFO.has(p.held_kind()):
				return "Bring the food the ʻohana ordered"
		"kahawai":
			if p.held_kind() != "ipu_empty":
				return "Bring an empty ipu"
		"ki":
			if p.held_kind() != "paiai":
				return "Bring paʻiʻai to wrap"
		"gate":
			return main.gate_text()
	return ""


func work(delta: float, p) -> bool:
	var tag := work_prompt(p)
	if tag == "":
		return false
	if tag != work_tag:
		work_tag = tag
		progress = 0.0
	progress += delta
	if kind == "papa":
		pound_anim = 0.15
	if progress >= float(WORK_TIME.get(tag, 1.0)):
		progress = 0.0
		work_tag = ""
		_finish(tag, p)
		return true
	return false


func _finish(tag: String, p) -> void:
	match kind:
		"plot":
			if tag == "Pull mauʻu (weeds)":
				weed = false
				main.health = minf(100.0, main.health + 1.5)
				main.float_text("Mauʻu pulled!", global_position)
			elif tag == "Harvest kalo":
				planted = false
				growth = 0.0
				p.give("kalo")
				main.spawn_item("huli", global_position + Vector3(0.85, 0, 0.35))
				main.tip("harvest")
			elif tag == "Pick lau (leaves)":
				p.give("lau")
				growth = maxf(1.5, growth - 0.8)
				main.tip("lau")
		"papa":
			main.wai -= 1
			slot_item.set_kind("paiai")
			main.tip("pound")
			main.float_text("Paʻiʻai!", global_position)
		"umeke":
			main.wai -= 1
			slot_item.set_kind("poi")
			main.tip("poi")
			main.float_text("Poi!", global_position)
		"clog":
			main.remove_clog(self)
		"breach":
			main.repair_breach()
		"gate":
			main.set_gate_all(not main.gate_all)
