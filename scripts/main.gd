extends Node3D
## Loʻi Kalo — playable prototype level.
## Everything (terrain, water, stations, HUD) is built in code from placeholder
## shapes so the level layout and rules are easy to tweak in one place.

const PlayerScript := preload("res://scripts/player.gd")
const StationScript := preload("res://scripts/station.gd")
const ItemScript := preload("res://scripts/item.gd")

const LEVEL_TIME := 240.0
const ORDER_TIME := 110.0
const STREAM_X0 := -17.0
const STREAM_X1 := -14.0
const AUWAI_CLOG_X := [-12.0, -9.5, -7.5]
const STAR_SCORES := [120, 220, 320]

static var quick_restart := false

var LOI: Array = [Rect2(-10, -10, 12, 5), Rect2(-10, -3, 12, 5), Rect2(-10, 4, 12, 5)]
var BOUNDS := Rect2(-13.4, -13.3, 32.4, 28.5)
var PLAYER_COLORS := [Color(0.95, 0.5, 0.2), Color(0.25, 0.6, 0.95)]

var NAMES := {
	"huli": "Huli (kalo top)",
	"kalo": "Kalo (raw)",
	"lau": "Lau kalo (leaves)",
	"kalo_cooked": "Kalo (cooked)",
	"luau": "Lūʻau",
	"paiai": "Paʻiʻai",
	"paiai_wrapped": "Paʻiʻai in lāʻī",
	"poi": "Poi",
	"ipu_empty": "Ipu (empty)",
	"ipu_full": "Ipu (full of wai)",
}

var ORDER_INFO := {
	"poi": {"name": "Poi", "points": 35, "color": Color(0.45, 0.35, 0.55),
		"steps": "kalo → imu → papa (pound)\n→ ʻumeke + wai"},
	"luau": {"name": "Lūʻau", "points": 25, "color": Color(0.2, 0.42, 0.22),
		"steps": "lau kalo (leaves) → imu"},
	"paiai_wrapped": {"name": "Paʻiʻai in lāʻī", "points": 40, "color": Color(0.15, 0.42, 0.4),
		"steps": "kalo → imu → papa (pound)\n→ wrap at the kī"},
}

var TIPS := {
	"start": "Aloha mai! Welcome to our loʻi kalo (kalo terraces). The ʻohana are hungry — let's grow, cook and pound kalo together. [i]ʻAʻohe hana nui ke alu ʻia[/i]: no task is too big when we work together.",
	"plant": "You planted a [b]huli[/b]! A huli is the top of a harvested kalo. Replanting it keeps the same kalo living on, season after season.",
	"harvest": "See the [b]huli[/b] left beside the plant? Every kalo you pull gives you the next huli to plant. Put it back in an empty spot!",
	"nohuli": "No huli left in the pile! Harvest a grown kalo — its top becomes your next huli.",
	"raw": "Not yet! Raw kalo makes your mouth itchy ([b]maneʻo[/b]). Cook it in the [b]imu[/b] first.",
	"imu": "The [b]imu[/b] is an earth oven. Hot stones cook the food slowly under a cover of leaves and earth.",
	"pound": "Pounding cooked kalo on the [b]papa kuʻi ʻai[/b] with a [b]pōhaku kuʻi ʻai[/b] (stone pounder) makes [b]paʻiʻai[/b]. Pound together and it goes faster!",
	"poi": "Mixing paʻiʻai with [b]wai[/b] (fresh water) makes [b]poi[/b]!",
	"wrap": "Paʻiʻai wrapped in [b]lāʻī[/b] (ti leaves) keeps well and can travel with you.",
	"lau": "Young kalo leaves ([b]lau[/b]) are cooked to make [b]lūʻau[/b]. Like the corm, the leaves must be cooked well — raw, they are itchy too!",
	"weeds": "[b]Mauʻu[/b] (weeds) are crowding a kalo! Hold work on it to pull them so the kalo can keep growing.",
	"clog": "[b]ʻŌpala[/b] (debris) is blocking the [b]ʻauwai[/b] (irrigation ditch)! No water reaches the loʻi until someone clears it.",
	"stagnant": "The water stopped flowing! Kalo grows best in cool, flowing water. Still, warm water can make kalo rot.",
	"all": "Taking ALL the water dries up the [b]kahawai[/b] below the poʻo wai. The [b]ʻoʻopu[/b] (native stream fish) and the families downstream need that water too!",
	"share": "Sharing the water! It flows from the kahawai, through the ʻauwai and every loʻi, and back into the kahawai.",
	"closed": "The [b]poʻo wai[/b] is closed — no water is going into the ʻauwai.",
	"flood_warn": "Heavy rain [b]mauka[/b] (up in the mountains)! The kahawai is rising — close the [b]poʻo wai[/b] before the flood reaches the loʻi!",
	"flood_ok": "Well done! Closing the poʻo wai protected the [b]kuāuna[/b] (loʻi banks) from the flood.",
	"breach": "The flood broke a [b]kuāuna[/b] (bank)! Water is draining out of the loʻi. Hold work at the break to rebuild it.",
	"flood_end": "The flood has passed. Open the poʻo wai again so cool water can flow into the loʻi.",
	"serve": "[b]ʻOno![/b] The ʻohana are fed. Keep the orders coming!",
	"fill_ipu": "This ipu is empty. Fill it with wai at the [b]kahawai[/b] (stream), then pour it here.",
	"wai": "Wai poured! You need wai to pound kalo and to make poi.",
	"low": "The kahawai is too low here to fill the ipu. Is someone taking all the water at the poʻo wai?",
	"order_luau": "New order: [b]lūʻau[/b]! Pick young leaves (lau) from a growing kalo and cook them in the imu.",
	"order_paiai_wrapped": "New order: [b]paʻiʻai in lāʻī[/b]! Pound cooked kalo, then wrap it at the kī (ti) plants.",
	"missed": "An order went unfilled. Working together — one person in the loʻi, one at the imu — helps!",
}

var TUTU_TALK := [
	"A [b]loʻi[/b] is a flooded terrace for growing kalo. An [b]ʻauwai[/b] carries water from the kahawai (stream) into the loʻi.",
	"Water flows from one loʻi down into the next, and then back to the kahawai. We share it with everyone downstream.",
	"In our moʻolelo, the first kalo, [b]Hāloanakalaukapalili[/b], is the elder sibling of the Hawaiian people. We care for kalo, and kalo cares for us.",
	"An [b]ahupuaʻa[/b] reaches from [b]mauka[/b] (the mountains) to [b]makai[/b] (the sea). What we do with the water up here affects everyone below.",
	"Our kūpuna (ancestors) grew hundreds of different kinds of kalo, each with its own name.",
	"People still farm loʻi today, and communities all over Hawaiʻi are bringing old loʻi back to life.",
	"[i]ʻAʻohe hana nui ke alu ʻia[/i] — no task is too big when we work together.",
]

