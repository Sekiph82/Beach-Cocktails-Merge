extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const GAMEPLAY_SCENE := preload("res://scenes/main.tscn")
const OUT := "res://coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R03/owner-review"
const LOGICAL_SIZE := Vector2i(720, 1280)
const TARGETS := [Vector2i(390, 844), Vector2i(432, 960)]

var failures: Array[String] = []
var captures: Array[Dictionary] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_R03_CAPTURE PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_R03_CAPTURE FAIL: %s" % label)


func _frames(count: int = 5) -> void:
	for _index in range(count):
		await process_frame


func _set_size(size: Vector2i) -> void:
	get_root().size = LOGICAL_SIZE
	get_root().get_window().content_scale_size = LOGICAL_SIZE
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(size)
	await _frames(8)


func _new_game(database, size: Vector2i, tutorial: bool = false):
	await _set_size(size)
	var economy = ECONOMY_SCRIPT.new()
	economy.configure(100, {}, [], 5)
	var bridge = BRIDGE_SCRIPT.new()
	bridge.configure(database, null, economy)
	var started: Dictionary = bridge.start_session("tiki_island", 27)
	var gameplay = GAMEPLAY_SCENE.instantiate()
	get_root().add_child(gameplay)
	var configured: bool = not started.is_empty() and gameplay.configure_campaign_session(bridge)
	await _frames(8)
	_check("production gameplay scene configured at %dx%d" % [size.x, size.y], configured)
	if tutorial and configured:
		gameplay.start_guided_tutorial(true)
		await _frames(4)
	_check("tutorial state is visible at %dx%d" % [size.x, size.y], not tutorial or gameplay.gameplay_tutorial.visible)
	return {"gameplay": gameplay, "bridge": bridge, "configured": configured}


func _capture(name: String, size: Vector2i, gameplay, bridge, state_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_root().get_texture().get_image()
	if not image.is_empty() and image.get_size() != size:
		image.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	var path := "%s/%s.png" % [OUT, name]
	var save_error := image.save_png(ProjectSettings.globalize_path(path)) if not image.is_empty() else ERR_CANT_CREATE
	var state: Dictionary = bridge.get_move_budget_state()
	var valid := save_error == OK and image.get_size() == size
	_check("saved %s production frame at exact %dx%d" % [name, size.x, size.y], valid)
	captures.append({"name": name, "path": path, "viewport": [size.x, size.y], "image_source_size": [image.get_width(), image.get_height()], "state": state_name, "moves_label": gameplay._move_limit_label.text if is_instance_valid(gameplay._move_limit_label) else "", "moves_remaining": state.get("moves_remaining", null), "tutorial_visible": gameplay.gameplay_tutorial.visible, "physical_device": false})


func _touch_shot(gameplay, bridge) -> bool:
	var held = gameplay.shot_controller._current_drink
	if not is_instance_valid(held):
		return false
	var pos: Vector2 = held.get_global_transform_with_canvas().origin
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = pos
	get_root().get_viewport().push_input(down, true)
	await process_frame
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = pos + Vector2(64, 0)
	drag.relative = Vector2(64, 0)
	get_root().get_viewport().push_input(drag, true)
	await process_frame
	var up := InputEventScreenTouch.new()
	up.index = 0
	up.pressed = false
	up.position = pos + Vector2(64, 0)
	get_root().get_viewport().push_input(up, true)
	await _frames(8)
	return int(bridge.get_move_budget_state().get("moves_used", 0)) == 1


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var database = DATABASE_SCRIPT.new()
	var loaded: bool = database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL)
	_check("canonical campaign data loaded", loaded)
	if not loaded:
		quit(1)
		return
	for size in TARGETS:
		var prefix := "%dx%d" % [size.x, size.y]
		var game: Dictionary = await _new_game(database, size)
		if game.configured:
			await _capture("%s_before_touch" % prefix, size, game.gameplay, game.bridge, "before_touch")
			var touched: bool = await _touch_shot(game.gameplay, game.bridge)
			_check("real viewport touch drag committed a shot at %s" % prefix, touched)
			if touched:
				await _capture("%s_after_touch" % prefix, size, game.gameplay, game.bridge, "after_touch")
		game.gameplay.queue_free()
		await process_frame
		var low: Dictionary = await _new_game(database, size)
		if low.configured:
			var limit := int(low.bridge.get_move_budget_state().get("move_limit", 0))
			var valid_low := limit > 1
			for n in range(maxi(0, limit - 1)):
				var result: Dictionary = low.bridge.record_committed_shot("r03-low-moves-%s-%d" % [prefix, n])
				valid_low = valid_low and bool(result.get("ok", false))
			_check("low-moves state leaves one move at %s" % prefix, valid_low and int(low.bridge.get_move_budget_state().get("moves_remaining", -1)) == 1)
			await _frames(2)
			await _capture("%s_low_moves" % prefix, size, low.gameplay, low.bridge, "low_moves")
		low.gameplay.queue_free()
		await process_frame
		var tutorial: Dictionary = await _new_game(database, size, true)
		if tutorial.configured:
			await _capture("%s_tutorial" % prefix, size, tutorial.gameplay, tutorial.bridge, "tutorial")
		tutorial.gameplay.queue_free()
		await process_frame
	var manifest := {"result": "PASS" if failures.is_empty() else "FAIL", "capture_origin": "Godot 4.7.2 production main scene at the requested desktop window outputs; no image compositing", "logical_viewport": [LOGICAL_SIZE.x, LOGICAL_SIZE.y], "renderer": DisplayServer.get_name(), "captures": captures, "failures": failures, "physical_device": false, "owner_visual_review": "PENDING"}
	var file := FileAccess.open(OUT + "/capture_manifest.json", FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(manifest, "  ") + "\n")
	_check("owner-review capture manifest saved", file != null)
	if file != null:
		file.close()
	print("M34_R03_CAPTURE_RESULT=%s count=%d" % [str(manifest.result), captures.size()])
	quit(0 if failures.is_empty() else 1)
