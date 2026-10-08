extends SceneTree

## BCM-M21-001 production-path desktop/mobile-layout proxy.
## Drives the existing App Shell controls and saves auditable captures at the
## canonical viewport plus a taller portrait SubViewport. Physical-device
## touch/visual acceptance is intentionally outside this probe.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const CAPTURE_DIR := "res://coordination/sessions/BCM-M24-MASTER-V01/evidence/M24-R01/mobile_qa"

var failures: Array[String] = []
var captures: Array[Dictionary] = []
var canonical_shell
var canonical_navigation


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_CHILD_01_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_CHILD_01_PROBE FAIL: %s" % label)


func _frame(count: int = 2) -> void:
	for _index in range(count):
		await process_frame


func _fresh_campaign():
	var database = DATABASE_SCRIPT.new()
	_check("canonical campaign data loads", database.load_canonical())
	var campaign = CAMPAIGN_SCRIPT.new()
	_check("fresh campaign fixture configures", campaign.configure(database, SAVE_SCRIPT.new().create_default_state()))
	return {"database": database, "campaign": campaign}


func _mount_shell(target: Viewport, suffix: String):
	var shell = SHELL_SCENE.instantiate()
	var unique_suffix := "%s_%s" % [suffix, Time.get_ticks_usec()]
	shell.onboarding_storage_path = "user://m21_child01_onboarding_%s.json" % unique_suffix
	shell.settings_storage_path = "user://m21_child01_settings_%s.json" % unique_suffix
	target.add_child(shell)
	await _frame(4)
	var fixture: Dictionary = _fresh_campaign()
	var navigation = shell.get_campaign_navigation()
	_check("production navigation accepts fresh campaign fixture", navigation.configure_campaign(fixture["database"], fixture["campaign"]))
	await _frame(4)
	return shell


func _capture(viewport: Viewport, label: String) -> void:
	var texture := viewport.get_texture()
	if texture == null:
		_check("capture texture available: %s" % label, false)
		return
	var image := texture.get_image()
	if image == null:
		_check("capture image available: %s" % label, false)
		return
	var path := "%s/%s.png" % [CAPTURE_DIR, label]
	var error := image.save_png(path)
	var saved := error == OK and FileAccess.file_exists(path)
	_check("capture saved: %s" % label, saved)
	print("M21_CHILD_01_CAPTURE name=%s path=%s dimensions=%dx%d error=%s" % [label, path, image.get_width(), image.get_height(), error])
	if saved:
		captures.append({"name": label, "path": path, "width": image.get_width(), "height": image.get_height()})


func _capture_surface(viewport: Viewport, shell, label: String) -> void:
	await _frame(3)
	_capture(viewport, label)


