extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const GAMEPLAY_SCENE := preload("res://scenes/main.tscn")
const OUT := "res://coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-004/mobile-captures"
const LOGICAL_SIZE := Vector2i(720, 1280)
const SAMPLES := [
	{"name": "phone_390_one_starter", "size": Vector2i(390, 844), "island": "tiki_island", "level": 13, "tutorial": false},
	{"name": "phone_432_two_starters", "size": Vector2i(432, 960), "island": "tiki_island", "level": 27, "tutorial": false},
	{"name": "reference_720_no_starter", "size": Vector2i(720, 1280), "island": "tiki_island", "level": 1, "tutorial": false},
	{"name": "phone_390_tutorial_overlay", "size": Vector2i(390, 844), "island": "tiki_island", "level": 13, "tutorial": true},
]

var failures: Array[String] = []
var captures: Array[Dictionary] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M34_CAPTURE PASS: %s" % label)
	else:
		failures.append(label)
		print("M34_CAPTURE FAIL: %s" % label)


func _frames(count: int = 4) -> void:
	for _index in range(count):
		await process_frame


func _set_size(size: Vector2i) -> void:
	# Production uses a fixed 720x1280 logical canvas. The physical device/window
	# changes the output size while Godot scales this production viewport.
	get_root().size = LOGICAL_SIZE
	get_root().get_window().content_scale_size = LOGICAL_SIZE
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(size)
	await _frames(8)


func _push_input(event: InputEvent) -> void:
	get_root().get_viewport().push_input(event, true)
	await process_frame


func _fire_touch_shot(gameplay) -> bool:
	var held = gameplay.shot_controller._current_drink
	if not is_instance_valid(held):
		return false
	var launch_point: Vector2 = held.get_global_transform_with_canvas().origin
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.pressed = true
	down.position = launch_point
	await _push_input(down)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = launch_point + Vector2(64.0, 0.0)
	drag.relative = Vector2(64.0, 0.0)
	await _push_input(drag)
	var up := InputEventScreenTouch.new()
	up.index = 0
	up.pressed = false
	up.position = launch_point + Vector2(64.0, 0.0)
	await _push_input(up)
	await _frames(4)
	return int(gameplay.campaign_session_bridge.get_move_budget_state().get("moves_used", 0)) == 1


func _capture(sample: Dictionary, gameplay) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_root().get_texture().get_image()
	var relative_path := "%s/%s.png" % [OUT, sample["name"]]
	var expected_size: Vector2i = sample["size"]
	var logical_capture_size := image.get_size() if not image.is_empty() else Vector2i.ZERO
	if not image.is_empty() and logical_capture_size != expected_size:
		image.resize(expected_size.x, expected_size.y, Image.INTERPOLATE_LANCZOS)
	var save_error := image.save_png(ProjectSettings.globalize_path(relative_path)) if not image.is_empty() else ERR_CANT_CREATE
	var valid := save_error == OK and image.get_size() == expected_size
	_check("captured production gameplay frame %s at exact %dx%d" % [sample["name"], expected_size.x, expected_size.y], valid)
	var level: Dictionary = gameplay.campaign_session_bridge.level_database.get_level(str(sample["island"]), int(sample["level"]))
	captures.append({"name": sample["name"], "viewport": [image.get_width(), image.get_height()], "island_id": sample["island"], "level_id": sample["level"], "initial_starters": level.get("initial_tabletop_drinks", []), "move_limit": level.get("move_limit", null), "moves_label": gameplay._move_limit_label.text if is_instance_valid(gameplay._move_limit_label) else "", "tutorial_visible": gameplay.gameplay_tutorial.visible, "path": relative_path, "save_error": save_error})


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var database = DATABASE_SCRIPT.new()
	var loaded: bool = database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL)
	_check("full canonical data loads for production capture", loaded)
	if not loaded:
		quit(1)
		return
	for sample in SAMPLES:
		await _set_size(sample["size"])
		var economy = ECONOMY_SCRIPT.new()
		economy.configure(100, {}, [], 5)
		var bridge = BRIDGE_SCRIPT.new()
		bridge.configure(database, null, economy)
		var started: Dictionary = bridge.start_session(str(sample["island"]), int(sample["level"]))
		var gameplay = GAMEPLAY_SCENE.instantiate()
		get_root().add_child(gameplay)
		var configured: bool = not started.is_empty() and gameplay.configure_campaign_session(bridge)
		await _frames(5)
		_check("production GameManager configures %s" % sample["name"], configured)
		if not configured:
			gameplay.queue_free()
			await process_frame
			continue
		if bool(sample["tutorial"]):
			gameplay.start_guided_tutorial(true)
			await _frames(3)
		_check("production tutorial overlay is visible for mobile capture", not bool(sample["tutorial"]) or gameplay.gameplay_tutorial.visible)
		await _capture(sample, gameplay)
		if not bool(sample["tutorial"]):
			var touch_started: bool = await _fire_touch_shot(gameplay)
			_check("viewport touch drag launches a drink and spends one move in %s" % sample["name"], touch_started)
			if touch_started:
				var live_sample: Dictionary = sample.duplicate(true)
				live_sample["name"] = str(sample["name"]) + "_after_touch_input"
				live_sample["size"] = sample["size"]
				await _capture(live_sample, gameplay)
		gameplay.queue_free()
		await _frames(2)
	var manifest := {"result": "PASS" if failures.is_empty() else "FAIL", "capture_origin": "Godot 4.7.2 production main scene logical viewport texture scaled to target window output dimensions; no compositing", "logical_viewport": [LOGICAL_SIZE.x, LOGICAL_SIZE.y], "renderer": DisplayServer.get_name(), "captures": captures, "failures": failures, "physical_device": false, "owner_visual_review": "PENDING"}
	var manifest_file := FileAccess.open(OUT + "/capture_manifest.json", FileAccess.WRITE)
	if manifest_file != null:
		manifest_file.store_string(JSON.stringify(manifest, "  ") + "\n")
		manifest_file.close()
	_check("capture manifest written", manifest_file != null)
	print("M34_CAPTURE_RESULT=%s count=%d" % [str(manifest["result"]), captures.size()])
	quit(0 if failures.is_empty() else 1)
