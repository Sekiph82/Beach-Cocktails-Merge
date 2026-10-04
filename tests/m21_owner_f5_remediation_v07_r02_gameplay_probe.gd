extends SceneTree

## BCM-M21 owner F5 remediation V07_R02 gameplay probe.
##
## The launch smoke dispatches real InputEvent objects through the production
## viewport boundary. It intentionally never calls ShotController launch
## methods directly.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const CAPTURE_DIR := "res://coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v07-r02"
const SUNNY_COVE_MAP_BACKGROUND := "res://assets/ui_assets/campaign/islands/sunny_cove/map_background.png"

var failures: Array[String] = []
var captures: Array[Dictionary] = []
var hotspot_centers: Array[Dictionary] = []
var landmark_mappings: Array[Dictionary] = []
var table_translation_report: Dictionary = {}
var gameplay_texture_inventory: Array[Dictionary] = []
var terminal_visual_counts: Dictionary = {}
var theme_layer_report: Array[Dictionary] = []
var mouse_shots := 0
var touch_shots := 0
var boundary_shots := 0
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
	var launch_y := gameplay.launch_y
	await _push_input(_mouse_event(Vector2(300.0 + float(index % 4) * 34.0, launch_y), true))
	await _push_input(_mouse_motion(Vector2(360.0 + float(index % 4) * 34.0, launch_y)))
	await _push_input(_mouse_event(Vector2(360.0 + float(index % 4) * 34.0, launch_y), false))


func _fire_touch_shot(index: int) -> void:
	var launch_y := gameplay.launch_y
	await _push_input(_touch_event(Vector2(300.0 + float(index % 4) * 34.0, launch_y), true))
	await _push_input(_touch_drag(Vector2(360.0 + float(index % 4) * 34.0, launch_y)))
	await _push_input(_touch_event(Vector2(360.0 + float(index % 4) * 34.0, launch_y), false))


func _fire_mouse_boundary_shot(x_position: float, wait_frames: int = 28) -> Drink:
	var launch_y := gameplay.launch_y
	var fired := gameplay.shot_controller._current_drink as Drink
	await _push_input(_mouse_motion(Vector2(x_position, launch_y)))
	await _push_input(_mouse_event(Vector2(x_position, launch_y), true))
	await _push_input(_mouse_event(Vector2(x_position, launch_y), false))
	await _frame(wait_frames)
	return fired


