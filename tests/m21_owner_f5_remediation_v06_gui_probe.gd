extends SceneTree

## V06 owner F5 blocker probe. All menu, map, settings, and result actions are
## dispatched as viewport mouse input to visible production Control nodes.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const CAPTURE_DIR := "res://coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v06"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

var failures: Array[String] = []
var captures: Array[Dictionary] = []
var click_count := 0
var shell: ApplicationShell
var navigation: CampaignNavigationController


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_OWNER_F5_V06_GUI PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_OWNER_F5_V06_GUI FAIL: %s" % label)


func _frame(count: int = 3) -> void:
	for _index in range(count):
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
	event.relative = Vector2.ZERO
	return event


func _push_input(event: InputEvent) -> void:
	# Positions come from Control.get_global_rect() in viewport coordinates.
	root.get_viewport().push_input(event, true)
	await process_frame


func _click(control: Control, label: String) -> void:
	if not is_instance_valid(control) or not control.is_visible_in_tree() or control.get_global_rect().size == Vector2.ZERO:
		_check("visible GUI target: %s" % label, false)
		return
	var center := control.get_global_rect().get_center()
	await _push_input(_mouse_motion(center))
	await _push_input(_mouse_event(center, true))
	await _push_input(_mouse_event(center, false))
	await _frame(2)
	click_count += 1
	print("M21_OWNER_F5_V06_GUI_CLICK label=%s position=%s count=%d" % [label, center, click_count])


func _capture(label: String) -> void:
	var texture := root.get_viewport().get_texture()
	if texture == null:
		_check("capture texture available: %s" % label, false)
		return
	var image := texture.get_image()
	if image == null:
		_check("capture image available: %s" % label, false)
		return
	var path := "%s/%s.png" % [CAPTURE_DIR, label]
	var error := image.save_png(path)
	var ok := error == OK and image.get_width() == 720 and image.get_height() == 1280
	_check("720x1280 capture: %s" % label, ok)
	if ok:
		captures.append({"name": label, "path": path, "width": image.get_width(), "height": image.get_height()})
	print("M21_OWNER_F5_V06_CAPTURE name=%s path=%s dimensions=%dx%d error=%s" % [label, path, image.get_width(), image.get_height(), error])


