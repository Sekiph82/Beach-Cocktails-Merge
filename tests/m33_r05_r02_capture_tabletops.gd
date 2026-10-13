extends SceneTree

const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")
const GAMEPLAY_SCENE := preload("res://scenes/main.tscn")
const ISLANDS := ["tiki_island", "azure_bay", "coconut_beach", "sunset_island", "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island"]
const OUT := "res://coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R05-R02/screenshots"

var database
var failures: Array[String] = []
var captures: Array[Dictionary] = []
var capture_viewport: SubViewport


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	if err != OK and err != ERR_ALREADY_EXISTS:
		_failures_append("cannot create screenshot evidence directory")
		quit(1)
		return
	await process_frame
	await process_frame
	_setup_capture_viewport()
	database = DATABASE_SCRIPT.new()
	if not database.load_canonical(DATABASE_SCRIPT.DEFAULT_ISLANDS_PATH, DATABASE_SCRIPT.DEFAULT_LEVEL_PATHS, DATABASE_SCRIPT.ValidationMode.FULL):
		_failures_append("full campaign database failed to load")
		quit(1)
		return
	var size := DisplayServer.window_get_size()
	await _capture_set(int(size.x), int(size.y))
	var manifest := {"result": "PASS" if failures.is_empty() else "FAIL", "capture_origin": "Godot 4.7.2 production scene rendered in a 720x1280 SubViewport and scaled by SubViewportContainer into the exact client viewport; root viewport texture saved directly; no post-capture resizing or compositing", "captures": captures, "failures": failures}
	var file := FileAccess.open(OUT + "/capture_manifest.json", FileAccess.WRITE)
	if file == null:
		push_error("R05 capture manifest could not be written")
		quit(1)
		return
	file.store_string(JSON.stringify(manifest, "  ") + "\n")
	file.close()
	print("M33_R05_R02_CAPTURE_RESULT=%s count=%d" % [str(manifest["result"]), captures.size()])
	quit(0 if failures.is_empty() else 1)


func _capture_set(width: int, height: int) -> void:
	await process_frame
	await process_frame
	for island_id in ISLANDS:
		var levels: Array[Dictionary] = database.get_levels_for_island(island_id)
		var empty_level := _find_empty_level(levels)
		var component_level := _find_stable_populated_level(levels)
		if empty_level.is_empty() or component_level.is_empty():
			_failures_append("%s lacks an empty or stable component-start sample" % island_id)
			continue
		await _capture_level(island_id, empty_level, "empty", width, height)
		await _capture_level(island_id, component_level, "populated", width, height)
	var contrast_island := "tiki_island"
	var contrast: Dictionary = _find_multi_drink_level(database.get_levels_for_island(contrast_island))
	if not contrast.is_empty():
		await _capture_level(contrast_island, contrast, "contrast_two_drinks", width, height)
	else:
		_failures_append("no generated multi-drink contrast level exists")


func _capture_level(island_id: String, level: Dictionary, kind: String, width: int, height: int) -> void:
	var bridge = BRIDGE_SCRIPT.new()
	bridge.configure(database, null)
	if bridge.start_session(island_id, int(level["level_id"])).is_empty():
		_failures_append("could not start %s/%s" % [island_id, kind])
		return
	var gameplay = GAMEPLAY_SCENE.instantiate()
	capture_viewport.add_child(gameplay)
	if not gameplay.configure_campaign_session(bridge):
		_failures_append("production scene failed to configure %s/%s" % [island_id, kind])
		gameplay.queue_free()
		await process_frame
		return
	for _frame in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	var drink_telemetry: Array[Dictionary] = []
	for node in gameplay.world.get_children():
		if node is RigidBody2D and node.get("level") != null:
			drink_telemetry.append(node.get_visual_qualification_telemetry())
	var image_width := width
	var image_height := height
	var relative_dir := "%s/%dx%d" % [OUT, image_width, image_height]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(relative_dir))
	var relative_path := "%s/%s_L%03d_%s.png" % [relative_dir, island_id, int(level["level_id"]), kind]
	var image: Image = get_root().get_texture().get_image()
	var save_error := image.save_png(ProjectSettings.globalize_path(relative_path))
	if save_error != OK or image.get_width() != width or image.get_height() != height:
		_failures_append("PNG write failed for %s/%s" % [island_id, kind])
	else:
		captures.append({"island_id": island_id, "level_id": int(level["level_id"]), "kind": kind, "viewport": [image_width, image_height], "path": relative_path, "initial_drinks": level.get("initial_tabletop_drinks", []), "drink_telemetry": drink_telemetry})
	gameplay.queue_free()
	await process_frame
	await process_frame


func _find_empty_level(levels: Array[Dictionary]) -> Dictionary:
	for level in levels:
		if int(level.get("level_id", 0)) < 100 and level.get("initial_tabletop_drinks", []).is_empty():
			return level
	return {}


func _find_stable_populated_level(levels: Array[Dictionary]) -> Dictionary:
	for level in levels:
		if int(level.get("level_id", 0)) >= 100:
			continue
		var drinks: Array = level.get("initial_tabletop_drinks", [])
		if drinks.size() != 1:
			continue
		var first_target := 13
		for order in level.get("orders", []):
			first_target = mini(first_target, int(order.get("cocktail_level", 0)))
		var source_level := int(drinks[0].get("cocktail_level", 0))
		var has_next_target := false
		for order in level.get("orders", []):
			if int(order.get("cocktail_level", 0)) == source_level + 1:
				has_next_target = true
		if source_level != first_target and (targets_has_level(level, source_level) or has_next_target):
			return level
	return {}


func targets_has_level(level: Dictionary, cocktail_level: int) -> bool:
	for order in level.get("orders", []):
		if int(order.get("cocktail_level", 0)) == cocktail_level:
			return true
	return false


func _find_multi_drink_level(levels: Array[Dictionary]) -> Dictionary:
	for level in levels:
		if int(level.get("level_id", 0)) < 100 and level.get("initial_tabletop_drinks", []).size() >= 2:
			return level
	return {}


func _failures_append(message: String) -> void:
	failures.append(message)
	push_error(message)


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
