extends SceneTree

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const OUTPUT_PATH := "res://coordination/sessions/BCM-M23-MASTER-V01/evidence/M23-R03/m21_tall_navigation_diagnostic.json"

var _frames := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(720, 1440)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var shell := SHELL_SCENE.instantiate()
	var unique := str(Time.get_ticks_usec())
	shell.onboarding_storage_path = "user://m23_r03_tall_onboarding_%s.json" % unique
	shell.settings_storage_path = "user://m23_r03_tall_settings_%s.json" % unique
	viewport.add_child(shell)
	await _settle(4)
	var database = DATABASE_SCRIPT.new()
	var database_ok: bool = database.load_canonical()
	var campaign = CAMPAIGN_SCRIPT.new()
	var campaign_ok: bool = campaign.configure(database, SAVE_SCRIPT.new().create_default_state()) if database_ok else false
	var navigation = shell.get_campaign_navigation()
	var navigation_ok: bool = navigation.configure_campaign(database, campaign) if campaign_ok else false
	var before := _snapshot(shell, navigation, viewport)
	var skip_result: bool = shell.skip_onboarding()
	var after_skip := _snapshot(shell, navigation, viewport)
	var play = shell.get_menu_controls().get("play")
	var play_control := {
		"exists": is_instance_valid(play),
		"disabled": bool(play.disabled) if is_instance_valid(play) else null,
		"visible": bool(play.is_visible_in_tree()) if is_instance_valid(play) else null,
	}
	if is_instance_valid(play):
		play.pressed.emit()
	await _settle(4)
	var after_play := _snapshot(shell, navigation, viewport)
	var result := {
		"probe": "BCM-M23-R03-M21-720x1440-diagnostic",
		"renderer": "headless GL Compatibility; visual captures unavailable",
		"database_loaded": database_ok,
		"campaign_configured": campaign_ok,
		"navigation_configured": navigation_ok,
		"skip_onboarding_return": skip_result,
		"play_control": play_control,
		"before_skip": before,
		"after_skip": after_skip,
		"after_play": after_play,
		"navigation_result": "PASS" if str(after_play.get("navigation_view", "")) == "WORLD_MAP" else "FAIL",
		"scope": "read-only diagnosis; no M21 production geometry or navigation edits",
	}
	var file := FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(result, "\t") + "\n")
		file.close()
	print("M23_R03_M21_TALL_NAV_DIAGNOSTIC=%s viewport=%s shell=%s campaign=%s nav=%s" % [result.navigation_result, str(viewport.size), str(shell.get_current_view()), str(campaign_ok), str(after_play.get("navigation_view", ""))])
	print(JSON.stringify(result))
	quit(0 if result.navigation_result == "PASS" else 1)


func _snapshot(shell, navigation, viewport: SubViewport) -> Dictionary:
	return {
		"viewport_size": viewport.size,
		"shell_size": shell.size,
		"shell_view": shell.get_current_view(),
		"onboarding_visible": shell.is_onboarding_visible(),
		"main_menu_visible": shell.is_main_menu_visible(),
		"campaign_navigation_visible": navigation.visible if is_instance_valid(navigation) else false,
		"navigation_view": navigation.get_current_view() if is_instance_valid(navigation) else "MISSING",
	}


func _settle(count: int) -> void:
	for _index in range(count):
		await process_frame
