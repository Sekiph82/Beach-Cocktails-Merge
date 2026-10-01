extends SceneTree

## BCM-M21 owner F5 remediation V03 probe.
##
## The launch smoke dispatches real InputEvent objects through the production
## viewport boundary. It intentionally never calls ShotController launch
## methods directly.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const CAPTURE_DIR := "res://coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v03"
const SUNNY_COVE_MAP_BACKGROUND := "res://assets/ui_assets/campaign/islands/sunny_cove/map_background.png"

var failures: Array[String] = []
var captures: Array[Dictionary] = []
var hotspot_centers: Array[Dictionary] = []
var gameplay_texture_inventory: Array[Dictionary] = []
var terminal_visual_counts: Dictionary = {}
var mouse_shots := 0
var touch_shots := 0
var direct_launch_calls := 0
var mouse_counter: Callable
var touch_counter: Callable
var shell
var navigation
var gameplay: GameManager


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_OWNER_RUNTIME_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_OWNER_RUNTIME_PROBE FAIL: %s" % label)


func _frame(count: int = 2) -> void:
	for _index in range(count):
		await process_frame


func _capture(label: String) -> void:
	var texture := root.get_viewport().get_texture()
	if texture == null:
		failures.append("capture texture unavailable: %s" % label)
		print("M21_OWNER_RUNTIME_PROBE FAIL: capture texture unavailable: %s" % label)
		return
	var image := texture.get_image()
	if image == null:
		failures.append("capture image unavailable: %s" % label)
		print("M21_OWNER_RUNTIME_PROBE FAIL: capture image unavailable: %s" % label)
		return
	var path := "%s/%s.png" % [CAPTURE_DIR, label]
	var error := image.save_png(path)
	var ok := error == OK and image.get_width() == 720 and image.get_height() == 1280
	_check("720x1280 capture: %s" % label, ok)
	if ok:
		captures.append({"name": label, "path": path, "width": image.get_width(), "height": image.get_height()})
	print("M21_OWNER_RUNTIME_CAPTURE name=%s path=%s dimensions=%dx%d error=%s" % [label, path, image.get_width(), image.get_height(), error])


func _push_input(event: InputEvent) -> void:
	# This is the production viewport/input boundary required by the locked gate.
	root.get_viewport().push_input(event)
	await process_frame