var GLOSSARY := [
	["ʻāina", "land, earth; that which feeds"],
	["ahupuaʻa", "land division running from the mountains to the sea"],
	["ʻaha ʻāina", "feast, gathering for a meal"],
	["ʻauwai", "irrigation ditch"],
	["huli", "top of the kalo, cut and replanted"],
	["imu", "underground earth oven"],
	["ipu", "gourd, used as a water container"],
	["kahawai", "stream"],
	["kalo", "taro"],
	["kī / lāʻī", "ti plant / ti leaf"],
	["kuāuna", "bank of a loʻi"],
	["lau", "leaf"],
	["loʻi", "irrigated terrace for growing kalo"],
	["lūʻau", "cooked young kalo leaves"],
	["mahiʻai", "farmer"],
	["mauka / makai", "toward the mountains / toward the sea"],
	["maneʻo", "itchy"],
	["mauʻu", "grass, weeds"],
	["ʻōpala", "rubbish, debris"],
	["ʻoʻopu", "native freshwater stream fish (gobies)"],
	["paʻiʻai", "pounded cooked kalo, before water is added"],
	["papa kuʻi ʻai", "board for pounding kalo"],
	["pōhaku kuʻi ʻai", "stone pounder"],
	["poi", "paʻiʻai mixed with water"],
	["poʻo wai", "head of the ʻauwai, where water is diverted from the stream"],
	["ʻumeke", "bowl"],
	["wai", "fresh water"],
]

# ---- state
var state := "title"
var paused := false
var t := 0.0
var score := 0
var served := 0
var missed := 0
var health := 80.0
var wai := 2
var gate_open := true
var gate_all := false
var breached := false
var flood_state := ""
var flood_timer := 0.0
var flood_times: Array = [95.0, 185.0]
var next_clog := 35.0
var next_order := 0.5
var unlocked: Array = ["poi"]
var forced_next := ""
var loi_flow: Array = [true, true, true]
var loi_water: Array = [1.0, 1.0, 1.0]
var reach_level := 0.6
var stagnant_time := 0.0
var players: Array = []
var stations: Array = []
var items: Array = []
var orders: Array = []
var clogs: Array = []
var breach_station = null
var obstacles: Array = []
var tip_queue: Array = []
var tip_seen := {}
var tip_time := 0.0
var talk_i := 0
var floaters: Array = []
var mat_cache := {}
var anim_t := 0.0

# ---- scene refs
var cam: Camera3D
var cam_focus := Vector3(0, 1, 0)
var cam_zoom := 1.6
var sun: DirectionalLight3D
var loi_water_nodes: Array = []
var stream_segs: Array = []
var auwai_segs: Array = []
var outflow_segs: Array = []
var oopu: Array = []
var gate_station
var aha_station
var rain: Array = []

# ---- UI refs
var ui: Control
var orders_box: HBoxContainer
var time_label: Label
var score_label: Label
var health_bar: ProgressBar
var health_fill: StyleBoxFlat
var health_label: Label
var gate_label: Label
var wai_label: Label
var p2_hint: Label
var tip_panel: PanelContainer
var tip_text: RichTextLabel
var banner: Label
var title_overlay: Control
var end_overlay: Control
var end_text: RichTextLabel
var end_stars: HBoxContainer
var glossary_overlay: Control
var pause_overlay: Control


var game_font: Font
var ui_theme: Theme


func _setup_font() -> void:
	# Montserrat (SIL Open Font License) — includes the ʻokina and kahakō vowels,
	# which Godot's built-in fallback font does not render in web builds.
	game_font = load("res://fonts/Montserrat-Medium.ttf")
	ThemeDB.fallback_font = game_font
	var bold := FontVariation.new()
	bold.base_font = game_font
	bold.variation_embolden = 0.9
	var ital := FontVariation.new()
	ital.base_font = game_font
	ital.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)
	ui_theme = Theme.new()
	ui_theme.default_font = game_font
	ui_theme.set_font("bold_font", "RichTextLabel", bold)
	ui_theme.set_font("italics_font", "RichTextLabel", ital)
	ui_theme.set_font("bold_italics_font", "RichTextLabel", bold)


func _ready() -> void:
	randomize()
	_setup_font()
	_setup_inputs()
	_build_environment()
	_build_terrain()
	_build_water()
	_build_decor()
	_build_stations()
	_build_ui()
	_spawn_player(0)
	if quick_restart:
		_start()


# =====================================================================
# Input
# =====================================================================

func _act(name: String, keys: Array, dev := -1, axis := -1, axis_val := 0.0, buttons: Array = []) -> void:
	if not InputMap.has_action(name):
		InputMap.add_action(name, 0.3)
	for k in keys:
		var e := InputEventKey.new()
		e.physical_keycode = k
		InputMap.action_add_event(name, e)
	if axis >= 0:
		var m := InputEventJoypadMotion.new()
		m.device = dev
		m.axis = axis
		m.axis_value = axis_val
		InputMap.action_add_event(name, m)
	for b in buttons:
		var jb := InputEventJoypadButton.new()
		jb.device = dev
		jb.button_index = b
		InputMap.action_add_event(name, jb)


func _setup_inputs() -> void:
	# Player 1: WASD/arrows, E grab, Q/F work, Space dash. Gamepad 1.
	_act("p0_up", [KEY_W, KEY_UP], 0, JOY_AXIS_LEFT_Y, -1.0, [JOY_BUTTON_DPAD_UP])
	_act("p0_down", [KEY_S, KEY_DOWN], 0, JOY_AXIS_LEFT_Y, 1.0, [JOY_BUTTON_DPAD_DOWN])
	_act("p0_left", [KEY_A, KEY_LEFT], 0, JOY_AXIS_LEFT_X, -1.0, [JOY_BUTTON_DPAD_LEFT])
	_act("p0_right", [KEY_D, KEY_RIGHT], 0, JOY_AXIS_LEFT_X, 1.0, [JOY_BUTTON_DPAD_RIGHT])
	_act("p0_grab", [KEY_E], 0, -1, 0.0, [JOY_BUTTON_A])
	_act("p0_work", [KEY_Q, KEY_F], 0, -1, 0.0, [JOY_BUTTON_X])
	_act("p0_dash", [KEY_SPACE], 0, -1, 0.0, [JOY_BUTTON_B])
	# Player 2: IJKL, O grab, U/H work, Enter/; dash. Gamepad 2.
	_act("p1_up", [KEY_I], 1, JOY_AXIS_LEFT_Y, -1.0, [JOY_BUTTON_DPAD_UP])
	_act("p1_down", [KEY_K], 1, JOY_AXIS_LEFT_Y, 1.0, [JOY_BUTTON_DPAD_DOWN])
	_act("p1_left", [KEY_J], 1, JOY_AXIS_LEFT_X, -1.0, [JOY_BUTTON_DPAD_LEFT])
	_act("p1_right", [KEY_L], 1, JOY_AXIS_LEFT_X, 1.0, [JOY_BUTTON_DPAD_RIGHT])
	_act("p1_grab", [KEY_O], 1, -1, 0.0, [JOY_BUTTON_A])
	_act("p1_work", [KEY_U, KEY_H], 1, -1, 0.0, [JOY_BUTTON_X])
	_act("p1_dash", [KEY_ENTER, KEY_SEMICOLON], 1, -1, 0.0, [JOY_BUTTON_B])
	# Menus
	_act("start", [KEY_ENTER, KEY_SPACE, KEY_E], -1, -1, 0.0, [JOY_BUTTON_A, JOY_BUTTON_START])
	_act("restart", [KEY_R], -1, -1, 0.0, [JOY_BUTTON_START])
	_act("glossary", [KEY_G, KEY_TAB], -1, -1, 0.0, [JOY_BUTTON_BACK])
	_act("pause", [KEY_ESCAPE, KEY_P], -1, -1, 0.0, [])


# =====================================================================
# Mesh / material helpers (used by every script)
# =====================================================================

