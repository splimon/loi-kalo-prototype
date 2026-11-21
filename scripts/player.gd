extends Node3D
## A mahiʻai (farmer). Move, grab/place (one button), hold to work (other button), dash.

var main
var pid := 0
var held = null
var facing := Vector3(0, 0, 1)
var vel := Vector3.ZERO
var dash_t := 0.0
var dash_cd := 0.0
var target = null
var target_is_item := false
var work_lock := false
var working := false
var body_root: Node3D
var hand: Node3D
var prompt: Label3D
var marker: MeshInstance3D
var walk_phase := 0.0
var color := Color.WHITE
var grab_key := "E"
var work_key := "Q"


func setup(m, id: int, col: Color) -> void:
	main = m
	pid = id
	color = col
	grab_key = "E" if id == 0 else "O"
	work_key = "Q" if id == 0 else "U"
	body_root = Node3D.new()
	add_child(body_root)
	main.add_mesh(body_root, main.capsule(0.34, 1.1), col, Vector3(0, 0.6, 0))
	main.add_mesh(body_root, main.sphere(0.27), Color(0.55, 0.38, 0.27), Vector3(0, 1.32, 0))
	main.add_mesh(body_root, main.sphere(0.28), Color(0.12, 0.08, 0.06), Vector3(0, 1.43, -0.06), Vector3.ZERO, Vector3(1, 0.7, 1))
	var lei_col := Color(1.0, 0.85, 0.2) if id == 0 else Color(0.95, 0.45, 0.65)
	main.add_mesh(body_root, main.torus(0.22, 0.34), lei_col, Vector3(0, 1.08, 0))
	main.add_mesh(body_root, main.box(0.08, 0.08, 0.1), Color(0.5, 0.34, 0.24), Vector3(0, 1.32, 0.27))
	hand = Node3D.new()
	hand.position = Vector3(0, 0.8, 0.52)
	body_root.add_child(hand)
	main.add_mesh(self, main.torus(0.42, 0.55), col, Vector3(0, 0.05, 0), Vector3.ZERO, Vector3(1, 0.25, 1))
	main.label3d(self, "P%d" % (id + 1), Vector3(0, 2.0, 0), 34, col.lightened(0.3), true)
	marker = main.add_mesh(main, main.torus(0.55, 0.7), col, Vector3.ZERO, Vector3.ZERO, Vector3(1, 0.3, 1))
	marker.visible = false
	prompt = main.label3d(main, "", Vector3.ZERO, 40, Color.WHITE, true)
	prompt.pixel_size = 0.009
	prompt.modulate = Color(1, 1, 1).lerp(col, 0.25)


func held_kind() -> String:
	return held.kind if held != null else ""


func attach(it) -> void:
	if it.get_parent():
		it.get_parent().remove_child(it)
	hand.add_child(it)
	it.position = Vector3.ZERO
	it.rotation = Vector3.ZERO
	held = it


func give(k: String) -> void:
	var it = main.new_item(k)
	attach(it)


func consume() -> void:
	if held:
		held.queue_free()
	held = null


func release_to(parent: Node3D, local_pos: Vector3):
	var it = held
	held = null
	hand.remove_child(it)
	parent.add_child(it)
	it.position = local_pos
	it.rotation = Vector3.ZERO
	return it


func tick(delta: float) -> void:
	var a := "p%d_" % pid
	var mv := Input.get_vector(a + "left", a + "right", a + "up", a + "down")
	var dir := Vector3(mv.x, 0, mv.y)
	var res: Array = main.find_target(self)
	target = res[0]
	target_is_item = res[1]

	# Hold-to-work
	var want_work := Input.is_action_pressed(a + "work")
	if not want_work:
		work_lock = false
	working = false
	if want_work and not work_lock and target != null and not target_is_item:
		if target.work_prompt(self) != "":
			working = true
			if target.work(delta, self):
				work_lock = true
	if working:
		dir = Vector3.ZERO

	# Dash
	dash_cd -= delta
	dash_t -= delta
	if Input.is_action_just_pressed(a + "dash") and dash_cd <= 0.0:
		dash_t = 0.16
		dash_cd = 0.7
	var spd := 5.6 * (0.68 if main.in_mud(position) else 1.0)
	var want := dir * spd
	if dash_t > 0.0:
		want = facing * spd * 2.8
	vel = vel.lerp(want, clampf(delta * 14.0, 0.0, 1.0))
	var np: Vector3 = main.resolve(position + vel * delta, self)
	position.x = np.x
	position.z = np.z
	var gy: float = main.ground_h(position.x, position.z)
	position.y = lerpf(position.y, gy, clampf(delta * 14.0, 0.0, 1.0))
	if dir.length() > 0.1:
		facing = dir.normalized()
	body_root.rotation.y = lerp_angle(body_root.rotation.y, atan2(facing.x, facing.z), clampf(delta * 16.0, 0.0, 1.0))
	if working:
		walk_phase += delta * 18.0
		body_root.position.y = absf(sin(walk_phase)) * 0.12
	elif vel.length() > 0.5:
		walk_phase += delta * 12.0
		body_root.position.y = absf(sin(walk_phase)) * 0.08
	else:
		body_root.position.y = 0.0

	if Input.is_action_just_pressed(a + "grab"):
		_grab()
	_update_prompt()


func _grab() -> void:
	if target != null and not target_is_item:
		if target.grab(self):
			return
	if target != null and target_is_item and held == null:
		main.pick_item(self, target)
		return
	if held != null:
		main.drop_item(self)


func _update_prompt() -> void:
	var lines := PackedStringArray()
	if target != null:
		if target_is_item:
			if held == null:
				lines.append("[%s] Pick up %s" % [grab_key, main.item_name(target.kind)])
		else:
			var g: String = target.grab_prompt(self)
			if g != "":
				lines.append("[%s] %s" % [grab_key, g])
			var w: String = target.work_prompt(self)
			if w != "":
				lines.append("[%s] hold: %s" % [work_key, w])
			var h: String = target.hint(self)
			if h != "":
				lines.append("(" + h + ")")
	if lines.is_empty() and held != null:
		lines.append("[%s] Put down" % grab_key)
	prompt.text = "\n".join(lines)
	var anchor: Vector3 = target.global_position if target != null else global_position
	prompt.global_position = anchor + Vector3(0, 2.4 + pid * 0.55, 0)
	marker.visible = target != null
	if target != null:
		marker.global_position = target.global_position + Vector3(0, 0.08, 0)