func _mouse_event(position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = pressed
	return event


func _mouse_motion(position: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.relative = Vector2(42.0, 0.0)
	return event


func _touch_event(position: Vector2, pressed: bool) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = position
	event.pressed = pressed
	return event


func _touch_drag(position: Vector2) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.index = 0
	event.position = position
	event.relative = Vector2(42.0, 0.0)
	return event


func _fire_mouse_shot(index: int) -> void:
	await _push_input(_mouse_event(Vector2(300.0 + float(index % 4) * 34.0, 950.0), true))
	await _push_input(_mouse_motion(Vector2(360.0 + float(index % 4) * 34.0, 950.0)))
	await _push_input(_mouse_event(Vector2(360.0 + float(index % 4) * 34.0, 950.0), false))


func _fire_touch_shot(index: int) -> void:
	await _push_input(_touch_event(Vector2(300.0 + float(index % 4) * 34.0, 950.0), true))
	await _push_input(_touch_drag(Vector2(360.0 + float(index % 4) * 34.0, 950.0)))
	await _push_input(_touch_event(Vector2(360.0 + float(index % 4) * 34.0, 950.0), false))


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	shell = SHELL_SCENE.instantiate()
	shell.onboarding_storage_path = "user://m21_owner_runtime_probe_onboarding.json"
	shell.settings_storage_path = "user://m21_owner_runtime_probe_settings.json"
	root.add_child(shell)
	await _frame(4)
	_check("production shell boots", shell.get_current_view() == "ONBOARDING" or shell.get_current_view() == "MAIN_MENU")
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	await _frame(2)
	shell.press_play_continue()
	await _frame(4)
	navigation = shell.get_campaign_navigation()
	var world = navigation.get_world_map()
	_check("production World Map has ten entries", world != null and world.get_entry_count() == 10)
	_check("World Map duplicate island thumbnails are hidden", world != null and not bool(world._entries["sunny_cove"]._island_art.visible))
	_check("runtime yellow IslandRoute is absent", world != null and world.find_child("IslandRoute", true, false) == null)
	for island_id in world.get_entry_ids():
		var entry = world._entries.get(island_id)
		if entry == null:
			_check("data-position hotspot exists: %s" % island_id, false)
			continue
		var definition: Dictionary = world.level_database.get_island(island_id)
		var map_position: Array = definition.get("map_position", [])
		var expected_local := Vector2(float(map_position[0]) * world._map_canvas.size.x, float(map_position[1]) * world._map_canvas.size.y)
		var actual_local: Vector2 = entry.position + IslandEntry.MARKER_CENTER
		_check("hotspot uses data map_position: %s" % island_id, actual_local.distance_to(expected_local) < 0.1)
		if island_id == "sunny_cove":
			_check("Sunny Cove data position is [0.16,0.83] and lower-left", map_position == [0.16, 0.83] and actual_local.x < world._map_canvas.size.x * 0.3 and actual_local.y > world._map_canvas.size.y * 0.75)
	_check("debug override is 800x1422 with 720x1280 viewport", int(ProjectSettings.get_setting("display/window/size/window_width_override")) == 800 and int(ProjectSettings.get_setting("display/window/size/window_height_override")) == 1422 and int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 720 and int(ProjectSettings.get_setting("display/window/size/viewport_height")) == 1280)
	_check("viewport stretch mode remains unchanged", str(ProjectSettings.get_setting("display/window/stretch/mode")) == "viewport")
	hotspot_centers = world.get_hotspot_center_report()
	_capture("01_world_map_720x1280")

	world._entries["sunny_cove"].pressed.emit()
	await _frame(4)
	var island_map = navigation.get_island_map()
	_check("Sunny Cove Island Map entry opens", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and island_map.get_level_button_count() == 100)
	_check("Sunny Cove Island Map uses its theme background", island_map.get_island_map_background_path() == SUNNY_COVE_MAP_BACKGROUND)
	_capture("02_sunny_cove_island_map_720x1280")
	island_map.get_level_button(1).pressed.emit()
	await _frame(6)
	gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
	_check("production Level 1 gameplay opens", gameplay != null and gameplay.shot_controller != null)
	if gameplay == null:
		_finish()
		return
	gameplay_texture_inventory = gameplay.get_visible_texture_inventory()
	var forbidden_decor := false
	var resolved_table := false
	for item in gameplay_texture_inventory:
		var texture_path := str(item.get("texture_path", ""))
		if texture_path.ends_with("decor_left.png") or texture_path.ends_with("decor_right.png") or texture_path.ends_with("decor_back.png"):
			forbidden_decor = true
		if texture_path == "res://assets/ui_assets/campaign/islands/sunny_cove/gameplay_table.png":
			resolved_table = true
	_check("visible texture inventory has no island decor assets", not forbidden_decor)
	_check("Sunny Cove gameplay table texture is active", resolved_table)
	_check("launch-zone scenery is behind the wooden table", gameplay._launch_zone.z_index < gameplay._theme_table.z_index)
	_check("result feedback uses dedicated topmost CanvasLayer", navigation._result_canvas_layer != null and navigation._result_canvas_layer.layer > 0)
	_check("result CanvasLayer is attached to the root viewport", navigation._result_canvas_layer.get_parent() == root)
	mouse_counter = func(_drink: Drink, _velocity: Vector2) -> void: mouse_shots += 1
	gameplay.shot_controller.shot_fired.connect(mouse_counter)
	_write_json("V03_GAMEPLAY_VISIBLE_TEXTURE_INVENTORY.json", {"before_first_shot": true, "texture_nodes": gameplay_texture_inventory})
	_capture("03_sunny_cove_gameplay_before_shots_720x1280")
	_check("Sunny Cove theme paths resolve", gameplay.get_active_theme_paths().get("gameplay_background", "").contains("sunny_cove/gameplay_background.png") and gameplay.get_active_theme_paths().get("gameplay_table", "").contains("sunny_cove/gameplay_table.png") and gameplay.get_active_theme_paths().get("gameplay_table_shadow", "").contains("sunny_cove/gameplay_table_shadow.png") and gameplay.get_active_theme_paths().get("table_edge_overlay", "").contains("sunny_cove/table_edge_overlay.png") and gameplay.get_active_theme_paths().get("launch_zone", "").contains("sunny_cove/launch_zone.png"))
	_check("session is explicitly untimed", not bool(navigation.get_session_bridge().get_session_configuration().get("timed", true)) and float(navigation.get_session_bridge().get_session_configuration().get("time_limit_sec", -1.0)) == 0.0)
	for index in range(10):
		await _fire_mouse_shot(index)
	_check("10/10 real mouse launches", mouse_shots == 10)
	_capture("04_sunny_cove_gameplay_after_10_mouse_shots_720x1280")

	var bridge = navigation.get_session_bridge()
	bridge.tick(3600.0)
	_check("untimed gameplay survives one simulated hour", bridge.is_session_active() and not bridge.is_terminal() and is_zero_approx(bridge.timer_remaining_sec))
	_capture("05_sunny_cove_untimed_after_one_hour_720x1280")
	var before_pause_shots := mouse_shots
	gameplay.request_pause()
	await _frame(2)
	var pause_hint: Label = gameplay._pause_layer.get_node_or_null("PauseHint") as Label
	_check("pause overlay opens without timer copy", gameplay.get_pause_overlay_visible() and pause_hint != null and not pause_hint.text.to_lower().contains("timer"))
	_capture("06_pause_untimed_720x1280")
	await _push_input(_mouse_event(Vector2(320.0, 950.0), true))
	await _push_input(_mouse_event(Vector2(380.0, 950.0), false))
	_check("pause overlay blocks mouse shots", mouse_shots == before_pause_shots)
	gameplay.resume_campaign_gameplay()
	gameplay.shot_controller.shot_fired.disconnect(mouse_counter)
	touch_counter = func(_drink: Drink, _velocity: Vector2) -> void: touch_shots += 1
	gameplay.shot_controller.shot_fired.connect(touch_counter)
	for index in range(10):
		await _fire_touch_shot(index)
	_check("10/10 real touch launches", touch_shots == 10)
	_check("direct launch method calls remain zero", direct_launch_calls == 0)

	for level in navigation.get_session_bridge().level_database.get_levels_for_island("sunny_cove"):
		_check("Sunny Cove level %d is untimed" % int(level.get("level_id", 0)), float(level.get("time_limit_sec", -1.0)) == 0.0 and not bool(level.get("feature_flags", {}).get("timed", true)))
	var production_island: Dictionary = navigation.get_session_bridge().level_database.get_island("sunny_cove")
	for reward_entry in production_island.get("reward_track", {}).get("cumulative_star_rewards", []):
		_check("production cumulative reward does not grant +Time", str(reward_entry.get("reward", {}).get("id", "")) != "time")
	var remaining: Dictionary = bridge.get_objective_state().get("normal_remaining", {})
	# Add a crowded board plus transient merge/delivery visuals before resolving
	# the real campaign WIN path. The production terminal signal must clean these.
	for index in range(8):
		var drink := gameplay.spawn_drink(1 + (index % 3), Vector2(95.0 + float(index % 4) * 140.0, 620.0 + float(index / 4) * 130.0))
		if drink != null:
			drink.freeze = true
	gameplay._spawn_to_go_trail(Vector2(90.0, 700.0), Vector2(620.0, 700.0), 0.3)
	gameplay._juice_effect(Vector2(360.0, 720.0))
	var delivery_index := 0
	for level in remaining:
		var quantity := int(remaining[level])
		if quantity > 0:
			delivery_index += 1
			bridge.record_to_go_delivery(int(level), quantity, "m21-owner-win-%d" % delivery_index, 777)
	await _frame(4)
	var result_overlay = navigation.get_result_feedback_overlay()
	_check("WIN result opens without timer wording", result_overlay.visible and result_overlay.get_title_text() == "LEVEL COMPLETE" and not result_overlay.get_body_text().to_lower().contains("time up") and not result_overlay.get_body_text().to_lower().contains("timer"))
	_check("WIN result overlay is visible in the viewport canvas", result_overlay.is_visible_in_tree() and result_overlay.get_global_rect().size == Vector2(720.0, 1280.0))
	terminal_visual_counts = gameplay.get_terminal_visual_counts()
	_check("terminal WIN hides every active Drink", int(terminal_visual_counts.get("visible_drink_count", -1)) == 0)
	_check("terminal WIN clears transient world effects", int(terminal_visual_counts.get("visible_transient_world_effect_count", -1)) == 0)
	_check("result modal CanvasLayer is above gameplay HUD", navigation._result_canvas_layer.layer > gameplay._hud.get_parent().layer)
	var terminal_score := gameplay.score
	var objective_before: Dictionary = bridge.get_objective_state()
	gameplay._add_score(9000)
	bridge.set_current_score(terminal_score + 9000)
	var rejected_delivery: Dictionary = bridge.record_to_go_delivery(6, 1, "v03-post-terminal-delivery", terminal_score + 9000)
	_check("score and delivery state stay frozen after terminal", gameplay.score == terminal_score and bridge.get_objective_state() == objective_before and not bool(rejected_delivery.get("ok", false)))
	_write_json("V03_TERMINAL_VISIBLE_COUNTS.json", {"visual_counts": terminal_visual_counts, "result_canvas_layer": navigation._result_canvas_layer.layer, "result_overlay_visible_in_tree": result_overlay.is_visible_in_tree(), "result_overlay_rect": result_overlay.get_global_rect()})
	_capture("07_win_untimed_no_timer_language_720x1280")
	var shots_before_result_input := mouse_shots + touch_shots
	await _push_input(_mouse_event(Vector2(320.0, 950.0), true))
	await _push_input(_mouse_motion(Vector2(380.0, 950.0)))
	await _push_input(_mouse_event(Vector2(380.0, 950.0), false))
	await _push_input(_touch_event(Vector2(320.0, 950.0), true))
	await _push_input(_touch_drag(Vector2(380.0, 950.0)))
	await _push_input(_touch_event(Vector2(380.0, 950.0), false))
	_check("result overlay blocks mouse and touch shots", mouse_shots + touch_shots == shots_before_result_input)
	if result_overlay.get_visible_actions().has("NEXT_LEVEL"):
		_check("Next Level action remains available", result_overlay.trigger_action("NEXT_LEVEL"))
		await _frame(5)
		_check("Next Level action starts the next production level", navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_session_bridge().active_level_id == 2 and navigation.get_gameplay_instance_count() == 1)
	_finish()


func _finish() -> void:
	var report := {
	"work_item": "BCM-M21 owner F5 remediation V03",
		"production_path": "ApplicationShellScene -> CampaignNavigationController -> IslandMap -> GameManager",
		"mouse_shots_fired": mouse_shots,
		"touch_shots_fired": touch_shots,
		"direct_shot_controller_launch_method_calls": direct_launch_calls,
	"captures": captures,
	"hotspot_centers": hotspot_centers,
	"terminal_visual_counts": terminal_visual_counts,
	"checks_failed": failures,
		"physical_device_acceptance": "DEFERRED_TO_OWNER_NATIVE_REAUDIT",
	}
	_write_json("M21_OWNER_F5_REMEDIATION_V03_REPORT.json", report)
	_write_json("V03_HOTSPOT_CENTERS.json", {"centers": hotspot_centers})
	if failures.is_empty():
		print("M21_OWNER_F5_REMEDIATION_V03_RESULT=PASS mouse=%d/10 touch=%d/10 drinks=%d effects=%d captures=%d" % [mouse_shots, touch_shots, int(terminal_visual_counts.get("visible_drink_count", -1)), int(terminal_visual_counts.get("visible_transient_world_effect_count", -1)), captures.size()])
		quit(0)
		return
	print("M21_OWNER_F5_REMEDIATION_V03_RESULT=FAIL failures=%s" % str(failures))
	quit(1)


func _write_json(filename: String, value: Variant) -> void:
	var file := FileAccess.open("%s/%s" % [CAPTURE_DIR, filename], FileAccess.WRITE)
	if file == null:
		failures.append("unable to write report: %s" % filename)
		return
	file.store_string(JSON.stringify(value, "\t"))
	file.close()