func mat(c: Color) -> StandardMaterial3D:
	if mat_cache.has(c):
		return mat_cache[c]
	var m := _new_mat(c)
	mat_cache[c] = m
	return m


func _new_mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.9
	if c.a < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m


func add_mesh(parent: Node, mesh: Mesh, c: Color, pos := Vector3.ZERO, rot := Vector3.ZERO, scl := Vector3.ONE, unique := false) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = _new_mat(c) if unique else mat(c)
	mi.position = pos
	mi.rotation = rot
	mi.scale = scl
	parent.add_child(mi)
	return mi


func box(x: float, y: float, z: float) -> BoxMesh:
	var m := BoxMesh.new()
	m.size = Vector3(x, y, z)
	return m


func sphere(r: float) -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = 14
	m.rings = 7
	return m


func cyl(top: float, bottom: float, h: float) -> CylinderMesh:
	var m := CylinderMesh.new()
	m.top_radius = top
	m.bottom_radius = bottom
	m.height = h
	m.radial_segments = 12
	m.rings = 1
	return m


func capsule(r: float, h: float) -> CapsuleMesh:
	var m := CapsuleMesh.new()
	m.radius = r
	m.height = h
	m.radial_segments = 12
	m.rings = 4
	return m


func torus(inner: float, outer: float) -> TorusMesh:
	var m := TorusMesh.new()
	m.inner_radius = inner
	m.outer_radius = outer
	m.rings = 18
	m.ring_segments = 8
	return m


func label3d(parent: Node, text: String, pos: Vector3, size := 48, col := Color.WHITE, on_top := false) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font = game_font
	l.font_size = size
	l.pixel_size = 0.0075
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.modulate = col
	l.outline_size = 12
	l.outline_modulate = Color(0, 0, 0, 0.8)
	l.no_depth_test = on_top
	if on_top:
		l.render_priority = 10
		l.outline_render_priority = 9
	l.position = pos
	parent.add_child(l)
	return l


func item_name(k: String) -> String:
	return NAMES.get(k, k)


# =====================================================================
# World: terrain shape
# =====================================================================

func base_h(x: float, z: float) -> float:
	var h := 3.0 * clampf((16.0 - z) / 32.0, 0.0, 1.0)
	if z < -13.5:
		h += (-13.5 - z) * 1.1
	if x > 19.5:
		h += (x - 19.5) * 0.9
	if x < STREAM_X0:
		h += (STREAM_X0 - x) * 0.8 + 0.4
	if z > 16.0:
		h -= (z - 16.0) * 0.6
	return h


func loi_floor(i: int) -> float:
	var r: Rect2 = LOI[i]
	return 3.0 * clampf((16.0 - r.end.y) / 32.0, 0.0, 1.0) - 0.4


func is_auwai(x: float, z: float) -> bool:
	return (z > -12.5 and z < -11.5 and x >= STREAM_X1 and x < -5.5) or (x > -6.5 and x < -5.5 and z >= -12.0 and z < -10.0)


func is_outflow(x: float, z: float) -> bool:
	return z > 6.5 and z < 7.5 and x >= STREAM_X1 and x < -10.0


func ground_h(x: float, z: float) -> float:
	var p := Vector2(x, z)
	for i in 3:
		if LOI[i].has_point(p):
			return loi_floor(i)
	var h := base_h(x, z)
	if x > STREAM_X0 and x < STREAM_X1:
		return h - 0.9
	if is_auwai(x, z) or is_outflow(x, z):
		return h - 0.3
	return h


func in_mud(pos: Vector3) -> bool:
	var p := Vector2(pos.x, pos.z)
	for r in LOI:
		if r.has_point(p):
			return true
	return false


func _terrain_color(x: float, z: float) -> Color:
	var p := Vector2(x, z)
	for r in LOI:
		if r.has_point(p):
			return Color(0.42, 0.29, 0.18)
	if x > STREAM_X0 and x < STREAM_X1:
		return Color(0.45, 0.44, 0.4)
	if is_auwai(x, z) or is_outflow(x, z):
		return Color(0.48, 0.35, 0.22)
	var n := 0.035 * sin(x * 0.9) * cos(z * 0.7)
	if z > 16.0:
		return Color(0.88, 0.82, 0.62)
	if z < -13.5 or x < STREAM_X0 or x > 19.5:
		return Color(0.18 + n, 0.42 + n, 0.2)
	# a worn dirt path from the loʻi to the hale and imu
	if (z > -0.6 and z < 0.6 and x > 2.0 and x < 16.0) or (x > 2.2 and x < 3.4 and z > -10.0 and z < 12.0):
		return Color(0.66, 0.55, 0.38)
	return Color(0.36 + n, 0.64 + n, 0.3)


func _vert(st: SurfaceTool, x: float, z: float) -> void:
	var e := 0.25
	var nrm := Vector3(ground_h(x - e, z) - ground_h(x + e, z), 2.0 * e, ground_h(x, z - e) - ground_h(x, z + e)).normalized()
	st.set_color(_terrain_color(x, z))
	st.set_normal(nrm)
	st.add_vertex(Vector3(x, ground_h(x, z), z))


func _build_terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step := 0.5
	var x0 := -32.0
	var z0 := -30.0
	var nx := 128
	var nz := 112
	for i in nx:
		for j in nz:
			var ax := x0 + i * step
			var az := z0 + j * step
			var bx := ax + step
			var bz := az + step
			_vert(st, ax, az)
			_vert(st, bx, bz)
			_vert(st, bx, az)
			_vert(st, ax, az)
			_vert(st, ax, bz)
			_vert(st, bx, bz)
	var mesh := st.commit()
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.vertex_color_is_srgb = true
	m.roughness = 1.0
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = m
	add_child(mi)
	# ocean (makai)
	add_mesh(self, box(140, 0.1, 50), Color(0.15, 0.5, 0.75), Vector3(0, -0.45, 42))


# =====================================================================
# World: water
# =====================================================================

func _build_water() -> void:
	for i in 3:
		var r: Rect2 = LOI[i]
		var c := r.get_center()
		var mi := add_mesh(self, box(r.size.x - 0.05, 0.04, r.size.y - 0.05), Color(0.3, 0.58, 0.8, 0.42),
			Vector3(c.x, loi_floor(i) + 0.3, c.y), Vector3.ZERO, Vector3.ONE, true)
		loi_water_nodes.append(mi)
	var z := -30.0
	while z < 18.0:
		var mi := add_mesh(self, box(3.0, 0.05, 1.02), Color(0.25, 0.58, 0.88, 0.85),
			Vector3(-15.5, 0, z + 0.5), Vector3.ZERO, Vector3.ONE, true)
		stream_segs.append({"node": mi, "z": z + 0.5})
		z += 1.0
	for xi in range(-14, -6):
		var x := xi + 0.5
		var mi := add_mesh(self, box(1.02, 0.04, 0.9), Color(0.3, 0.62, 0.88, 0.85), Vector3(x, base_h(x, -12.0) - 0.15, -12.0))
		auwai_segs.append({"node": mi, "x": x})
	for zz in [-11.5, -10.5]:
		var mi := add_mesh(self, box(0.9, 0.04, 1.02), Color(0.3, 0.62, 0.88, 0.85), Vector3(-6.0, base_h(-6.0, zz) - 0.15, zz))
		auwai_segs.append({"node": mi, "x": -6.0})
	for xi in range(-14, -10):
		var x := xi + 0.5
		var mi := add_mesh(self, box(1.02, 0.04, 0.9), Color(0.3, 0.62, 0.88, 0.85), Vector3(x, base_h(x, 7.0) - 0.15, 7.0))
		outflow_segs.append(mi)
	for k in 6:
		var f := Node3D.new()
		add_child(f)
		add_mesh(f, sphere(0.12), Color(0.35, 0.3, 0.2), Vector3.ZERO, Vector3.ZERO, Vector3(0.6, 0.5, 1.6))
		oopu.append({"node": f, "z": -9.0 + k * 2.4, "ph": randf() * TAU})