func _complete_current_orders(bridge, prefix: String) -> void:
	var remaining: Dictionary = bridge.get_objective_state().get("normal_remaining", {})
	var index := 0
	for level in remaining:
		var quantity := int(remaining[level])
		if quantity > 0:
			index += 1
			var result: Dictionary = bridge.record_to_go_delivery(int(level), quantity, "%s-%d" % [prefix, index], 777)
			_check("production objective delivery accepted: level %s" % str(level), bool(result.get("ok", false)))
	await _frame(6)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var onboarding := FileAccess.open("user://m21_owner_f5_v05_gui_onboarding.json", FileAccess.WRITE)
	if onboarding == null:
		_check("test onboarding fixture can be written", false)
		_finish()
		return
	onboarding.store_string("{\"schema_version\":1,\"completed\":true}")
	onboarding.close()

	shell = SHELL_SCENE.instantiate() as ApplicationShell
	shell.onboarding_storage_path = "user://m21_owner_f5_v05_gui_onboarding.json"
	shell.settings_storage_path = "user://m21_owner_f5_v05_gui_settings.json"
	root.add_child(shell)
	await _frame(8)
	navigation = shell.get_campaign_navigation()
	# Use isolated in-memory campaign state after the production shell has booted,
	# so the GUI smoke cannot write to the owner's canonical campaign save.
	var database = DATABASE_SCRIPT.new()
	var campaign = CAMPAIGN_SCRIPT.new()
	var configured := database.load_canonical() and campaign.configure(database, SAVE_SCRIPT.new().create_default_state())
	_check("isolated campaign fixture configured", configured and navigation.configure_campaign(database, campaign))
	var result_layer: CanvasLayer = navigation._result_canvas_layer
	_check("production shell launches directly to Main Menu", shell.get_current_view() == "MAIN_MENU" and shell.is_main_menu_visible())
	_check("hidden result layer is inactive at menu launch", result_layer != null and not result_layer.visible and navigation._result_canvas_root.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	_capture("01_main_menu_before_play")

	await _click(shell.get_menu_controls()["play"], "main_menu_play_initial")
	await _frame(5)
	_check("real PLAY click opens visible World Map", shell.get_current_view() == "CAMPAIGN" and navigation.visible and navigation.get_current_view() == navigation.VIEW_WORLD_MAP)
	_check("result layer remains inactive over World Map", not result_layer.visible and not navigation.get_result_feedback_overlay().visible)
	_capture("02_world_map_after_play")

	var world_map = navigation.get_world_map()
	await _click(world_map.get_node("Header/BackButton"), "world_map_back_to_main_menu")
	await _frame(5)
	_check("World Map Back uses production route to Main Menu", shell.get_current_view() == "MAIN_MENU" and not navigation.visible and not result_layer.visible)
	await _click(shell.get_menu_controls()["settings"], "main_menu_settings")
	_check("real SETTINGS click opens Settings", shell.get_current_view() == "SETTINGS" and shell.is_settings_visible())
	_capture("03_settings_after_click")
	await _click(shell.find_child("CloseSettingsButton", true, false) as Control, "settings_back_to_menu")
	_check("real BACK TO MENU click returns to Main Menu", shell.get_current_view() == "MAIN_MENU" and shell.is_main_menu_visible())
	_capture("04_main_menu_after_settings")
	await _click(shell.get_menu_controls()["play"], "main_menu_play_second")
	await _frame(5)
	_check("second real PLAY click opens World Map", shell.get_current_view() == "CAMPAIGN" and navigation.visible and navigation.get_current_view() == navigation.VIEW_WORLD_MAP)

	world_map = navigation.get_world_map()
	await _click(world_map._entries.get("sunny_cove") as Control, "world_map_sunny_cove")
	await _frame(6)
	_check("real Sunny Cove click opens Island Map", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and navigation.get_island_map().get_level_button_count() == 100)
	var island_map = navigation.get_island_map()
	await _click(island_map.get_level_button(1) as Control, "island_map_level_1")
	await _frame(8)
	_check("real Level 1 click opens gameplay", navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_gameplay_instance_count() == 1)
	if navigation.get_current_view() != navigation.VIEW_GAMEPLAY:
		_finish()
		return

	var bridge = navigation.get_session_bridge()
	_check("campaign session is untimed", not bool(bridge.get_session_configuration().get("timed", true)) and float(bridge.get_session_configuration().get("time_limit_sec", -1.0)) == 0.0)
	await _complete_current_orders(bridge, "m21-owner-f5-v05-win")
	var feedback = navigation.get_result_feedback_overlay()
	_check("WIN result card and canvas are active", feedback.visible and feedback.get_title_text() == "LEVEL COMPLETE" and result_layer.visible and feedback.is_visible_in_tree())
	_check("result root remains input-ignored", navigation._result_canvas_root.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	_capture("05_win_result_visible")

	var next_button := feedback.get_node("FeedbackActions").get_child(0) as Button
	await _click(next_button, "result_next_level")
	await _frame(8)
	_check("real Next Level click starts Level 2", navigation.get_current_view() == navigation.VIEW_GAMEPLAY and bridge.active_level_id == 2)
	_check("result layer is inactive after Next Level", not result_layer.visible and not feedback.visible)
	await _complete_current_orders(bridge, "m21-owner-f5-v05-win-next")
	_check("reused result surface presents the next level WIN", feedback.visible and feedback.get_title_text() == "LEVEL COMPLETE" and result_layer.visible)
	var island_map_action := feedback.get_node("FeedbackActions").get_child(1) as Button
	await _click(island_map_action, "result_island_map_after_next_win")
	await _frame(7)
	_check("real result Island Map click returns to map and hides result layer", navigation.get_current_view() == navigation.VIEW_ISLAND_MAP and not result_layer.visible and not feedback.visible)
	island_map = navigation.get_island_map()
	await _click(island_map.get_node("IslandMapHeader/BackToWorldMap"), "island_map_back_to_world_map_after_result")
	await _frame(5)
	_check("production Island Map Back returns to World Map", navigation.get_current_view() == navigation.VIEW_WORLD_MAP)
	world_map = navigation.get_world_map()
	await _click(world_map.get_node("Header/BackButton"), "world_map_back_after_result")
	await _frame(6)
	_check("production map Back returns to Main Menu after result", shell.get_current_view() == "MAIN_MENU" and not navigation.visible and not result_layer.visible)
	_capture("06_main_menu_after_result")

	await _click(shell.get_menu_controls()["play"], "main_menu_play_after_result")
	await _frame(5)
	_check("PLAY remains clickable after result", shell.get_current_view() == "CAMPAIGN" and navigation.get_current_view() == navigation.VIEW_WORLD_MAP)
	await _click(world_map.get_node("Header/BackButton"), "world_map_back_after_result_validation")
	await _click(shell.get_menu_controls()["settings"], "main_menu_settings_after_result")
	_check("SETTINGS remains clickable after result", shell.get_current_view() == "SETTINGS" and shell.is_settings_visible())
	await _click(shell.find_child("CloseSettingsButton", true, false) as Control, "settings_back_after_result_validation")
	_check("BACK TO MENU remains clickable after result", shell.get_current_view() == "MAIN_MENU" and shell.is_main_menu_visible())

	_finish()


func _finish() -> void:
	var report := {
		"work_item": "BCM-M21-001 + BCM-M21-006 Owner F5 Remediation V06",
		"production_path": "ApplicationShellScene -> CampaignNavigationController -> WorldMap -> IslandMap -> GameManager",
		"gui_click_count": click_count,
		"captures": captures,
		"result_layer_visible_at_finish": navigation._result_canvas_layer.visible if navigation != null and is_instance_valid(navigation._result_canvas_layer) else false,
		"result_root_mouse_filter": navigation._result_canvas_root.mouse_filter if navigation != null and is_instance_valid(navigation._result_canvas_root) else -1,
		"checks_failed": failures,
		"physical_device_acceptance": "DEFERRED_TO_OWNER_NATIVE_F5_REVIEW",
	}
	var report_file := FileAccess.open("%s/M21_OWNER_F5_REMEDIATION_V06_GUI_REPORT.json" % CAPTURE_DIR, FileAccess.WRITE)
	if report_file != null:
		report_file.store_string(JSON.stringify(report, "\t"))
		report_file.close()
	if failures.is_empty():
		print("M21_OWNER_F5_REMEDIATION_V06_GUI_RESULT=PASS clicks=%d captures=%d" % [click_count, captures.size()])
		quit(0)
		return
	print("M21_OWNER_F5_REMEDIATION_V06_GUI_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