func _run_canonical() -> void:
	var viewport := root
	canonical_shell = await _mount_shell(viewport, "canonical")
	canonical_navigation = canonical_shell.get_campaign_navigation()

	_check("onboarding surface is visible", canonical_shell.is_onboarding_visible())
	_check("onboarding exposes five pages", canonical_shell.get_onboarding_page_count() == 5)
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_onboarding")

	var next_button = canonical_shell._onboarding_next_button
	for _page in range(canonical_shell.get_onboarding_page_count()):
		_check("onboarding NEXT/FINISH production control is reachable", next_button != null)
		if next_button != null:
			next_button.pressed.emit()
		await _frame()
	_check("onboarding control path reaches Main Menu", canonical_shell.is_main_menu_visible())
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_main_menu")

	var menu_controls: Dictionary = canonical_shell.get_menu_controls()
	var settings_button: BaseButton = menu_controls.get("settings")
	_check("Settings production control is reachable", settings_button != null)
	if settings_button != null:
		settings_button.pressed.emit()
	await _frame()
	_check("Settings surface opens", canonical_shell.is_settings_visible())
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_settings")
	var before_reduced_motion := bool(canonical_shell.get_user_settings().get_value("reduced_motion", false))
	var reduced_motion_button: Button = canonical_shell._settings_controls.get("reduced_motion")
	_check("Settings toggle production control is reachable", reduced_motion_button != null)
	if reduced_motion_button != null:
		reduced_motion_button.pressed.emit()
	await _frame()
	_check("Settings toggle persists in presentation state", bool(canonical_shell.get_presentation_state().get("reduced_motion", false)) != before_reduced_motion)
	var close_settings = canonical_shell._settings_layer.get_node_or_null("CloseSettingsButton")
	_check("Settings close production control is reachable", close_settings != null)
	if close_settings != null:
		close_settings.pressed.emit()
	await _frame()

	var play_button: BaseButton = canonical_shell.get_menu_controls().get("play")
	_check("PLAY production control is reachable", play_button != null)
	if play_button != null:
		play_button.pressed.emit()
	await _frame(4)
	_check("PLAY continues the unlocked frontier into gameplay", canonical_shell.get_current_view() == "CAMPAIGN" and canonical_navigation.get_current_view() == canonical_navigation.VIEW_GAMEPLAY and canonical_navigation.get_gameplay_instance_count() == 1)
	_check("PLAY does not misroute into World Map", canonical_navigation.get_current_view() != canonical_navigation.VIEW_WORLD_MAP)
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_play_gameplay")
	_check("Home can be reopened after PLAY", canonical_shell.show_main_menu() and canonical_shell.is_main_menu_visible())
	var world_map_button: TextureButton = canonical_shell.get_menu_controls().get("world_map")
	_check("separate WORLD MAP production control is reachable", world_map_button != null)
	if world_map_button != null:
		world_map_button.pressed.emit()
	await _frame(4)
	_check("WORLD MAP control reaches World Map without gameplay", canonical_shell.get_current_view() == "CAMPAIGN" and canonical_navigation.get_current_view() == canonical_navigation.VIEW_WORLD_MAP and canonical_navigation.get_gameplay_instance_count() == 0)
	var world = canonical_navigation.get_world_map()
	_check("World Map has production island controls", world != null and world.get_entry_count() == world.get_map_node_count() and world.get_entry_count() >= 2)
	_check("World Map layout has no horizontal clipping", not bool(world.get_layout_report(Vector2(720, 1280)).get("horizontal_clipping", true)))
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_world_map")

	var tiki_entry = world._entries.get("tiki_island")
	_check("locked island production control is reachable", tiki_entry != null)
	if tiki_entry != null:
		tiki_entry.pressed.emit()
	await _frame()
	_check("locked feedback is visible", world.get_feedback_overlay().visible)
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_locked_feedback")
	world.get_feedback_overlay().trigger_action("DISMISS")

	var sunny_entry = world._entries.get("sunny_cove")
	_check("Sunny Cove island production control is reachable", sunny_entry != null)
	if sunny_entry != null:
		sunny_entry.pressed.emit()
	await _frame(4)
	var island_map = canonical_navigation.get_island_map()
	_check("World Map selection reaches Island Map", canonical_navigation.get_current_view() == canonical_navigation.VIEW_ISLAND_MAP and island_map.get_level_button_count() == 100)
	var island_layout: Dictionary = island_map.get_layout_report(Vector2(720, 1280))
	_check("100-level Island Map has no horizontal clipping", not bool(island_layout.get("horizontal_clipping", true)))
	_check("100-level Island Map is vertically scrollable", bool(island_layout.get("vertical_scrollable", false)))
	_check("Island Map has no duplicate level nodes", not bool(island_layout.get("duplicate_nodes", true)))
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_island_map_top")
	island_map.set_scroll_vertical(999999)
	await _frame(3)
	_check("Island Map scroll path reaches lower levels", island_map.get_scroll_vertical() > 0 and island_map.get_level_button(100) != null)
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_island_map_bottom")

	var level_one = island_map.get_level_button(1)
	_check("Level selection production control is reachable", level_one != null)
	if level_one != null:
		level_one.pressed.emit()
	await _frame(5)
	var gameplay = canonical_navigation.get_node_or_null("CampaignGameplay") as GameManager
	_check("level selection reaches gameplay", gameplay != null and canonical_navigation.get_gameplay_instance_count() == 1)
	_check("gameplay pause control is reachable", gameplay != null and gameplay._pause_button != null)
	if gameplay != null and gameplay._pause_button != null:
		gameplay._pause_button.pressed.emit()
	await _frame()
	_check("pause overlay opens", gameplay != null and gameplay.get_pause_overlay_visible())
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_pause")
	_check("resume production control is reachable", gameplay != null and gameplay._pause_resume_button != null)
	if gameplay != null and gameplay._pause_resume_button != null:
		gameplay._pause_resume_button.pressed.emit()
	await _frame(2)
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_gameplay")

	var bridge = canonical_navigation.get_session_bridge()
	bridge.resolve_lose("M21_CHILD_01_LOSE")
	await _frame(3)
	_check("LOSE result action surface opens", canonical_navigation.get_result_feedback_overlay().visible and canonical_navigation.get_result_feedback_overlay().get_feedback_kind() == "RESULT_LOSE")
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_lose_result")
	_check("RETRY result production action is reachable", canonical_navigation.get_result_feedback_overlay().trigger_action("RETRY"))
	await _frame(5)
	bridge = canonical_navigation.get_session_bridge()
	var remaining: Dictionary = bridge.get_objective_state().get("normal_remaining", {})
	var delivery_index := 0
	for level in remaining:
		var quantity := int(remaining[level])
		if quantity > 0:
			delivery_index += 1
			bridge.record_to_go_delivery(int(level), quantity, "m21-child01-win-%d" % delivery_index, 321)
	await _frame(3)
	_check("WIN result action surface opens", canonical_navigation.get_result_feedback_overlay().visible and canonical_navigation.get_result_feedback_overlay().get_feedback_kind() == "RESULT_WIN")
	await _capture_surface(viewport, canonical_shell, "canonical_720x1280_win_result")
	_check("ISLAND MAP result production action is reachable", canonical_navigation.get_result_feedback_overlay().trigger_action("ISLAND_MAP"))
	await _frame(3)
	_check("result action returns to one Island Map", canonical_navigation.get_current_view() == canonical_navigation.VIEW_ISLAND_MAP and canonical_navigation.get_gameplay_instance_count() == 0)
	_check("navigation retains one map pair after repeated flow", canonical_navigation.get_map_instance_count() == 2)