func stream_level(z: float) -> float:
	var flood := 0.35 if flood_state == "flood" else 0.0
	if z < -12.0:
		return 0.85 + flood
	var r := reach_level
	if z >= 7.0 and loi_flow[2]:
		r = minf(1.0, r + 0.35)
	return r + flood * 0.7


# =====================================================================
# World: decoration
# =====================================================================

func _tree(pos: Vector2, trunk_h: float, canopy_r: float, canopy_col: Color, name_label := "") -> void:
	var y := ground_h(pos.x, pos.y)
	var n := Node3D.new()
	n.position = Vector3(pos.x, y, pos.y)
	add_child(n)
	add_mesh(n, cyl(0.15, 0.25, trunk_h), Color(0.42, 0.3, 0.2), Vector3(0, trunk_h / 2, 0))
	add_mesh(n, sphere(canopy_r), canopy_col, Vector3(0, trunk_h + canopy_r * 0.5, 0), Vector3.ZERO, Vector3(1, 0.75, 1))
	add_mesh(n, sphere(canopy_r * 0.7), canopy_col.lightened(0.1), Vector3(canopy_r * 0.5, trunk_h + canopy_r * 0.2, 0.3))
	if name_label != "":
		label3d(n, name_label, Vector3(0, trunk_h + canopy_r * 1.6, 0), 34, Color(0.9, 1, 0.85))
	obstacles.append({"p": pos, "r": 0.45})


func _hale(pos: Vector2, w: float, d: float) -> void:
	var y := ground_h(pos.x, pos.y)
	var n := Node3D.new()
	n.position = Vector3(pos.x, y, pos.y)
	add_child(n)
	add_mesh(n, box(w, 1.6, d), Color(0.6, 0.48, 0.3), Vector3(0, 0.8, 0))
	add_mesh(n, box(0.9, 1.2, 0.05), Color(0.2, 0.14, 0.1), Vector3(0, 0.6, d / 2 + 0.01))
	var roof := PrismMesh.new()
	roof.size = Vector3(w + 0.8, 1.8, d + 0.6)
	add_mesh(n, roof, Color(0.78, 0.68, 0.38), Vector3(0, 2.5, 0))
	var r := maxf(w, d) * 0.5
	obstacles.append({"p": pos + Vector2(-w * 0.25, 0), "r": r * 0.6})
	obstacles.append({"p": pos + Vector2(w * 0.25, 0), "r": r * 0.6})


func _build_decor() -> void:
	# mountains mauka
	var peaks := [[-22, -36, 16, 20], [-6, -40, 18, 26], [10, -36, 15, 21], [26, -32, 14, 17], [-34, -18, 12, 14]]
	for pk in peaks:
		add_mesh(self, cyl(0.0, pk[2], pk[3]), Color(0.16, 0.4, 0.22), Vector3(pk[0], pk[3] / 2.0 - 1.0, pk[1]))
	# waterfall feeding the kahawai
	add_mesh(self, box(1.6, 9.0, 0.3), Color(0.75, 0.88, 1.0, 0.75), Vector3(-15.5, 8.0, -24.0))
	_hale(Vector2(15.5, -7.5), 4.0, 3.0)
	_hale(Vector2(17.6, 3.0), 2.4, 2.4)
	_tree(Vector2(2.8, -12.0), 2.6, 1.3, Color(0.55, 0.72, 0.45), "Kukui")
	_tree(Vector2(18.0, 7.5), 2.8, 1.6, Color(0.22, 0.5, 0.22), "ʻUlu")
	_tree(Vector2(-12.0, 15.0), 2.4, 1.4, Color(0.3, 0.55, 0.28))
	_tree(Vector2(9.0, -12.0), 2.2, 1.2, Color(0.3, 0.55, 0.28))
	_tree(Vector2(18.5, -12.0), 2.4, 1.4, Color(0.55, 0.72, 0.45))
	# maiʻa (banana) clump
	var bp := Vector2(3.8, 13.0)
	for k in 3:
		var p := Vector3(bp.x + k * 0.5, ground_h(bp.x, bp.y), bp.y + (k % 2) * 0.5)
		add_mesh(self, cyl(0.15, 0.2, 2.2), Color(0.5, 0.6, 0.3), p + Vector3(0, 1.1, 0))
		for j in 4:
			var a := j * TAU / 4.0 + k
			add_mesh(self, sphere(0.6), Color(0.35, 0.65, 0.25), p + Vector3(cos(a) * 0.6, 2.3, sin(a) * 0.6), Vector3(0, a, 0.5), Vector3(0.35, 0.08, 1.4))
	label3d(self, "Maiʻa", Vector3(bp.x + 0.5, ground_h(bp.x, bp.y) + 3.6, bp.y), 34, Color(0.9, 1, 0.85))
	obstacles.append({"p": bp + Vector2(0.5, 0.2), "r": 0.8})
	# signage for the land itself
	label3d(self, "MAUKA  (toward the mountains)", Vector3(-2, 6.5, -15.5), 64, Color(0.85, 1, 0.85))
	label3d(self, "MAKAI  (toward the sea)", Vector3(3, 1.6, 16.0), 64, Color(0.8, 0.95, 1))
	label3d(self, "Kahawai (stream)", Vector3(-15.5, 3.5, -6), 44, Color(0.75, 0.9, 1))
	label3d(self, "ʻAuwai (ditch)", Vector3(-10, 3.6, -12.6), 40, Color(0.75, 0.9, 1))
	for i in 3:
		var r: Rect2 = LOI[i]
		label3d(self, "Loʻi %d" % (i + 1), Vector3(r.position.x + 0.8, loi_floor(i) + 1.0, r.get_center().y), 40, Color(1, 0.95, 0.8))
	# rocks along the kahawai bank
	for k in 14:
		var z := -12.0 + k * 2.0 + randf()
		add_mesh(self, sphere(0.3 + randf() * 0.2), Color(0.45, 0.45, 0.43), Vector3(-13.9, ground_h(-13.9, z) + 0.05, z), Vector3.ZERO, Vector3(1, 0.6, 1))
	# rain drops (shown during the flood event)
	for k in 80:
		var d := add_mesh(self, box(0.03, 0.5, 0.03), Color(0.75, 0.85, 1.0, 0.6))
		d.visible = false
		rain.append({"node": d, "off": Vector3(randf_range(-16, 16), randf_range(0, 12), randf_range(-12, 12))})


# =====================================================================
# Stations
# =====================================================================

func _station(kind: String, pos: Vector2, opts := {}, block := 0.0):
	var s = StationScript.new()
	add_child(s)
	s.position = Vector3(pos.x, ground_h(pos.x, pos.y), pos.y)
	s.setup(self, kind, opts)
	stations.append(s)
	if block > 0.0:
		obstacles.append({"p": pos, "r": block})
	return s