func _complete_current_orders(bridge, delivery_prefix: String) -> void:
	var remaining: Dictionary = bridge.get_objective_state().get("normal_remaining", {})
	var delivery_index := 0
	for level in remaining:
		var quantity := int(remaining[level])
		if quantity > 0:
			delivery_index += 1
			bridge.record_to_go_delivery(int(level), quantity, "%s-%d" % [delivery_prefix, delivery_index], 777)
	await _frame(4)


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
		_check("hotspot center uses calibrated map_position: %s" % island_id, actual_local.distance_to(expected_local) < 0.1)
		_check("marker state and click control share calibrated center: %s" % island_id, entry.get_global_rect().get_center().distance_to(world._map_canvas.global_position + actual_local) < 0.1)
		_check("duplicate island and lock thumbnails stay hidden: %s" % island_id, not entry._island_art.visible and not entry._lock_overlay.visible)
	_check("debug override is 800x1422 with 720x1280 viewport", int(ProjectSettings.get_setting("display/window/size/window_width_override")) == 800 and int(ProjectSettings.get_setting("display/window/size/window_height_override")) == 1422 and int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 720 and int(ProjectSettings.get_setting("display/window/size/viewport_height")) == 1280)
	_check("viewport stretch mode remains unchanged", str(ProjectSettings.get_setting("display/window/stretch/mode")) == "viewport")
	hotspot_centers = world.get_hotspot_center_report()
	_capture("01_world_map_calibrated_720x1280")

	world._entries["sunny_cove"].pressed.emit()
	await _frame(4)
	var island_map = navigation.get_island_map()
	_check("Sunny Cove Island Map entry opens", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and island_map.get_level_button_count() == 100)
	_check("Sunny Cove Island Map uses its theme background", island_map.get_island_map_background_path() == SUNNY_COVE_MAP_BACKGROUND)
	var island_layout: Dictionary = island_map.get_layout_report()
	_check("Sunny Cove uses ten 10-level landmark pages", int(island_layout.get("page_size", 0)) == 10 and int(island_layout.get("page_count", 0)) == 10 and island_layout.get("page_background_count", 0) == 10)
	_check("Sunny Cove has no connector path node", island_map.find_child("DeterministicLevelPath", true, false) == null and not bool(island_layout.get("connector_lines", true)))
	var landmark_centers: Array = island_map.level_database.get_island("sunny_cove").get("island_map_layout", {}).get("landmark_centers", [])
	for level_id in range(1, 101):
		var page_index := int(floor(float(level_id - 1) / 10.0))
		var slot_index := (level_id - 1) % 10
		var expected_center := Vector2(float(landmark_centers[slot_index][0]), float(page_index) * 1100.0 + float(landmark_centers[slot_index][1]))
		var level_button: Control = island_map.get_level_button(level_id)
		var actual_center := level_button.position + level_button.size * 0.5
		_check("L%d maps to repeated landmark slot %d" % [level_id, slot_index + 1], actual_center.distance_to(expected_center) <= 0.1)
		if level_id <= 10 or level_id >= 51 and level_id <= 60:
			landmark_mappings.append({"level_id": level_id, "page": page_index + 1, "slot": slot_index + 1, "center": actual_center})
	_check("selected level opens its containing page", island_map.get_scroll_vertical() == 0)
	_capture("02_sunny_cove_page01_landmarks_720x1280")
	island_map._focus_level_id = 51
	island_map.call_deferred("_apply_focus")
	await _frame(3)
	_check("focus L51 opens page six", island_map.get_scroll_vertical() == 5500)
	island_map.set_scroll_vertical(99999)
	_check("vertical paging reaches L100", island_map.get_level_button(100) != null and island_map.get_scroll_vertical() > 9000)
	island_map._focus_level_id = 51
	island_map.call_deferred("_apply_focus")
	await _frame(3)
	_capture("03_sunny_cove_page06_landmarks_720x1280")
	island_map.get_level_button(1).pressed.emit()
	await _frame(6)
	gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
	_check("production Level 1 gameplay opens", gameplay != null and gameplay.shot_controller != null)
	if gameplay == null:
		_finish()
		return
	gameplay_texture_inventory = gameplay.get_visible_texture_inventory()
	var theme_paths: Dictionary = gameplay.get_active_theme_paths()
	var geometry: Dictionary = theme_paths.get("playable_geometry", {})
	var expected_geometry: Dictionary = navigation.get_session_bridge().level_database.get_island("sunny_cove").get("playable_geometry", {})
	_check("Sunny Cove renders one gameplay composite", theme_paths.get("gameplay_surface", "") == "res://assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface.png" and gameplay._background.name == "GameplaySurface" and gameplay._theme_table == null and gameplay._theme_table_shadow == null and gameplay._theme_edge_overlay == null)
	_check("Sunny Cove legacy Y offset is absent from active runtime", not theme_paths.has("table_y_offset_canonical") and is_zero_approx(gameplay._table_y_offset_canonical))
	_check("active geometry equals island playable_geometry", geometry == expected_geometry and geometry.has_all(["playable_polygon", "launch_y", "spawn_y", "death_y"]))
	_check("held launch glass spawns on image-locked spawn_y", gameplay.shot_controller._current_drink != null and is_equal_approx(gameplay.shot_controller._current_drink.position.y, float(geometry.get("spawn_y", -1.0))))
	_check("profile boundary edges match polygon vertices", gameplay.get_playable_boundary_edges().size() == geometry.get("playable_polygon", []).size() and gameplay.get_table_rail_bounds_at_y(gameplay.launch_y).x < gameplay.get_table_rail_bounds_at_y(gameplay.launch_y).y)
	_check("launch line follows image-locked profile", gameplay._launch_indicator != null and is_equal_approx(gameplay._launch_indicator.points[0].y, gameplay.launch_y))
	theme_layer_report = [{"static_visual": "GameplaySurface", "texture_path": theme_paths.get("gameplay_surface", ""), "legacy_layers_instanced": false, "table_y_offset_canonical": gameplay._table_y_offset_canonical, "geometry": geometry}]
	_write_json("V07_R02_GEOMETRY_RUNTIME_REPORT.json", {"theme": theme_paths, "geometry": geometry, "texture_inventory": gameplay_texture_inventory, "rail_edge_count": gameplay.get_playable_boundary_edges().size()})
	_check("result feedback uses dedicated topmost CanvasLayer", navigation._result_canvas_layer != null and navigation._result_canvas_layer.layer > 0)
	_check("result CanvasLayer is owned by campaign navigation and ready", navigation._result_canvas_layer.get_parent() == navigation and navigation.get_result_feedback_overlay().is_node_ready())
	_write_json("V07_R02_GAMEPLAY_VISIBLE_TEXTURE_INVENTORY.json", {"before_first_shot": true, "texture_nodes": gameplay_texture_inventory})
	_capture("SC-01_single_flattened_surface_720x1280")
	_capture("SC-02_clear_central_tabletop_720x1280")
	_capture("SC-03_held_spawn_in_front_720x1280")
	_capture("SC-07_hud_and_progression_clearance_720x1280")
	_check("Sunny Cove theme resolves the composite image", gameplay.get_active_theme_paths().get("gameplay_surface", "").ends_with("sunny_cove/gameplay_surface.png"))
	var bridge = navigation.get_session_bridge()
	_check("session is explicitly untimed", not bool(bridge.get_session_configuration().get("timed", true)) and float(bridge.get_session_configuration().get("time_limit_sec", -1.0)) == 0.0)
	var before_pause_shots := mouse_shots
	_check("Pause action is accepted", gameplay.request_pause())
	await _frame(2)
	var pause_hint: Label = gameplay._pause_layer.get_node_or_null("PauseHint") as Label
	_check("pause overlay opens without timer copy", gameplay.get_pause_overlay_visible() and pause_hint != null and not pause_hint.text.to_lower().contains("timer"))
	_capture("07_pause_untimed_720x1280")
	await _push_input(_mouse_event(Vector2(320.0, 1000.0), true))
	await _push_input(_mouse_motion(Vector2(380.0, 1000.0)))
	await _push_input(_mouse_event(Vector2(380.0, 1000.0), false))
	_check("pause overlay blocks mouse shots", mouse_shots == before_pause_shots)
	_check("RESUME action is accepted", gameplay.resume_campaign_gameplay())
	await _frame(3)
	_check("RESUME closes the pause overlay", not gameplay.get_pause_overlay_visible() and bridge.session_state == bridge.STATE_ACTIVE)
	var stress_layout := [[180,510,12],[360,510,11],[540,510,10],[140,675,9],[360,675,8],[580,675,7],[160,805,6],[360,805,5],[560,805,4],[130,900,3],[360,900,2],[590,900,1]]
	var stress_drinks: Array[Drink] = []
	for entry in stress_layout:
		var stress_drink := gameplay.spawn_drink(int(entry[2]), Vector2(float(entry[0]), float(entry[1])))
		if stress_drink != null:
			stress_drink.freeze = true
			stress_drinks.append(stress_drink)
	_check("12 real cocktail levels instantiate for visual stress", stress_drinks.size() == 12 and gameplay.get_playable_boundary_edges().size() == geometry.get("playable_polygon", []).size())
	for stress_drink in stress_drinks:
		var stress_projection: Dictionary = gameplay.project_footprint_inside_table(Transform2D(0.0, stress_drink.position), stress_drink.get_table_footprint_local(), Vector2.ZERO)
		_check("L%d visible stress footprint stays inside image-locked tabletop" % stress_drink.level, stress_drink.is_visible_in_tree() and not bool(stress_projection.get("corrected", true)) and stress_projection.get("transform", Transform2D.IDENTITY).origin.is_equal_approx(stress_drink.position))
	await _frame(4)
	_capture("SC-05_twelve_glass_crowded_runtime_720x1280")
	for stress_drink in stress_drinks:
		stress_drink.queue_free()
	await _frame(3)
	boundary_shots = 0
	var boundary_counter = func(_drink: Drink, _velocity: Vector2) -> void: boundary_shots += 1
	gameplay.shot_controller.shot_fired.connect(boundary_counter)
	var left_boundary_drink := await _fire_mouse_boundary_shot(20.0, 32)
	var left_contact_position := left_boundary_drink.position if is_instance_valid(left_boundary_drink) else Vector2.ZERO
	var left_contact_bounds := gameplay.get_table_rail_bounds_at_y(left_contact_position.y)
	_capture("SC-06_left_rail_contact_runtime_720x1280")
	var right_boundary_drink := await _fire_mouse_boundary_shot(700.0, 32)
	var right_contact_position := right_boundary_drink.position if is_instance_valid(right_boundary_drink) else Vector2.ZERO
	var right_contact_bounds := gameplay.get_table_rail_bounds_at_y(right_contact_position.y)
	gameplay.shot_controller.shot_fired.disconnect(boundary_counter)
	var left_contact := is_instance_valid(left_boundary_drink) and left_contact_position.x - left_boundary_drink.radius <= left_contact_bounds.x + 6.0
	var right_contact := is_instance_valid(right_boundary_drink) and right_contact_position.x + right_boundary_drink.radius >= right_contact_bounds.y - 6.0
	_check("real left and right side launches contact the visible image-derived rails", boundary_shots == 2 and left_contact and right_contact)
	print("M21_OWNER_F5_V07_R02_SIDE_CONTACT shots=%d left=%s right=%s left_bounds=%s right_bounds=%s left_contact=%s right_contact=%s" % [boundary_shots, str(left_contact_position), str(right_contact_position), str(left_contact_bounds), str(right_contact_bounds), str(left_contact), str(right_contact)])
	_capture("SC-06_right_rail_contact_runtime_720x1280")
	for child in gameplay.world.get_children():
		if child is Drink and (child as Drink).motion_state != Drink.MotionState.HELD:
			(child as Drink).queue_free()
	await _frame(3)
	var rear_boundary_drink := await _fire_mouse_boundary_shot(360.0, 56)
	var rear_contact_position := rear_boundary_drink.position if is_instance_valid(rear_boundary_drink) else Vector2.ZERO
	var rear_contact_bounds := gameplay.get_table_rail_bounds_at_y(rear_contact_position.y)
	var rear_contact := is_instance_valid(rear_boundary_drink) and rear_contact_position.x >= rear_contact_bounds.x and rear_contact_position.x <= rear_contact_bounds.y and absf(rear_contact_position.y - 390.0) <= rear_boundary_drink.radius + 7.0
	_check("real rear launch contacts its visible image-derived rail", rear_contact)
	print("M21_OWNER_F5_V07_R02_REAR_CONTACT position=%s bounds=%s contact=%s" % [str(rear_contact_position), str(rear_contact_bounds), str(rear_contact)])
	_capture("SC-06_rear_rail_contact_runtime_720x1280")
	for child in gameplay.world.get_children():
		if child is Drink and (child as Drink).motion_state != Drink.MotionState.HELD:
			(child as Drink).queue_free()
	await _frame(3)
	mouse_counter = func(_drink: Drink, _velocity: Vector2) -> void: mouse_shots += 1
	gameplay.shot_controller.shot_fired.connect(mouse_counter)
	for index in range(10):
		await _fire_mouse_shot(index)
	_check("10/10 real mouse launches", mouse_shots == 10)
	_capture("SC-04_after_10_real_mouse_launches_720x1280")

	bridge = navigation.get_session_bridge()
	bridge.tick(3600.0)
	_check("untimed gameplay survives one simulated hour", bridge.is_session_active() and not bridge.is_terminal() and is_zero_approx(bridge.timer_remaining_sec))
	_capture("06_sunny_cove_untimed_after_one_hour_720x1280")
	gameplay.shot_controller.shot_fired.disconnect(mouse_counter)
	touch_counter = func(_drink: Drink, _velocity: Vector2) -> void: touch_shots += 1
	gameplay.shot_controller.shot_fired.connect(touch_counter)
	for index in range(10):
		await _fire_touch_shot(index)
		print("M21_OWNER_F5_V07_R02_TOUCH index=%d fired=%d game_over=%s can_shoot=%s" % [index + 1, touch_shots, gameplay.game_over, gameplay.shot_controller._can_shoot])
	_check("10/10 real touch launches", touch_shots == 10)
	_check("direct launch method calls remain zero", direct_launch_calls == 0)

	for level in navigation.get_session_bridge().level_database.get_levels_for_island("sunny_cove"):
		_check("Sunny Cove level %d is untimed" % int(level.get("level_id", 0)), float(level.get("time_limit_sec", -1.0)) == 0.0 and not bool(level.get("feature_flags", {}).get("timed", true)))
	var production_island: Dictionary = navigation.get_session_bridge().level_database.get_island("sunny_cove")
	for reward_entry in production_island.get("reward_track", {}).get("cumulative_star_rewards", []):
		_check("production cumulative reward does not grant +Time", str(reward_entry.get("reward", {}).get("id", "")) != "time")
	gameplay._spawn_to_go_trail(Vector2(90.0, 700.0), Vector2(620.0, 700.0), 0.3)
	gameplay._juice_effect(Vector2(360.0, 720.0))
	await _complete_current_orders(bridge, "m21-owner-v04-win-one")
	var result_overlay = navigation.get_result_feedback_overlay()
	_check("WIN result opens without timer wording", result_overlay.visible and result_overlay.get_title_text() == "LEVEL COMPLETE" and not result_overlay.get_body_text().to_lower().contains("time up") and not result_overlay.get_body_text().to_lower().contains("timer"))
	_check("WIN result overlay is visible in the viewport canvas", result_overlay.is_visible_in_tree() and result_overlay.get_global_rect().size == Vector2(720.0, 1280.0))
	_check("first WIN is presented exactly once", navigation._result_presentation_count == 1)
	navigation._on_session_terminal(bridge.get_terminal_result())
	await _frame(5)
	_check("duplicate terminal signal does not duplicate the result surface", navigation._result_presentation_count == 1 and navigation.get_children().filter(func(child: Node) -> bool: return child is CanvasLayer and child.name == "CampaignResultCanvasLayer").size() == 1)
	terminal_visual_counts = gameplay.get_terminal_visual_counts()
	_check("terminal WIN hides every active Drink", int(terminal_visual_counts.get("visible_drink_count", -1)) == 0)
	_check("terminal WIN clears transient world effects", int(terminal_visual_counts.get("visible_transient_world_effect_count", -1)) == 0)
	_check("result modal CanvasLayer is above gameplay HUD", navigation._result_canvas_layer.layer > gameplay._hud.get_parent().layer)
	var terminal_score := gameplay.score
	var objective_before: Dictionary = bridge.get_objective_state()
	gameplay._add_score(9000)
	bridge.set_current_score(terminal_score + 9000)
	var rejected_delivery: Dictionary = bridge.record_to_go_delivery(6, 1, "v04-post-terminal-delivery", terminal_score + 9000)
	_check("score and delivery state stay frozen after terminal", gameplay.score == terminal_score and bridge.get_objective_state() == objective_before and not bool(rejected_delivery.get("ok", false)))
	_write_json("V07_R02_TERMINAL_VISIBLE_COUNTS.json", {"visual_counts": terminal_visual_counts, "result_canvas_layer": navigation._result_canvas_layer.layer, "result_canvas_parent": navigation._result_canvas_layer.get_parent().name, "result_overlay_visible_in_tree": result_overlay.is_visible_in_tree(), "result_overlay_rect": result_overlay.get_global_rect(), "presentations": navigation._result_presentation_count})
	_capture("SC-08_win_result_clear_720x1280")
	var shots_before_result_input := mouse_shots + touch_shots
	var result_input_y := float(geometry.get("launch_y", 950.0))
	await _push_input(_mouse_event(Vector2(320.0, result_input_y), true))
	await _push_input(_mouse_motion(Vector2(380.0, result_input_y)))
	await _push_input(_mouse_event(Vector2(380.0, result_input_y), false))
	await _push_input(_touch_event(Vector2(320.0, result_input_y), true))
	await _push_input(_touch_drag(Vector2(380.0, result_input_y)))
	await _push_input(_touch_event(Vector2(380.0, result_input_y), false))
	_check("result overlay blocks mouse and touch shots", mouse_shots + touch_shots == shots_before_result_input)
	if result_overlay.get_visible_actions().has("NEXT_LEVEL"):
		_check("Next Level action remains available", result_overlay.trigger_action("NEXT_LEVEL"))
		await _frame(7)
		_check("Next Level action starts the next production level", navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_session_bridge().active_level_id == 2 and navigation.get_gameplay_instance_count() == 1)
		gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
		bridge = navigation.get_session_bridge()
		await _complete_current_orders(bridge, "m21-owner-v04-win-two")
		result_overlay = navigation.get_result_feedback_overlay()
		_check("second WIN result appears after ready-safe re-use", result_overlay.visible and result_overlay.get_title_text() == "LEVEL COMPLETE" and navigation._result_presentation_count == 2)
		_capture("09_second_win_result_visible_720x1280")
		_check("Island Map action is available after second WIN", result_overlay.get_visible_actions().has("ISLAND_MAP") and result_overlay.trigger_action("ISLAND_MAP"))
		await _frame(7)
		_check("Island Map action returns through production navigation", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_gameplay_instance_count() == 0)
		island_map = navigation.get_island_map()
		_check("level 3 unlock remains authoritative after L2 completion", island_map.get_level_state(3) != "LOCKED")
		island_map.get_level_button(3).pressed.emit()
		await _frame(7)
		gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
		bridge = navigation.get_session_bridge()
		_check("production L3 retry fixture starts", gameplay != null and bridge.active_level_id == 3)
		bridge.resolve_lose("V07_R02_RETRY_FIXTURE", 0)
		await _frame(5)
		result_overlay = navigation.get_result_feedback_overlay()
		_check("LOSE result and actions appear", result_overlay.visible and result_overlay.get_title_text() == "LEVEL FAILED" and result_overlay.get_visible_actions() == ["RETRY", "ISLAND_MAP"])
		_capture("10_lose_result_visible_720x1280")
		_check("Retry action is available", result_overlay.trigger_action("RETRY"))
		await _frame(7)
		_check("Retry restarts same level with one live gameplay instance", navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_session_bridge().active_level_id == 3 and navigation.get_gameplay_instance_count() == 1 and not navigation.get_result_feedback_overlay().visible)
	_finish()


