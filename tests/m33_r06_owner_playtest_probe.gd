extends "res://tests/support/isolated_test_scene_tree.gd"

const BCM_SANDBOX_GUARD := preload("res://tests/support/test_sandbox_guard.gd")


## Bounded integration probe for the R06 owner playtest console.
## It launches the production shell/scene and uses the production input,
## merge-queue, objective, retry, and profile boundaries.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const CONSOLE_SCRIPT := preload("res://scripts/campaign/owner_playtest_console.gd")

var failures: Array[String] = []
var captures: Array[String] = []
var shell
var navigation
var console


func _init() -> void:
	if not BCM_SANDBOX_GUARD.enforce(self):
		return
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M33_R06 PASS: %s" % label)
	else:
		failures.append(label)
		print("M33_R06 FAIL: %s" % label)


func _frames(count: int = 3) -> void:
	for _index in range(count):
		await process_frame


func _capture(label: String) -> void:
	if OS.has_feature("headless") or DisplayServer.get_name().to_lower() in ["headless", "dummy"]:
		print("M33_R06_CAPTURE SKIP %s: headless renderer" % label)
		return
	await RenderingServer.frame_post_draw
	print("M33_R06_CAPTURE_STATE name=%s view=%s chooser=%s background=%s" % [label, str(navigation.get_current_view()) if navigation != null else "NO_NAV", str(console._panel.visible) if console != null else "NO_CONSOLE", str(console._background.visible) if console != null else "NO_CONSOLE"])
	var image := root.get_viewport().get_texture().get_image()
	var directory := "res://coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R06"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var path := "%s/%s.png" % [directory, label]
	var err := image.save_png(path)
	var ok := err == OK and image.get_width() == 720 and image.get_height() == 1280
	_check("actual graphical capture %s at 720x1280" % label, ok)
	if ok:
		captures.append(path)


func _push(event: InputEvent) -> void:
	root.get_viewport().push_input(event)
	await process_frame