func _build_stations() -> void:
	# kalo planting spots: 3 per loʻi. A few start grown so orders can begin quickly.
	var start_growth := [[3.0, 3.0, 1.6], [2.2, -1.0, 1.0], [-1.0, -1.0, 0.4]]
	for i in 3:
		var cz: float = LOI[i].get_center().y
		for k in 3:
			var g: float = start_growth[i][k]
			_station("plot", Vector2(-7.0 + k * 3.0, cz), {"loi": i, "planted": g >= 0.0, "growth": maxf(g, 0.0)})
	_station("huli_pile", Vector2(4.0, -2.2), {"count": 2}, 0.55)
	gate_station = _station("gate", Vector2(-13.5, -11.0), {}, 0.3)
	_station("kahawai", Vector2(-13.9, -2.0))
	_station("kahawai", Vector2(-13.9, 12.0))
	_station("imu", Vector2(9.0, -3.5), {}, 1.0)
	_station("counter", Vector2(6.6, -3.5), {}, 0.5)
	_station("counter", Vector2(11.4, -3.5), {}, 0.5)
	_station("papa", Vector2(10.0, 2.2), {}, 0.7)
	_station("wai_stand", Vector2(12.8, 2.2), {}, 0.6)
	_station("counter", Vector2(7.4, 2.2), {}, 0.5)
	_station("umeke", Vector2(10.0, 6.4), {}, 0.7)
	_station("ki", Vector2(6.6, 8.8), {}, 0.7)
	_station("counter", Vector2(13.0, 6.4), {}, 0.5)
	aha_station = _station("aha", Vector2(15.0, 11.5), {}, 0.0)
	obstacles.append({"p": Vector2(13.6, 12.9), "r": 0.5})
	obstacles.append({"p": Vector2(15.0, 12.9), "r": 0.5})
	obstacles.append({"p": Vector2(16.4, 12.9), "r": 0.5})
	_station("tutu", Vector2(14.8, -4.2), {}, 0.45)
	# two ipu to start with
	spawn_item("ipu_empty", Vector3(13.6, 0, 3.4))
	spawn_item("ipu_full", Vector3(12.0, 0, 3.6))


func new_item(k: String):
	var it = ItemScript.new()
	add_child(it)
	it.setup(self, k)
	return it


func spawn_item(k: String, pos: Vector3):
	var it = new_item(k)
	it.position = Vector3(pos.x, ground_h(pos.x, pos.z) + 0.02, pos.z)
	items.append(it)
	return it


func pick_item(p, it) -> void:
	items.erase(it)
	p.attach(it)


func drop_item(p) -> void:
	var it = p.held
	p.held = null
	var pos: Vector3 = p.position + p.facing * 0.7
	pos.x = clampf(pos.x, BOUNDS.position.x, BOUNDS.end.x)
	pos.z = clampf(pos.z, BOUNDS.position.y, BOUNDS.end.y)
	it.get_parent().remove_child(it)
	add_child(it)
	it.rotation = Vector3.ZERO
	it.position = Vector3(pos.x, ground_h(pos.x, pos.z) + 0.02, pos.z)
	items.append(it)


func find_target(p) -> Array:
	var front: Vector3 = p.position + p.facing * 0.7
	var best = null
	var best_item := false
	var best_d := 99.0
	for s in stations:
		var d: float = Vector2(front.x - s.position.x, front.z - s.position.z).length()
		if d > s.reach:
			continue
		var relevant: bool = s.grab_prompt(p) != "" or s.work_prompt(p) != ""
		var sc := d + (0.0 if relevant else 0.8)
		if sc < best_d:
			best_d = sc
			best = s
			best_item = false
	if p.held == null:
		for it in items:
			var d2: float = Vector2(front.x - it.position.x, front.z - it.position.z).length()
			if d2 < 0.95 and d2 - 0.15 < best_d:
				best_d = d2 - 0.15
				best = it
				best_item = true
	return [best, best_item]


func resolve(np: Vector3, who) -> Vector3:
	np.x = clampf(np.x, BOUNDS.position.x, BOUNDS.end.x)
	np.z = clampf(np.z, BOUNDS.position.y, BOUNDS.end.y)
	for o in obstacles:
		var c: Vector2 = o["p"]
		var r: float = o["r"] + 0.35
		var d := Vector2(np.x - c.x, np.z - c.y)
		if d.length() < r:
			if d.length() < 0.001:
				d = Vector2(1, 0)
			var push := d.normalized() * r
			np.x = c.x + push.x
			np.z = c.y + push.y
	for q in players:
		if q == who:
			continue
		var d2 := Vector2(np.x - q.position.x, np.z - q.position.z)
		if d2.length() < 0.75 and d2.length() > 0.001:
			var push2 := d2.normalized() * 0.75
			np.x = q.position.x + push2.x
			np.z = q.position.z + push2.y
	return np


func _spawn_player(id: int) -> void:
	var p = PlayerScript.new()
	add_child(p)
	p.setup(self, id, PLAYER_COLORS[id])
	var start: Vector2 = [Vector2(5.0, -0.2), Vector2(6.5, 0.6)][id]
	p.position = Vector3(start.x, ground_h(start.x, start.y), start.y)
	players.append(p)
	if id == 1:
		float_text("Player 2 joined!", p.position)


# =====================================================================
# Game rules
# =====================================================================

func growth_rate(i: int) -> float:
	if loi_flow[i]:
		return (1.0 / 14.0) * (1.4 if gate_all else 1.0)
	return 0.012


func gate_text() -> String:
	if not gate_open:
		return "CLOSED"
	return "TAKING ALL the water" if gate_all else "SHARING the water"


func toggle_gate() -> void:
	gate_open = not gate_open
	if gate_open:
		gate_all = false
		tip("share", flood_state == "")
	else:
		tip("closed")
	float_text("Poʻo wai " + ("opened" if gate_open else "closed"), gate_station.global_position)


func set_gate_all(v: bool) -> void:
	gate_all = v
	if v:
		tip("all", true)
	else:
		tip("share", true)


func tutu_talk() -> void:
	tip_queue.clear()
	tip_queue.append(TUTU_TALK[talk_i % TUTU_TALK.size()])
	talk_i += 1
	tip_time = 0.0


func tip(key: String, force := false) -> void:
	if tip_seen.has(key) and not force:
		return
	tip_seen[key] = true
	var text: String = TIPS.get(key, key)
	if force:
		tip_queue.push_front(text)
		tip_time = 0.0
	elif not tip_queue.has(text):
		tip_queue.append(text)


func float_text(text: String, pos: Vector3, col := Color(1, 1, 0.7)) -> void:
	var l := label3d(self, text, pos + Vector3(0, 2.0, 0), 44, col, true)
	floaters.append({"node": l, "t": 0.0})


func _spawn_clog() -> void:
	var free_x: Array = []
	for x in AUWAI_CLOG_X:
		var used := false
		for c in clogs:
			if absf(c.position.x - x) < 0.1:
				used = true
		if not used:
			free_x.append(x)
	if free_x.is_empty():
		return
	var cx: float = free_x.pick_random()
	var s = _station("clog", Vector2(cx, -12.0))
	clogs.append(s)
	tip("clog")
	float_text("ʻŌpala in the ʻauwai!", s.position, Color(1, 0.75, 0.5))


