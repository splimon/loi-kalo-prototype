extends SceneTree
## Headless smoke test: godot --headless --path . -s tests/selftest.gd
## Drives every station through one full poi / lūʻau / paʻiʻai chain and the flood event.

var fails := 0


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  ok   ", msg)
	else:
		print("  FAIL ", msg)
		fails += 1


func find(m, kind: String):
	for s in m.stations:
		if s.kind == kind:
			return s
	return null


func work_until_done(s, p, max_t := 10.0) -> bool:
	var tt := 0.0
	while tt < max_t:
		if s.work(0.1, p):
			return true
		tt += 0.1
	return false


func _initialize() -> void:
	var m = load("res://main.tscn").instantiate()
	root.add_child(m)
	await process_frame
	await process_frame
	m._start()
	var p = m.players[0]
	print("Selftest: start")

	# --- harvest a mature kalo
	var plot = null
	for s in m.stations:
		if s.kind == "plot" and s.planted and s.growth >= 3.0:
			plot = s
			break
	check(plot != null, "a mature kalo exists at start")
	var items_before: int = m.items.size()
	check(work_until_done(plot, p), "harvest kalo")
	check(p.held_kind() == "kalo", "holding raw kalo")
	check(m.items.size() == items_before + 1, "huli dropped beside harvested plant")

	# --- raw kalo refused by papa
	var papa = find(m, "papa")
	papa.grab(p)
	check(p.held_kind() == "kalo", "papa refuses raw kalo")

	# --- cook in the imu
	var imu = find(m, "imu")
	check(imu.grab(p), "put kalo in imu")
	imu.tick(13.0)
	check(imu.grab(p) and p.held_kind() == "kalo_cooked", "take cooked kalo from imu")

	# --- pound
	check(papa.grab(p), "put cooked kalo on papa")
	var wai_before: int = m.wai
	check(work_until_done(papa, p), "pound kalo")
	check(m.wai == wai_before - 1, "pounding used 1 wai")
	check(papa.grab(p) and p.held_kind() == "paiai", "take paʻiʻai")

	# --- poi at the ʻumeke
	var umeke = find(m, "umeke")
	check(umeke.grab(p), "put paʻiʻai in ʻumeke")
	m.wai = 2
	check(work_until_done(umeke, p), "mix poi")
	check(umeke.grab(p) and p.held_kind() == "poi", "take poi")
	var aha = find(m, "aha")
	m.orders = [{"kind": "poi", "left": 100.0}]
	m._rebuild_orders()
	check(aha.grab(p) and m.score > 0 and p.held == null, "serve poi -> score %d" % m.score)

	# --- lūʻau from leaves
	var leafy = null
	for s in m.stations:
		if s.kind == "plot" and s.planted and s.growth >= 2.0 and s.growth < 3.0:
			leafy = s
	if leafy == null:
		leafy = plot
		leafy.planted = true
		leafy.growth = 2.5
	check(work_until_done(leafy, p) and p.held_kind() == "lau", "pick lau")
	imu.grab(p)
	imu.tick(13.0)
	check(imu.grab(p) and p.held_kind() == "luau", "cook lūʻau")
	m.orders = [{"kind": "luau", "left": 100.0}]
	check(aha.grab(p), "serve lūʻau")

	# --- wrapped paʻiʻai
	p.give("paiai")
	check(find(m, "ki").grab(p) and p.held_kind() == "paiai_wrapped", "wrap paʻiʻai at kī")
	p.consume()

	# --- water: ipu fill + pour
	p.give("ipu_empty")
	var dip = find(m, "kahawai")
	check(dip.grab(p) and p.held_kind() == "ipu_full", "fill ipu at kahawai")
	m.wai = 0
	check(find(m, "wai_stand").grab(p) and m.wai == 3, "pour wai")
	p.consume()

	# --- replant a huli
	plot.planted = false
	p.give("huli")
	check(plot.grab(p) and plot.planted, "plant huli")

	# --- gate + take all
	var gate = m.gate_station
	m.set_gate_all(true)
	for i in 60:
		m._update_sim(0.1)
	check(m.reach_level < 0.3, "taking all water dries the stream reach")
	p.give("ipu_empty")
	check(dip.grab(p) and p.held_kind() == "ipu_empty", "can't fill ipu from dried stream")
	p.consume()
	m.set_gate_all(false)

	# --- clog blocks flow
	m._spawn_clog()
	m._update_sim(0.1)
	check(not m.loi_flow[0], "ʻōpala blocks water")
	check(work_until_done(m.clogs[0], p), "clear ʻōpala")
	m._update_sim(0.1)
	check(m.loi_flow[0] or m.clogs.size() > 0, "water flows again")
	while not m.clogs.is_empty():
		m.remove_clog(m.clogs[0])

	# --- flood with gate open -> breach
	m.t = 95.1
	m._update_sim(0.1)
	check(m.flood_state == "warning", "flood warning triggers")
	for i in 130:
		m._update_sim(0.1)
	check(m.breached, "flood with open gate breaks the kuāuna")
	check(not m.loi_flow[0], "breach drains the loʻi")
	gate.grab(p)
	check(work_until_done(m.breach_station, p), "rebuild kuāuna (gate closed)")
	for i in 200:
		m._update_sim(0.1)
	while not m.clogs.is_empty():
		m.remove_clog(m.clogs[0])

	check(not m.breached, "kuāuna stays repaired with gate closed")
	gate.grab(p)
	check(m.gate_open, "reopen poʻo wai after flood")
	# --- second flood, gate closed -> safe
	m.t = 185.1
	m._update_sim(0.1)
	gate.grab(p)
	check(not m.gate_open, "close poʻo wai")
	for i in 130:
		m._update_sim(0.1)
	check(not m.breached, "closed gate protects kuāuna")

	# --- run the real frame loop for a while (2 players, time compressed)
	m._spawn_player(1)
	for i in 400:
		m._process(0.05)
		await process_frame
	m.t = 239.99
	m._process(0.05)
	check(m.state == "end", "level ends")
	print("Selftest finished: %d failure(s)" % fails)
	quit(1 if fails > 0 else 0)
