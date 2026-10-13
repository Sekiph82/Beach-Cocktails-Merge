extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const GAMEPLAY_SCENE := preload("res://scenes/main.tscn")
const OUT := "res://coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R05-R02/comparison"

var failures: Array[String] = []
var capture_viewport: SubViewport


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M33_R05_R02 PASS: %s" % label)
	else:
		failures.append(label)
		push_error("M33_R05_R02 FAIL: %s" % label)


func _run() -> void:
	await process_frame
	await process_frame
	_setup_capture_viewport()
	var database = DATABASE_SCRIPT.new()
	var database_loaded: bool = database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL)
	if not database_loaded:
		print("M33_R05_R02_DATABASE_ERROR=%s" % database.get_last_error())
	_check("campaign loads with full schema and manifest validation", database_loaded)
	if not failures.is_empty():
		quit(1)
		return
	var level: Dictionary = database.get_level("azure_bay", 8)
	_check("Azure Bay L8 provides a real L6 preplaced starter sample", not level.is_empty() and level.get("initial_tabletop_drinks", []).size() == 1 and int(level["initial_tabletop_drinks"][0].get("cocktail_level", 0)) == 6)
	if failures.size() > 0:
		quit(1)
		return
	var bridge = BRIDGE_SCRIPT.new()
	bridge.configure(database, null)
	_check("controlled comparison session starts", not bridge.start_session("azure_bay", 8).is_empty())
	var gameplay = GAMEPLAY_SCENE.instantiate()
	capture_viewport.add_child(gameplay)
	_check("production gameplay scene configures for comparison", gameplay.configure_campaign_session(bridge))
	for _frame in 3:
		await process_frame
	var starters: Array[Drink] = []
	for child in gameplay.world.get_children():
		if child is RigidBody2D and child.get("level") != null and child.motion_state != child.MotionState.HELD:
			starters.append(child)
	_check("one real preplaced settled L6 starter exists", starters.size() == 1 and starters[0].level == 6)
	if starters.size() != 1:
		await _dispose(gameplay)
		quit(1)
		return
	var starter: Drink = starters[0]
	var board_size: Vector2 = gameplay.get_board_size()
	var paired_x := board_size.x * (0.72 if starter.position.x < board_size.x * 0.5 else 0.28)
	var ordinary: Drink = gameplay.spawn_drink(starter.level, Vector2(paired_x, starter.position.y), false)
	_check("ordinary settled comparison drink uses the same level and tabletop depth", ordinary != null and ordinary.level == starter.level and is_equal_approx(ordinary.position.y, starter.position.y))
	if ordinary == null:
		await _dispose(gameplay)
		quit(1)
		return
	for _frame in 3:
		await process_frame
	var starter_data: Dictionary = starter.get_visual_qualification_telemetry()
	var ordinary_data: Dictionary = ordinary.get_visual_qualification_telemetry()
	var exact: bool = starter_data["source_collision_radius"] == ordinary_data["source_collision_radius"] and starter_data["source_collision_diameter"] == ordinary_data["source_collision_diameter"]
	for key in ["sprite_local_scale", "visual_root_scale", "world_render_scale", "shadow_world_size"]:
		exact = exact and _vectors_equal(starter_data[key], ordinary_data[key])
	var starter_bounds: Array = starter_data["visible_bounds_canvas"]
	var ordinary_bounds: Array = ordinary_data["visible_bounds_canvas"]
	exact = exact and absf(float(starter_bounds[2]) - float(ordinary_bounds[2])) <= 0.01 and absf(float(starter_bounds[3]) - float(ordinary_bounds[3])) <= 0.01
	_check("preplaced and ordinary same-level drinks have equal world scale, alpha bounds, shadow and source collision", exact)
	var viewport_size := DisplayServer.window_get_size()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var capture_path := "%s/same_level_%dx%d.png" % [OUT, int(viewport_size.x), int(viewport_size.y)]
	await RenderingServer.frame_post_draw
	var image: Image = get_root().get_texture().get_image()
	var save_result := image.save_png(ProjectSettings.globalize_path(capture_path))
	_check("controlled same-level frame captured directly from the scaled Godot viewport", save_result == OK and Vector2i(image.get_width(), image.get_height()) == viewport_size)
	var record := {"result": "PASS" if failures.is_empty() else "FAIL", "comparison": "preplaced versus ordinary production Drink at same level and tabletop depth", "viewport": [int(viewport_size.x), int(viewport_size.y)], "island_id": "azure_bay", "level_id": 8, "cocktail_level": 6, "preplaced": starter_data, "ordinary_settled": ordinary_data, "scale_ratios": {"sprite": _ratio(starter_data["sprite_local_scale"], ordinary_data["sprite_local_scale"]), "render": _ratio(starter_data["world_render_scale"], ordinary_data["world_render_scale"]), "shadow": _ratio(starter_data["shadow_world_size"], ordinary_data["shadow_world_size"]), "alpha_bounds": _ratio([starter_bounds[2], starter_bounds[3]], [ordinary_bounds[2], ordinary_bounds[3]])}, "screenshot": capture_path, "failures": failures}
	var output := FileAccess.open("%s/same_level_%dx%d.json" % [OUT, int(viewport_size.x), int(viewport_size.y)], FileAccess.WRITE)
	if output != null:
		output.store_string(JSON.stringify(record, "  ") + "\n")
		output.close()
	else:
		_check("comparison telemetry JSON can be written", false)
	await _dispose(gameplay)
	print("M33_R05_R02_SCALE_COMPARISON_RESULT=%s" % ("PASS" if failures.is_empty() else "FAIL"))
	quit(0 if failures.is_empty() else 1)


func _vectors_equal(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for index in left.size():
		if absf(float(left[index]) - float(right[index])) > 0.001:
			return false
	return true


func _ratio(left: Array, right: Array) -> Array[float]:
	var result: Array[float] = []
	for index in mini(left.size(), right.size()):
		var denominator := float(right[index])
		result.append(float(left[index]) / denominator if not is_zero_approx(denominator) else 0.0)
	return result


func _dispose(gameplay: Node) -> void:
	if is_instance_valid(gameplay):
		gameplay.queue_free()
		await process_frame
		await process_frame


func _setup_capture_viewport() -> void:
	var container := SubViewportContainer.new()
	container.name = "R02CaptureContainer"
	container.position = Vector2.ZERO
	container.size = Vector2(720.0, 1280.0)
	container.scale = Vector2(float(get_root().size.x) / 720.0, float(get_root().size.y) / 1280.0)
	container.stretch = false
	get_root().add_child(container)
	capture_viewport = SubViewport.new()
	capture_viewport.name = "ProductionGameplayViewport"
	capture_viewport.size = Vector2i(720, 1280)
	capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(capture_viewport)