func remove_clog(s) -> void:
	clogs.erase(s)
	stations.erase(s)
	float_text("ʻAuwai cleared!", s.position)
	health = minf(100.0, health + 1.0)
	s.queue_free()


func _flood_damage() -> void:
	breached = true
	breach_station = _station("breach", Vector2(-1.5, -4.0))
	health = maxf(0.0, health - 10.0)
	_spawn_clog()
	_spawn_clog()
	tip("breach", true)
	float_text("The flood broke the kuāuna!", breach_station.position, Color(1, 0.6, 0.5))


func repair_breach() -> void:
	breached = false
	stations.erase(breach_station)
	float_text("Kuāuna rebuilt!", breach_station.position)
	breach_station.queue_free()
	breach_station = null


func serve(k: String) -> bool:
	var best = null
	for o in orders:
		if o["kind"] == k and (best == null or o["left"] < best["left"]):
			best = o
	if best == null:
		return false
	var info: Dictionary = ORDER_INFO[k]
	var bonus := int(10.0 * best["left"] / ORDER_TIME)
	var pts: int = info["points"] + bonus
	score += pts
	served += 1
	orders.erase(best)
	_rebuild_orders()
	float_text("+%d  ʻOno!" % pts, aha_station.position, Color(1, 0.9, 0.4))
	tip("serve")
	return true


func _add_order() -> void:
	var k := forced_next
	forced_next = ""
	if k == "":
		k = unlocked.pick_random()
	orders.append({"kind": k, "left": ORDER_TIME})
	_rebuild_orders()


func _update_orders(delta: float) -> void:
	if t > 40.0 and not unlocked.has("luau"):
		unlocked.append("luau")
		forced_next = "luau"
		next_order = minf(next_order, 1.0)
		tip("order_luau")
	if t > 85.0 and not unlocked.has("paiai_wrapped"):
		unlocked.append("paiai_wrapped")
		forced_next = "paiai_wrapped"
		next_order = minf(next_order, 1.0)
		tip("order_paiai_wrapped")
	next_order -= delta
	if orders.is_empty() and next_order > 4.0:
		next_order = 4.0
	if next_order <= 0.0 and orders.size() < 4:
		_add_order()
		next_order = randf_range(20.0, 27.0)
	for o in orders.duplicate():
		o["left"] -= delta
		if o["left"] <= 0.0:
			orders.erase(o)
			missed += 1
			score = maxi(0, score - 10)
			float_text("Order missed  -10", aha_station.position, Color(1, 0.5, 0.4))
			tip("missed")
			_rebuild_orders()


func _update_sim(delta: float) -> void:
	# --- flood event
	if flood_state == "" and not flood_times.is_empty() and t >= flood_times[0]:
		flood_times.pop_front()
		flood_state = "warning"
		flood_timer = 12.0
		tip("flood_warn", true)
	elif flood_state == "warning":
		flood_timer -= delta
		if flood_timer <= 0.0:
			flood_state = "flood"
			flood_timer = 14.0
			if gate_open:
				_flood_damage()
			else:
				health = minf(100.0, health + 6.0)
				tip("flood_ok", true)
				float_text("Kuāuna protected!", gate_station.position, Color(0.6, 1, 0.6))
	elif flood_state == "flood":
		flood_timer -= delta
		if gate_open and not breached:
			_flood_damage()
		if flood_timer <= 0.0:
			flood_state = ""
			tip("flood_end", true)
	# --- debris in the ʻauwai
	next_clog -= delta
	if next_clog <= 0.0:
		next_clog = randf_range(28.0, 40.0)
		_spawn_clog()
	# --- water flow through the loʻi
	var inflow := gate_open and clogs.is_empty()
	loi_flow[0] = inflow and not breached
	loi_flow[1] = loi_flow[0]
	loi_flow[2] = loi_flow[1]
	if not loi_flow[0] and flood_state == "":
		stagnant_time += delta
		if stagnant_time > 6.0:
			tip("stagnant")
	else:
		stagnant_time = 0.0
	var target_r := 0.6
	if not gate_open:
		target_r = 0.95
	elif gate_all:
		target_r = 0.04
	reach_level = move_toward(reach_level, target_r, delta * 0.35)
	# --- ʻāina health
	var dh := 0.0
	if gate_open and gate_all and reach_level < 0.3:
		dh -= 1.6
	elif gate_open and not gate_all and loi_flow[0]:
		dh += 0.3
	for s in stations:
		if s.kind == "plot" and s.weed:
			dh -= 0.12
	if breached:
		dh -= 0.6
	dh -= 0.08 * clogs.size()
	health = clampf(health + dh * delta, 0.0, 100.0)


func _check_join() -> void:
	if players.size() >= 2:
		return
	for a in ["p1_up", "p1_down", "p1_left", "p1_right", "p1_grab", "p1_work"]:
		if Input.is_action_just_pressed(a):
			_spawn_player(1)
			return


func _start() -> void:
	state = "play"
	title_overlay.visible = false
	t = 0.0
	tip("start")
	for p in players:
		cam_focus = p.position


func _end_level() -> void:
	state = "end"
	var bonus := int(health)
	var total := score + bonus
	var stars := 0
	for s in STAR_SCORES:
		if total >= s:
			stars += 1
	for c in end_stars.get_children():
		c.queue_free()
	for k in 3:
		end_stars.add_child(_star(k < stars))
	var health_msg := "Pono! The stream and the loʻi are thriving."
	if health < 40.0:
		health_msg = "The kahawai and the loʻi are struggling. Remember to share the water and keep it flowing."
	elif health < 75.0:
		health_msg = "The ʻāina could use more care — keep the water flowing and the mauʻu pulled."
	end_text.text = ("[center][font_size=40][b]Pau hana![/b][/font_size]\n"
		+ "[font_size=20]Work is done for the day.[/font_size]\n\n"
		+ "Orders served: [b]%d[/b]    Missed: [b]%d[/b]\n" % [served, missed]
		+ "Order points: [b]%d[/b]\n" % score
		+ "ʻĀina health bonus: [b]+%d[/b]\n" % bonus
		+ "[font_size=30]Total: [b]%d[/b][/font_size]\n\n" % total
		+ "[i]%s[/i]\n\n" % health_msg
		+ "[color=#ffe9a8][b]Moʻolelo card unlocked: Hāloa[/b][/color]\n"
		+ "In Hawaiian tradition, the first kalo plant, Hāloanakalaukapalili,\nis the elder sibling of Hāloa, ancestor of the Hawaiian people.\nCaring for kalo is caring for family.\n"
		+ "[font_size=14][color=#bbbbbb](Prototype text — to be reviewed with cultural advisors.)[/color][/font_size]\n\n"
		+ "Press [b]R[/b] to play again[/center]")
	end_overlay.visible = true


# =====================================================================
# Frame loop
# =====================================================================

func _process(delta: float) -> void:
	delta = minf(delta, 0.05)
	anim_t += delta
	if Input.is_action_just_pressed("glossary"):
		glossary_overlay.visible = not glossary_overlay.visible
	if Input.is_action_just_pressed("pause") and state == "play":
		paused = not paused
	pause_overlay.visible = paused and state == "play"
	var frozen := paused or glossary_overlay.visible
	if state == "title" and Input.is_action_just_pressed("start") and not glossary_overlay.visible:
		_start()
	elif state == "end" and Input.is_action_just_pressed("restart"):
		quick_restart = true
		get_tree().reload_current_scene()
		return
	elif state == "play" and not frozen:
		t += delta
		_update_sim(delta)
		for p in players:
			p.tick(delta)
		for s in stations.duplicate():
			if is_instance_valid(s):
				s.tick(delta)
		_update_orders(delta)
		_check_join()
		if t >= LEVEL_TIME:
			_end_level()
	_update_visuals(delta)
	_update_camera(delta)
	_update_ui(delta)