func _run_tall() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2(720, 1440)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	root.add_child(viewport)
	var shell = await _mount_shell(viewport, "tall")
	var navigation = shell.get_campaign_navigation()
	_check("tall presentation starts at onboarding", shell.is_onboarding_visible())
	shell.skip_onboarding()
	await _frame(2)
	shell.get_menu_controls().get("play").pressed.emit()
	await _frame(4)
	_check("tall PLAY continues the unlocked frontier into gameplay", shell.get_current_view() == "CAMPAIGN" and navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_gameplay_instance_count() == 1)
	_check("tall PLAY does not misroute into World Map", navigation.get_current_view() != navigation.VIEW_WORLD_MAP)
	await _capture_surface(viewport, shell, "tall_720x1440_play_gameplay")
	_check("tall Home can be reopened after PLAY", shell.show_main_menu() and shell.is_main_menu_visible())
	var world_map_button: TextureButton = shell.get_menu_controls().get("world_map")
	_check("tall separate WORLD MAP production control is reachable", world_map_button != null)
	if world_map_button != null:
		world_map_button.pressed.emit()
	await _frame(4)
	_check("tall WORLD MAP control reaches World Map without gameplay", shell.get_current_view() == "CAMPAIGN" and navigation.get_current_view() == navigation.VIEW_WORLD_MAP and navigation.get_gameplay_instance_count() == 0)
	var tall_world = navigation.get_world_map()
	_check("tall World Map retains all production island entries", tall_world != null and tall_world.get_entry_count() == tall_world.get_map_node_count() and tall_world.get_entry_count() >= 2)
	_check("tall World Map has no horizontal clipping", tall_world != null and not bool(tall_world.get_layout_report(Vector2(720, 1440)).get("horizontal_clipping", true)))
	await _capture_surface(viewport, shell, "tall_720x1440_world_map")
	navigation.get_world_map()._entries.get("sunny_cove").pressed.emit()
	await _frame(4)
	var island_map = navigation.get_island_map()
	_check("tall presentation keeps 100-level Island Map reachable", island_map.get_level_button_count() == 100 and not bool(island_map.get_layout_report(Vector2(720, 1440)).get("horizontal_clipping", true)))
	island_map.set_scroll_vertical(999999)
	await _frame(3)
	_check("tall presentation preserves vertical scroll interaction", island_map.get_scroll_vertical() > 0)
	await _capture_surface(viewport, shell, "tall_720x1440_island_map_bottom")
	island_map.get_level_button(1).pressed.emit()
	await _frame(5)
	var gameplay = navigation.get_node_or_null("CampaignGameplay") as GameManager
	_check("tall presentation reaches gameplay without duplicate instance", gameplay != null and navigation.get_gameplay_instance_count() == 1)
	await _capture_surface(viewport, shell, "tall_720x1440_gameplay")
	viewport.remove_child(shell)
	shell.queue_free()
	viewport.queue_free()
	await _frame(2)


func _write_report() -> void:
	var report := {
		"work_item": "BCM-M21-001",
		"probe": "tests/m21_mobile_qa_probe.gd",
		"environment": {
			"godot": Engine.get_version_info(),
			"renderer": "GL Compatibility",
			"physical_device": false,
			"canonical_viewport": [720, 1280],
			"tall_viewport": [720, 1440],
		},
		"capture_count": captures.size(),
		"captures": captures,
		"checks_failed": failures,
		"physical_device_acceptance": "DEFERRED_TO_OWNER_NATIVE_M21_006",
	}
	var file := FileAccess.open("%s/M21-001_MOBILE_LAYOUT_TOUCH_QA.json" % CAPTURE_DIR, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()


func _finish() -> void:
	_write_report()
	if failures.is_empty():
		print("M21_CHILD_01_RESULT=PASS captures=%d" % captures.size())
		quit(0)
		return
	print("M21_CHILD_01_RESULT=FAIL failures=%s captures=%d" % [str(failures), captures.size()])
	quit(1)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	await _run_canonical()
	await _run_tall()
	_finish()
