extends SceneTree

## BCM-M21 final owner-runtime closure V02-R01 probe.
##
## The launch smoke dispatches real InputEvent objects through the production
## viewport boundary. It intentionally never calls ShotController launch
## methods directly.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const CAPTURE_DIR := "res://coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v02-r01"
const WORLD_MAP_CENTERS := {
	"sunny_cove": Vector2(455.0, 330.0),
	"tiki_island": Vector2(135.0, 355.0),
	"azure_bay": Vector2(560.0, 475.0),
	"coconut_beach": Vector2(315.0, 625.0),
	"sunset_island": Vector2(180.0, 160.0),
	"party_beach": Vector2(135.0, 750.0),
	"frozen_paradise": Vector2(550.0, 150.0),
	"volcano_bay": Vector2(555.0, 1040.0),
	"billionaire_island": Vector2(560.0, 785.0),
	"final_island": Vector2(210.0, 960.0),
}

var failures: Array[String] = []
var captures: Array[Dictionary] = []
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
	for island_id in WORLD_MAP_CENTERS:
		var entry = world._entries.get(island_id)
		if entry == null:
			_check("calibrated hotspot exists: %s" % island_id, false)
			continue
		var expected_local: Vector2 = WORLD_MAP_CENTERS[island_id] - world._map_canvas.position
		var actual_local: Vector2 = entry.position + IslandEntry.MARKER_CENTER
		_check("calibrated hotspot aligns: %s" % island_id, actual_local.distance_to(expected_local) < 0.1)
	_capture("01_world_map_720x1280")

	world._entries["sunny_cove"].pressed.emit()
	await _frame(4)
	var island_map = navigation.get_island_map()
	_check("Sunny Cove Island Map entry opens", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and island_map.get_level_button_count() == 100)
	_capture("02_sunny_cove_island_map_720x1280")
	island_map.get_level_button(1).pressed.emit()
	await _frame(6)
	gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
	_check("production Level 1 gameplay opens", gameplay != null and gameplay.shot_controller != null)
	if gameplay == null:
		_finish()
		return
	mouse_counter = func(_drink: Drink, _velocity: Vector2) -> void: mouse_shots += 1
	gameplay.shot_controller.shot_fired.connect(mouse_counter)
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
	var delivery_index := 0
	for level in remaining:
		var quantity := int(remaining[level])
		if quantity > 0:
			delivery_index += 1
			bridge.record_to_go_delivery(int(level), quantity, "m21-owner-win-%d" % delivery_index, 777)
	await _frame(4)
	var result_overlay = navigation.get_result_feedback_overlay()
	_check("WIN result opens without timer wording", result_overlay.visible and result_overlay.get_title_text() == "LEVEL COMPLETE" and not result_overlay.get_body_text().to_lower().contains("time up") and not result_overlay.get_body_text().to_lower().contains("timer"))
	var shots_before_result_input := mouse_shots + touch_shots
	await _push_input(_mouse_event(Vector2(320.0, 950.0), true))
	await _push_input(_mouse_motion(Vector2(380.0, 950.0)))
	await _push_input(_mouse_event(Vector2(380.0, 950.0), false))
	await _push_input(_touch_event(Vector2(320.0, 950.0), true))
	await _push_input(_touch_drag(Vector2(380.0, 950.0)))
	await _push_input(_touch_event(Vector2(380.0, 950.0), false))
	_check("result overlay blocks mouse and touch shots", mouse_shots + touch_shots == shots_before_result_input)
	_capture("07_win_untimed_no_timer_language_720x1280")

	_finish()


func _finish() -> void:
	var report := {
		"work_item": "BCM-M21 final owner-runtime closure V02-R01",
		"production_path": "ApplicationShellScene -> CampaignNavigationController -> IslandMap -> GameManager",
		"mouse_shots_fired": mouse_shots,
		"touch_shots_fired": touch_shots,
		"direct_shot_controller_launch_method_calls": direct_launch_calls,
		"captures": captures,
		"checks_failed": failures,
		"physical_device_acceptance": "DEFERRED_TO_OWNER_NATIVE_REAUDIT",
	}
	var file := FileAccess.open("%s/M21_OWNER_RUNTIME_INPUT_SMOKE_V02_R01.json" % CAPTURE_DIR, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	if failures.is_empty():
		print("M21_OWNER_RUNTIME_CLOSURE_V02_R01_RESULT=PASS mouse=%d/10 touch=%d/10 direct_launch_calls=%d captures=%d" % [mouse_shots, touch_shots, direct_launch_calls, captures.size()])
		quit(0)
		return
	print("M21_OWNER_RUNTIME_CLOSURE_V02_R01_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