func _update_visuals(delta: float) -> void:
	for i in 3:
		var target := 1.0 if loi_flow[i] else 0.4
		if breached and i == 0:
			target = 0.05
		loi_water[i] = move_toward(loi_water[i], target, delta * 0.4)
		var n: MeshInstance3D = loi_water_nodes[i]
		n.position.y = loi_floor(i) + 0.04 + 0.3 * loi_water[i]
		n.visible = loi_water[i] > 0.08
		var flowing := Color(0.3, 0.58, 0.8, 0.42)
		var still := Color(0.42, 0.45, 0.25, 0.62)
		n.material_override.albedo_color = flowing if loi_flow[i] else still
	var flood_col := Color(0.55, 0.45, 0.3, 0.9)
	for s in stream_segs:
		var z: float = s["z"]
		var lvl := stream_level(z)
		var n: MeshInstance3D = s["node"]
		n.position.y = base_h(-15.5, z) - 0.85 + 0.8 * lvl
		n.visible = lvl > 0.06
		n.material_override.albedo_color = flood_col if flood_state == "flood" else Color(0.25, 0.58, 0.88, 0.85)
	var min_clog := 99.0
	for c in clogs:
		min_clog = minf(min_clog, c.position.x)
	for s in auwai_segs:
		s["node"].visible = gate_open and float(s["x"]) < min_clog
	for n in outflow_segs:
		n.visible = loi_flow[2] and loi_water[2] > 0.6
	for f in oopu:
		var node: Node3D = f["node"]
		var z: float = f["z"] + sin(anim_t * 0.7 + f["ph"]) * 1.2
		node.visible = reach_level > 0.3
		node.position = Vector3(-15.5 + sin(anim_t * 1.3 + f["ph"]) * 0.8, base_h(-15.5, z) - 0.85 + 0.8 * stream_level(z) - 0.12, z)
		node.rotation.y = sin(anim_t * 0.7 + f["ph"]) * 0.6
	var stormy := flood_state != ""
	sun.light_energy = lerpf(sun.light_energy, 0.55 if stormy else 1.35, delta * 2.0)
	for d in rain:
		var n: MeshInstance3D = d["node"]
		n.visible = stormy
		if stormy:
			var off: Vector3 = d["off"]
			var y := fmod(off.y - anim_t * 14.0, 12.0)
			if y < 0.0:
				y += 12.0
			n.position = cam_focus + Vector3(off.x, y, off.z)
	for f in floaters.duplicate():
		f["t"] += delta
		var l: Label3D = f["node"]
		l.position.y += delta * 1.2
		l.modulate.a = clampf(1.6 - f["t"], 0.0, 1.0)
		if f["t"] > 1.6:
			l.queue_free()
			floaters.erase(f)


func _update_camera(delta: float) -> void:
	var focus := Vector3(-1.0, 1.0, -0.5)
	var zoom := 1.55
	if state != "title" and not players.is_empty():
		focus = Vector3.ZERO
		for p in players:
			focus += p.position
		focus /= players.size()
		var spread := 0.0
		for p in players:
			spread = maxf(spread, p.position.distance_to(focus))
		zoom = clampf(1.0 + spread / 14.0, 1.0, 1.6)
		focus.x = clampf(focus.x, -8.0, 12.0)
		focus.z = clampf(focus.z, -8.5, 9.0)
	var k := clampf(delta * 3.0, 0.0, 1.0)
	cam_focus = cam_focus.lerp(focus, k)
	cam_zoom = lerpf(cam_zoom, zoom, k)
	cam.position = cam_focus + Vector3(0, 14.5, 12.0) * cam_zoom
	cam.look_at(cam_focus, Vector3.UP)


# =====================================================================
# Environment + HUD
# =====================================================================

func _build_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.32, 0.6, 0.92)
	sm.sky_horizon_color = Color(0.75, 0.88, 0.95)
	sm.ground_bottom_color = Color(0.25, 0.4, 0.3)
	sm.ground_horizon_color = Color(0.7, 0.85, 0.85)
	sky.sky_material = sm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.78, 0.84, 0.9)
	env.ambient_light_energy = 0.75
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -30, 0)
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 50.0
	add_child(sun)
	cam = Camera3D.new()
	cam.fov = 42.0
	cam.far = 300.0
	add_child(cam)
	cam.current = true


