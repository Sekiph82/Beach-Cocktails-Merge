extends SceneTree

## R08 production-path proof for Home frontier display/action and Island Map replay.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M21-HOME-FRONTIER-R08/evidence"

var failures: Array[String] = []
var shell: ApplicationShell


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_HOME_FRONTIER_R08 PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_HOME_FRONTIER_R08 FAIL: %s" % label)


func _frames(count: int = 4) -> void:
	for _index in range(count):
		await process_frame


func _mouse_click(position: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = position
	root.get_viewport().push_input(motion, true)
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = position
	down.pressed = true
	root.get_viewport().push_input(down, true)
	var up := down.duplicate() as InputEventMouseButton
	up.pressed = false
	root.get_viewport().push_input(up, true)
	await _frames(4)


func _touch_tap(position: Vector2) -> void:
	var down := InputEventScreenTouch.new()
	down.index = 0
	down.position = position
	down.pressed = true
	root.get_viewport().push_input(down, true)
	var up := down.duplicate() as InputEventScreenTouch
	up.pressed = false
	root.get_viewport().push_input(up, true)
	await _frames(4)


func _assert_home_frontier(level_id: int, label: String) -> void:
	_check("%s: visible Home LEVEL uses frontier %d" % [label, level_id], shell._home_value_labels.level.text == str(level_id))
	_check("%s: PLAY plaque uses LEVEL %d" % [label, level_id], shell._home_value_labels.continue.text == "LEVEL %d" % level_id)


func _return_home() -> void:
	_check("production shell returns from gameplay to Home", shell.show_main_menu())
	await _frames()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	root.size = Vector2i(720, 1280)
	shell = SHELL_SCENE.instantiate() as ApplicationShell
	shell.onboarding_storage_path = "user://m21_home_frontier_r08_onboarding.json"
	shell.settings_storage_path = "user://m21_home_frontier_r08_settings.json"
	root.add_child(shell)
	await _frames(8)
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	await _frames()
	var navigation: CampaignNavigationController = shell.get_campaign_navigation()
	var database = DATABASE_SCRIPT.new()
	var state := {
		"schema_version": 2,
		"unlocked_islands": ["sunny_cove"],
		"islands": {"sunny_cove": {"highest_unlocked_level": 11, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}},
		"legacy_best_score": 0,
		"boosters": {},
		"coins": 0,
		"reward_ledger": [],
	}
	var campaign = CAMPAIGN_SCRIPT.new()
	_check("canonical campaign data loads", database.load_canonical())
	_check("fixture configures frontier 11", campaign.configure(database, state) and campaign.get_frontier_level_id("sunny_cove") == 11)
	_check("production application shell accepts the fixture", navigation.configure_campaign(database, campaign))
	_check("old unlocked replay level 4 can be selected", campaign.select_level("sunny_cove", 4) and campaign.selected_level_id == 4)
	shell._refresh_home_values()
	_assert_home_frontier(11, "frontier 11 with replay level 4 selected")

	var controls: Dictionary = shell.get_menu_controls()
	await _mouse_click((controls.play as Control).get_global_rect().get_center())
	_check("real Home PLAY mouse input launches active gameplay level 11", shell.get_current_view() == "CAMPAIGN" and navigation.current_view == navigation.VIEW_GAMEPLAY and navigation._session_bridge.active_level_id == 11)
	_check("Home PLAY uses frontier 11 while the old replay selection remains 4", campaign.selected_level_id == 4 and campaign.get_frontier_level_id("sunny_cove") == 11 and navigation._session_bridge.active_level_id == 11)

	await _return_home()
	controls = shell.get_menu_controls()
	await _mouse_click((controls.world_map as Control).get_global_rect().get_center())
	_check("Home WORLD MAP control opens production World Map for replay path", navigation.current_view == navigation.VIEW_WORLD_MAP and navigation.get_world_map().visible)
	var world = navigation.get_world_map()
	var sunny_center: Vector2 = world.get_entry("sunny_cove").get_global_rect().get_center()
	await _mouse_click(sunny_center)
	_check("real World Map input opens Sunny Cove Island Map", navigation.current_view == navigation.VIEW_ISLAND_MAP and navigation.get_active_island_id() == "sunny_cove" and navigation.get_island_map().visible)
	var island_map = navigation.get_island_map()
	island_map._scroll.scroll_vertical = 0
	await _frames(3)
	var replay_center: Vector2 = island_map.get_level_button(4).get_global_rect().get_center()
	await _mouse_click(replay_center)
	_check("real Island Map level 4 click still launches explicit replay level 4", navigation.current_view == navigation.VIEW_GAMEPLAY and navigation._session_bridge.active_level_id == 4 and campaign.selected_level_id == 4)
	_check("level 4 replay leaves frontier at 11", campaign.get_frontier_level_id("sunny_cove") == 11)

	await _return_home()
	_assert_home_frontier(11, "Home after returning from level 4 replay")
	controls = shell.get_menu_controls()
	await _touch_tap((controls.play as Control).get_global_rect().get_center())
	_check("real Home PLAY touch input returns to frontier level 11", navigation.current_view == navigation.VIEW_GAMEPLAY and navigation._session_bridge.active_level_id == 11 and campaign.get_frontier_level_id("sunny_cove") == 11)

	var completion: Dictionary = campaign.mark_level_completed("sunny_cove", 11, {"stars": 1, "score": 1100})
	_check("completing frontier 11 advances campaign frontier to 12", completion.get("ok", false) and campaign.get_frontier_level_id("sunny_cove") == 12)
	await _return_home()
	_assert_home_frontier(12, "Home after completing frontier 11")
	controls = shell.get_menu_controls()
	await _touch_tap((controls.play as Control).get_global_rect().get_center())
	_check("real Home PLAY touch input launches active gameplay level 12", navigation.current_view == navigation.VIEW_GAMEPLAY and navigation._session_bridge.active_level_id == 12 and campaign.get_frontier_level_id("sunny_cove") == 12)

	if failures.is_empty():
		print("M21_HOME_FRONTIER_R08_RESULT=PASS frontier=11 replay=4 advanced_frontier=12")
		quit(0)
		return
	print("M21_HOME_FRONTIER_R08_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