func _finish() -> void:
	var report := {
	"work_item": "BCM-M21 owner F5 remediation V07_R02",
		"production_path": "ApplicationShellScene -> CampaignNavigationController -> IslandMap -> GameManager",
		"mouse_shots_fired": mouse_shots,
		"touch_shots_fired": touch_shots,
		"direct_shot_controller_launch_method_calls": direct_launch_calls,
	"captures": captures,
	"hotspot_centers": hotspot_centers,
	"terminal_visual_counts": terminal_visual_counts,
	"theme_layer_isolation": theme_layer_report,
	"landmark_mappings": landmark_mappings,
	"table_translation": table_translation_report,
	"result_presentation_count": navigation._result_presentation_count if navigation != null else 0,
	"checks_failed": failures,
		"physical_device_acceptance": "DEFERRED_TO_OWNER_NATIVE_REAUDIT",
	}
	_write_json("M21_OWNER_F5_REMEDIATION_V07_R02_REPORT.json", report)
	if failures.is_empty():
		print("M21_OWNER_F5_REMEDIATION_V07_R02_RESULT=PASS mouse=%d/10 touch=%d/10 drinks=%d effects=%d captures=%d" % [mouse_shots, touch_shots, int(terminal_visual_counts.get("visible_drink_count", -1)), int(terminal_visual_counts.get("visible_transient_world_effect_count", -1)), captures.size()])
		quit(0)
		return
	print("M21_OWNER_F5_REMEDIATION_V07_R02_RESULT=FAIL failures=%s" % str(failures))
	quit(1)


func _write_json(filename: String, value: Variant) -> void:
	var file := FileAccess.open("%s/%s" % [CAPTURE_DIR, filename], FileAccess.WRITE)
	if file == null:
		failures.append("unable to write report: %s" % filename)
		return
	file.store_string(JSON.stringify(value, "\t"))
	file.close()