func _style(col: Color, radius := 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb


func _label(text: String, size := 18, col := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	l.add_theme_constant_override("outline_size", 5)
	return l


func _rich(size := 19, col := Color.WHITE, min_size := Vector2(700, 0)) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.custom_minimum_size = min_size
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_font_size_override("bold_font_size", size)
	r.add_theme_font_size_override("italics_font_size", size)
	r.add_theme_color_override("default_color", col)
	return r


func _overlay(bg: Color) -> Array:
	var root := ColorRect.new()
	root.color = bg
	ui.add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var cc := CenterContainer.new()
	root.add_child(cc)
	cc.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(Color(0.08, 0.16, 0.12, 0.94), 18))
	cc.add_child(panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	panel.add_child(vb)
	return [root, vb]


func _star(filled: bool) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(64, 64)
	var poly := Polygon2D.new()
	var pts := PackedVector2Array()
	for k in 10:
		var r := 30.0 if k % 2 == 0 else 13.0
		var a := -PI / 2.0 + k * PI / 5.0
		pts.append(Vector2(32, 34) + Vector2(cos(a), sin(a)) * r)
	poly.polygon = pts
	poly.color = Color(1, 0.82, 0.2) if filled else Color(0.35, 0.35, 0.35)
	c.add_child(poly)
	return c


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	ui = Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.theme = ui_theme
	layer.add_child(ui)
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	orders_box = HBoxContainer.new()
	orders_box.position = Vector2(16, 16)
	orders_box.add_theme_constant_override("separation", 10)
	ui.add_child(orders_box)

	var rp := PanelContainer.new()
	rp.add_theme_stylebox_override("panel", _style(Color(0.08, 0.14, 0.1, 0.8)))
	ui.add_child(rp)
	rp.anchor_left = 1.0
	rp.anchor_right = 1.0
	rp.offset_left = -300
	rp.offset_right = -16
	rp.offset_top = 16
	var v := VBoxContainer.new()
	rp.add_child(v)
	time_label = _label("", 26)
	v.add_child(time_label)
	score_label = _label("", 22, Color(1, 0.9, 0.5))
	v.add_child(score_label)
	health_label = _label("", 16)
	v.add_child(health_label)
	health_bar = ProgressBar.new()
	health_bar.max_value = 100.0
	health_bar.show_percentage = false
	health_bar.custom_minimum_size = Vector2(256, 18)
	health_fill = StyleBoxFlat.new()
	health_fill.bg_color = Color(0.3, 0.8, 0.35)
	health_fill.set_corner_radius_all(6)
	var hbg := StyleBoxFlat.new()
	hbg.bg_color = Color(0.2, 0.2, 0.2)
	hbg.set_corner_radius_all(6)
	health_bar.add_theme_stylebox_override("fill", health_fill)
	health_bar.add_theme_stylebox_override("background", hbg)
	v.add_child(health_bar)
	gate_label = _label("", 16)
	v.add_child(gate_label)
	wai_label = _label("", 16, Color(0.7, 0.88, 1))
	v.add_child(wai_label)
	p2_hint = _label("Player 2: press O or IJKL to join", 14, Color(0.7, 0.85, 1))
	v.add_child(p2_hint)
	v.add_child(_label("G: glossary    Esc: pause", 14, Color(0.8, 0.8, 0.8)))

	tip_panel = PanelContainer.new()
	var tip_style := _style(Color(0.99, 0.95, 0.84, 0.96), 14)
	tip_style.border_color = Color(0.55, 0.35, 0.6)
	tip_style.set_border_width_all(3)
	tip_panel.add_theme_stylebox_override("panel", tip_style)
	ui.add_child(tip_panel)
	tip_panel.anchor_left = 0.5
	tip_panel.anchor_right = 0.5
	tip_panel.anchor_top = 1.0
	tip_panel.anchor_bottom = 1.0
	tip_panel.offset_left = -390
	tip_panel.offset_right = 390
	tip_panel.offset_top = -120
	tip_panel.offset_bottom = -16
	tip_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	tip_text = _rich(19, Color(0.18, 0.12, 0.08), Vector2(750, 0))
	tip_panel.add_child(tip_text)
	tip_panel.visible = false

	banner = _label("", 30, Color(1, 0.95, 0.85))
	banner.add_theme_color_override("font_outline_color", Color(0.6, 0.1, 0.05))
	banner.add_theme_constant_override("outline_size", 10)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.add_child(banner)
	banner.anchor_left = 0.0
	banner.anchor_right = 1.0
	banner.offset_top = 175
	banner.offset_bottom = 220

	# --- title screen
	var tt := _overlay(Color(0, 0, 0, 0.35))
	title_overlay = tt[0]
	var title := _rich(19, Color.WHITE, Vector2(760, 0))
	title.text = ("[center][font_size=52][b]Loʻi Kalo[/b][/font_size]\n"
		+ "[i]ʻAʻohe hana nui ke alu ʻia — no task is too big when done together.[/i][/center]\n\n"
		+ "Feed the ʻohana at the [b]ʻaha ʻāina[/b] by growing, cooking and pounding kalo — and keep the [b]ʻāina[/b] healthy while you do it.\n\n"
		+ "[b]Player 1[/b]   Move: WASD / arrows    Grab / place: [b]E[/b]    Hold to work: [b]Q[/b] or F    Dash: Space\n"
		+ "[b]Player 2[/b]   Move: IJKL    Grab / place: [b]O[/b]    Hold to work: [b]U[/b] or H    Dash: Enter\n"
		+ "Gamepads: stick to move, A grab, X hold to work, B dash.    [b]G[/b] glossary of Hawaiian words.\n\n"
		+ "[center][font_size=26][b]Press E, Space or Enter to start[/b][/font_size]\n"
		+ "[font_size=14][color=#bbbbbb]Prototype — placeholder art. Cultural content is draft text to be reviewed with cultural advisors.[/color][/font_size][/center]")
	tt[1].add_child(title)

	# --- end screen
	var et := _overlay(Color(0, 0, 0, 0.55))
	end_overlay = et[0]
	end_stars = HBoxContainer.new()
	end_stars.alignment = BoxContainer.ALIGNMENT_CENTER
	et[1].add_child(end_stars)
	end_text = _rich(19, Color.WHITE, Vector2(700, 0))
	et[1].add_child(end_text)
	end_overlay.visible = false

	# --- glossary
	var gt := _overlay(Color(0, 0, 0, 0.55))
	glossary_overlay = gt[0]
	var gl := _rich(17, Color.WHITE, Vector2(760, 0))
	var s := "[center][font_size=32][b]Hawaiian words in this level[/b][/font_size][/center]\n"
	for row in GLOSSARY:
		s += "[b]%s[/b] — %s\n" % [row[0], row[1]]
	s += "\n[center][color=#bbbbbb]Draft definitions — check against Pukui & Elbert, Hawaiian Dictionary. Press G to close.[/color][/center]"
	gl.text = s
	gt[1].add_child(gl)
	glossary_overlay.visible = false

	# --- pause
	var pt := _overlay(Color(0, 0, 0, 0.45))
	pause_overlay = pt[0]
	var pl := _label("Paused — press Esc to keep playing", 30)
	pt[1].add_child(pl)
	pause_overlay.visible = false


func _rebuild_orders() -> void:
	for c in orders_box.get_children():
		c.queue_free()
	for o in orders:
		var info: Dictionary = ORDER_INFO[o["kind"]]
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", _style(info["color"], 10))
		card.custom_minimum_size = Vector2(220, 0)
		var vb := VBoxContainer.new()
		card.add_child(vb)
		vb.add_child(_label(info["name"], 22))
		vb.add_child(_label(info["steps"], 13, Color(0.92, 0.92, 0.88)))
		var pb := ProgressBar.new()
		pb.max_value = ORDER_TIME
		pb.show_percentage = false
		pb.custom_minimum_size = Vector2(190, 10)
		var f := StyleBoxFlat.new()
		f.bg_color = Color(0.95, 0.85, 0.3)
		f.set_corner_radius_all(4)
		pb.add_theme_stylebox_override("fill", f)
		vb.add_child(pb)
		o["bar"] = pb
		o["fill"] = f
		orders_box.add_child(card)


func _update_ui(delta: float) -> void:
	var left := maxf(0.0, LEVEL_TIME - t)
	time_label.text = "Time  %d:%02d" % [int(left) / 60, int(left) % 60]
	score_label.text = "Score  %d" % score
	health_label.text = "ʻĀina health  %d%%" % int(health)
	health_bar.value = health
	health_fill.bg_color = Color(0.9, 0.3, 0.25).lerp(Color(0.3, 0.8, 0.35), health / 100.0)
	gate_label.text = "Poʻo wai: " + gate_text()
	gate_label.add_theme_color_override("font_color", Color(1, 0.6, 0.5) if (gate_all or not gate_open) else Color(0.7, 1, 0.7))
	wai_label.text = "Wai for pounding: %d / 6" % wai
	p2_hint.visible = players.size() < 2
	for o in orders:
		if o.has("bar"):
			o["bar"].value = o["left"]
			o["fill"].bg_color = Color(0.9, 0.3, 0.25) if o["left"] < 25.0 else Color(0.95, 0.85, 0.3)
	# tips
	tip_time -= delta
	if tip_time <= 0.0:
		if not tip_queue.is_empty() and state == "play":
			var text: String = tip_queue.pop_front()
			tip_text.text = "[b]Tūtū:[/b] " + text
			tip_panel.visible = true
			tip_time = 5.0 + text.length() / 30.0
		else:
			tip_panel.visible = false
	# banner
	banner.text = ""
	if state == "play":
		if flood_state == "warning":
			banner.text = "Kahawai rising! Close the poʻo wai!  %d" % ceili(flood_timer)
		elif flood_state == "flood":
			banner.text = "FLOOD! Keep the poʻo wai closed!" if not breached else "Rebuild the broken kuāuna!"
		elif breached:
			banner.text = "Rebuild the broken kuāuna!"
		elif gate_all and reach_level < 0.3:
			banner.text = "The kahawai is drying up below the poʻo wai!"