func _mouse(position: Vector2, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = pressed
	return event


func _run() -> void:
	var profile_root := OS.get_environment("BCM_M33_TEST_PROFILE_ROOT").replace("\\", "/").to_lower()
	var user_path := ProjectSettings.globalize_path("user://").replace("\\", "/").to_lower()
	_check("runtime user:// resolves beneath the explicit R06 test profile", not profile_root.is_empty() and user_path.begins_with(profile_root + "/"))
	_check("normal campaign persistence is disabled before startup", not OS.get_environment("BCM_M33_OWNER_PLAYTEST").is_empty())
	shell = SHELL_SCENE.instantiate()
	root.add_child(shell)
	await _frames(12)
	navigation = shell.get_campaign_navigation()
	console = shell.get_node_or_null("OwnerPlaytestConsole")
	_check("isolated app opens the R06 selector instead of Home/onboarding", console != null and console.visible and navigation != null)
	_check("test campaign progression persistence remains disabled", navigation != null and not navigation._persistence_enabled)
	_check("regular campaign save manager was not read in test mode", navigation != null and navigation.save_manager != null and not FileAccess.file_exists("user://campaign_save.json"))
	var database = navigation.level_database if navigation != null else null
	var rows: Array = CONSOLE_SCRIPT.SAMPLE_ROWS
	var sample_ids: Dictionary = {}
	var generated_entries: Dictionary = {}
	var contrast_counts := {0: false, 1: false, 2: false}
	var matrix_ok := database != null and rows.size() == 13
	for row in rows:
		var sample_id := str(row.get("sample_id", ""))
		var island_id := str(row.get("island_id", ""))
		var level_id := int(row.get("level_id", 0))
		var level: Dictionary = database.get_level(island_id, level_id) if database != null else {}
		matrix_ok = matrix_ok and not sample_id.is_empty() and not sample_ids.has(sample_id) and not level.is_empty() and int(level.get("global_level_id", -1)) == int(row.get("global_level_id", -2))
		sample_ids[sample_id] = true
		if sample_id.begins_with("ENTRY_"):
			generated_entries[island_id] = int(row["global_level_id"])
			matrix_ok = matrix_ok and level.get("initial_tabletop_drinks", []).is_empty()
		if sample_id == "CONTRAST_EMPTY":
			contrast_counts[0] = level.get("initial_tabletop_drinks", []).size() == 0
		if sample_id == "CONTRAST_ONE":
			contrast_counts[1] = level.get("initial_tabletop_drinks", []).size() == 1
		if sample_id == "CONTRAST_TWO":
			contrast_counts[2] = level.get("initial_tabletop_drinks", []).size() == 2
	_check("13 samples map to real immutable global IDs; nine generated entry IDs are distinct and empty", matrix_ok and generated_entries.size() == 9)
	_check("empty / one / two starter contrasts resolve to actual content", contrast_counts[0] and contrast_counts[1] and contrast_counts[2])
	_check("optional L9 capstone maps to global ID 1000", int(database.get_level("final_island", 100).get("global_level_id", 0)) == 1000)
	if console == null:
		_finish()
		return
	console._select_sample(rows[10])
	_check("selector preview shows immutable ID, objectives, starter stock and predicted T/move limit", console._preview.text.contains("global ID 208") and console._preview.text.contains("To-Go:") and console._preview.text.contains("Initial stock:") and console._preview.text.contains("Predicted T:"))
	await _capture("R06_SAMPLE_SELECTOR_720x1280")
	console._start_selected_sample()
	await _frames(12)
	var gameplay: GameManager = navigation.get_node_or_null("CampaignGameplay") as GameManager
	_check("sample selection enters the production gameplay scene", navigation.get_current_view() == navigation.VIEW_GAMEPLAY and gameplay != null and navigation.get_gameplay_instance_count() == 1)
	_check("sample chooser overlay is hidden for real play", console != null and not console._panel.visible and not console._background.visible and navigation.visible)
	var one_starter_count := 0
	if gameplay != null and gameplay.world != null:
		for child in gameplay.world.get_children():
			if child is Drink and (child as Drink).motion_state != Drink.MotionState.HELD:
				one_starter_count += 1
	_check("production gameplay shows the selected one-starter L6 stock", one_starter_count == 1)
	await _capture("R06_GAMEPLAY_ONE_STARTER_INITIAL_720x1280")
	console._return_to_chooser()
	await _frames(5)
	console._select_sample(rows[0])
	console._start_selected_sample()
	await _frames(12)
	gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
	var bridge = navigation.get_session_bridge()
	_check("empty Tiki entry loads live session with no timer", gameplay != null and bridge.active_island_id == "tiki_island" and bridge.active_level_id == 1 and is_zero_approx(bridge.timer_remaining_sec))
	var shot_before := int(console._attempt.get("shots", 0))
	var held: Drink = gameplay.shot_controller._current_drink as Drink
	var launch_position := Vector2(330.0, gameplay.launch_y)
	await _push(_mouse(launch_position, true))
	var motion := InputEventMouseMotion.new()
	motion.position = Vector2(335.0, gameplay.launch_y)
	motion.relative = Vector2(5.0, 0.0)
	await _push(motion)
	await _push(_mouse(Vector2(335.0, gameplay.launch_y), false))
	_check("real viewport mouse press-drag-release increments telemetry shot and production move count", int(console._attempt.get("shots", 0)) == shot_before + 1 and int(bridge.get_move_budget_state().get("moves_used", 0)) == 1 and is_instance_valid(held))
	var merge_position := Vector2(500.0, 660.0)
	for level in range(1, 5):
		var first := gameplay.spawn_drink(level, merge_position, false)
		var second := gameplay.spawn_drink(level, merge_position + Vector2(4.0, 0.0), false)
		if is_instance_valid(first): first.set_settled()
		if is_instance_valid(second): second.set_settled()
		gameplay.merge_queue.request_merge(first, second, level + 1)
		await _frames(4)
	var target_capture := false
	for _frame in range(120):
		await process_frame
		if bridge.is_terminal():
			target_capture = true
			break
	var completed_attempt: Dictionary = console._run_attempts.back() if not console._run_attempts.is_empty() else {}
	_check("production merge queue combines physical drink nodes through the L5 target", target_capture and int(completed_attempt.get("completed_to_go", 0)) == 1 and str(completed_attempt.get("outcome", "")) == "WIN" and navigation.get_session_bridge().is_terminal())
	var terminal = navigation.get_result_feedback_overlay()
	_check("real To-Go delivery produces the production win result", terminal != null and terminal.get_title_text() == "LEVEL COMPLETE")
	if terminal != null:
		terminal.trigger_action("RETRY")
	await _frames(12)
	_check("production Retry restarts the same sample and telemetry labels the new attempt", navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_session_bridge().active_level_id == 1 and int(console._attempt.get("retry_count", -1)) == 1 and int(console._attempt.get("shots", 0)) == 0)
	console._return_to_chooser()
	await _frames(5)
	var report_path := ProjectSettings.globalize_path("user://m33_r06/OWNER_PLAYTEST_REPORT.md")
	var telemetry_path := ProjectSettings.globalize_path("user://m33_r06/attempts.jsonl")
	_check("leaving a sample appends isolated report and JSONL telemetry", FileAccess.file_exists(report_path) and FileAccess.file_exists(telemetry_path) and console._run_attempts.size() >= 2)
	_check("return-to-samples disposes gameplay and restores selector", navigation.get_gameplay_instance_count() == 0 and console._panel.visible)
	print("M33_R06_CAPTURE_PATHS=%s" % JSON.stringify(captures))
	_finish()


func _finish() -> void:
	if failures.is_empty():
		print("M33_R06_RESULT=PASS")
		quit(0)
	else:
		print("M33_R06_RESULT=FAIL failures=%s" % JSON.stringify(failures))
		quit(1)
