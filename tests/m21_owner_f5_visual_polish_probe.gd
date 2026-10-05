extends SceneTree

## BCM-M21-001-R02 presentation and navigation probe.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const MAP_SCENE := preload("res://scenes/campaign/IslandMapScene.tscn")
const LEVEL_BUTTON_SCENE := preload("res://scenes/campaign/LevelButton.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ISLAND_ID := "m21_polish_fixture"
const EVIDENCE := "res://coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/evidence"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_OWNER_F5_POLISH PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_OWNER_F5_POLISH FAIL: %s" % label)


func _capture(name: String) -> void:
	var viewport_texture := root.get_texture()
	if viewport_texture == null:
		_check("capture %s has an active renderer" % name, false)
		return
	var image: Image = viewport_texture.get_image()
	var path := "%s/%s.png" % [EVIDENCE, name]
	var result := image.save_png(ProjectSettings.globalize_path(path))
	_check("capture %s saved at %dx%d" % [name, image.get_width(), image.get_height()], result == OK)


func _capture_viewport(name: String, viewport: Viewport) -> void:
	var image: Image = viewport.get_texture().get_image()
	var path := "%s/%s.png" % [EVIDENCE, name]
	var result := image.save_png(ProjectSettings.globalize_path(path))
	_check("capture %s saved at %dx%d" % [name, image.get_width(), image.get_height()], result == OK)


func _canonical_campaign():
	var database = DATABASE_SCRIPT.new()
	var loaded: bool = database.load_canonical()
	_check("canonical campaign data loads", loaded)
	var campaign = CAMPAIGN_SCRIPT.new()
	var state := {"schema_version": 2, "unlocked_islands": ["sunny_cove"],
		"islands": {"sunny_cove": {"highest_unlocked_level": 6,
		"completed_levels": {"1": {"completed": true, "stars": 0, "best_score": 0},
			"2": {"completed": true, "stars": 1, "best_score": 125},
			"3": {"completed": true, "stars": 2, "best_score": 200},
			"4": {"completed": true, "stars": 3, "best_score": 300}},
		"claimed_milestones": [], "claimed_star_rewards": []}}, "legacy_best_score": 0,
		"boosters": {}, "coins": 0, "reward_ledger": []}
	_check("canonical campaign configures", campaign.configure(database, state) and campaign.select_level("sunny_cove", 6))
	return [database, campaign]


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE))
	var expected := {
		"LOCKED": "res://assets/ui_assets/campaign/island_map/level_node_locked.png",
		"OPEN": "res://assets/ui_assets/campaign/island_map/level_node_unlocked.png",
		"CURRENT": "res://assets/ui_assets/campaign/island_map/level_node_finale.png",
		"COMPLETE0": "res://assets/ui_assets/campaign/island_map/level_node_completed.png",
		"COMPLETE1": "res://assets/ui_assets/campaign/island_map/level_node_current.png",
		"COMPLETE2": "res://assets/ui_assets/campaign/island_map/level_node_two_star.png",
		"COMPLETE3": "res://assets/ui_assets/campaign/island_map/level_node_milestone.png",
	}
	var button = LEVEL_BUTTON_SCENE.instantiate()
	root.add_child(button)
	await process_frame
	for entry in [
		["LOCKED", "LOCKED", 0], ["OPEN", "OPEN", 0], ["CURRENT", "CURRENT", 0],
		["COMPLETE0", "COMPLETE", 0], ["COMPLETE1", "COMPLETE", 1],
		["COMPLETE2", "COMPLETE", 2], ["COMPLETE3", "COMPLETE", 3],
	]:
		button.configure(ISLAND_ID, 1, entry[1], entry[2], false)
		_check("%s maps to its owner-selected PNG" % entry[0], button.get_skin_path() == expected[entry[0]])
		_check("%s PNG exists and is presented by TextureRect" % entry[0], ResourceLoader.exists(button.get_skin_path()) and button.get_node("NodeArt") is TextureRect)
	_check("LevelButton remains the semantic touch target", button is Button and button.mouse_filter == Control.MOUSE_FILTER_STOP)
	_check("node labels do not steal input", button.get_node("LevelNumber").mouse_filter == Control.MOUSE_FILTER_IGNORE and button.get_node("EarnedStars").mouse_filter == Control.MOUSE_FILTER_IGNORE)
	button.queue_free()

	var pair = _canonical_campaign()
	var database = pair[0]
	var campaign = pair[1]
	var map = MAP_SCENE.instantiate()
	root.add_child(map)
	await process_frame
	_check("canonical Island Map configures", map.configure_island("sunny_cove", database, campaign, {"island_id": "sunny_cove", "selected_level_id": 6, "scroll_focus_level_id": 6, "scroll_vertical": 0}))
	await process_frame
	await process_frame
	_check("map keeps all 100 levels and state/star APIs", map.get_level_button_count() == 100 and map.get_level_state(3) == "COMPLETE" and map.get_level_stars(3) == 2)
	_check("island plaque is visible and centered with current name", map.get_node("IslandMapHeader/IslandNamePlaque").visible and map.get_node("IslandMapHeader/IslandName").text == "SUNNY COVE")
	_check("rejected summary and subtitle are absent", map.get_node_or_null("IslandMapHeader/IslandMapSubtitle") == null and not map.get_node("IslandMapHeader/ProgressSummaryData").visible)
	_check("map scroll begins at the compact header", map.get_node("LevelPathScroll").offset_top == 112.0)
	map.set_scroll_vertical(0)
	_capture("01_island_map_top")
	map.visible = false

	var matrix := Control.new()
	matrix.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(matrix)
	var matrix_backdrop := ColorRect.new()
	matrix_backdrop.name = "StateMatrixBackdrop"
	matrix_backdrop.color = Color("#176b82")
	matrix_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	matrix_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	matrix.add_child(matrix_backdrop)
	var states := [["LOCKED", "LOCKED", 0], ["CURRENT", "CURRENT", 0], ["COMPLETE", "COMPLETE", 0],
		["COMPLETE", "COMPLETE", 1], ["COMPLETE", "COMPLETE", 2], ["COMPLETE", "COMPLETE", 3], ["OPEN", "OPEN", 0]]
	for index in range(states.size()):
		var tile = LEVEL_BUTTON_SCENE.instantiate()
		matrix.add_child(tile)
		tile.position = Vector2(30.0 + float(index % 3) * 220.0, 110.0 + float(index / 3) * 260.0)
		tile.configure(ISLAND_ID, index + 1, states[index][1], states[index][2], index == 4)
	map.visible = false
	await process_frame
	_capture("02_island_map_state_matrix")
	if is_instance_valid(matrix):
		matrix.queue_free()
	if is_instance_valid(map):
		map.queue_free()
	if is_instance_valid(button):
		button.queue_free()
	await process_frame

	var shell: ApplicationShell = SHELL_SCENE.instantiate() as ApplicationShell
	shell.onboarding_storage_path = "user://m21_polish_onboarding.json"
	root.add_child(shell)
	await process_frame
	await process_frame
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	var navigation = shell.get_campaign_navigation()
	_check("shell has canonical home background, logo and separate actions", shell.get_node("MainMenu/MainMenuBackground") is TextureRect and shell.get_node("MainMenu/BeachCocktailsLogo").texture != null and shell.get_menu_controls().has("world_map"))
	_check("decorative menu textures ignore pointer input", shell.get_node("MainMenu/LeftTropicalDecor").mouse_filter == Control.MOUSE_FILTER_IGNORE and shell.get_node("MainMenu/RightTropicalDecor").mouse_filter == Control.MOUSE_FILTER_IGNORE)
	_check("disabled shop/daily buttons do not invent product navigation", shell.get_node("MainMenu/ShopButton").disabled and shell.get_node("MainMenu/DailyRewardsButton").disabled)
	_check("settings remains connected", shell.get_menu_controls()["settings"].pressed.get_connections().size() > 0)
	var menu_pair = _canonical_campaign()
	var menu_database = menu_pair[0]
	var menu_campaign = menu_pair[1]
	_check("canonical campaign installs into the one production router", navigation.configure_campaign(menu_database, menu_campaign))
	shell.show_main_menu()
	_check("Continue label comes from current campaign state", shell.get_node("MainMenu/ContinueLevel").text == "CONTINUE LEVEL 6")
	await process_frame
	await process_frame
	_capture("06_home_720x1280")
	var large_viewport := SubViewport.new()
	large_viewport.name = "Home800Viewport"
	large_viewport.size = Vector2i(800, 1422)
	large_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(large_viewport)
	var large_shell: ApplicationShell = SHELL_SCENE.instantiate() as ApplicationShell
	large_shell.onboarding_storage_path = "user://m21_polish_onboarding_800.json"
	large_viewport.add_child(large_shell)
	await process_frame
	await process_frame
	if large_shell.is_onboarding_visible():
		large_shell.skip_onboarding()
	var large_pair = _canonical_campaign()
	_check("800x1422 Home campaign configures", large_shell.get_campaign_navigation().configure_campaign(large_pair[0], large_pair[1]))
	large_shell.show_main_menu()
	await process_frame
	await process_frame
	_capture_viewport("07_home_800x1422", large_viewport)
	large_shell.queue_free()
	large_viewport.queue_free()
	_check("Home WORLD MAP button opens production World Map", shell.press_world_map() and navigation.get_current_view() == navigation.VIEW_WORLD_MAP)
	await process_frame
	await process_frame
	_capture("08_home_world_map_navigation")
	_check("menu return is available after World Map action", shell.show_main_menu())
	_check("Home PLAY/CONTINUE launches the exact current level", shell.press_play_continue() and navigation.get_current_view() == navigation.VIEW_GAMEPLAY and navigation.get_gameplay_instance_count() == 1)
	await process_frame
	await process_frame
	var gameplay = navigation.get_node_or_null("CampaignGameplay")
	if gameplay != null:
		_check("To-Go panel matches exact +25% 720p geometry", is_equal_approx(gameplay._to_go_panel.size.x, 212.5) and is_equal_approx(gameplay._to_go_panel.size.y, 318.75))
		_check("normal To-Go target uses the shared enlarged scale policy", is_equal_approx(gameplay._to_go_target_sprite.scale.x, gameplay.call("_to_go_cocktail_scale", 6)))
		_check("all progress and reward text scales exactly 1.25", gameplay._to_go_progress_label.scale.is_equal_approx(Vector2.ONE * 1.25) and gameplay._to_go_reward_label.scale.is_equal_approx(Vector2.ONE * 1.25) and gameplay._vip_progress_label.scale.is_equal_approx(Vector2.ONE * 1.25) and gameplay._vip_reward_label.scale.is_equal_approx(Vector2.ONE * 1.25))
		_capture("03_gameplay_to_go_plus25_nonvip")
		_check("VIP level enables panel-local VIP target", menu_database.get_level("sunny_cove", 4).get("vip", {}).get("enabled", false))
	_capture("09_home_play_continue_navigation")
	if navigation.show_world_map():
		menu_campaign.select_level("sunny_cove", 4)
		shell.show_main_menu()
		if shell.press_play_continue():
			await process_frame
			await process_frame
			var vip_gameplay = navigation.get_node_or_null("CampaignGameplay")
			_check("VIP target is visible and uses same 1.25 cocktail scale", vip_gameplay != null and vip_gameplay._vip_target_sprite.visible and vip_gameplay._vip_target_sprite.scale.is_equal_approx(vip_gameplay._to_go_target_sprite.scale))
			_capture("04_gameplay_to_go_plus25_vip")
			navigation.show_world_map()
			menu_campaign.select_level("sunny_cove", 6)
			shell.show_main_menu()
			if shell.press_play_continue():
				await process_frame
				await process_frame
				_capture("05_gameplay_to_go_plus25_nonvip")

	if failures.is_empty():
		print("M21_OWNER_F5_POLISH_RESULT=PASS")
		quit(0)
		return
	print("M21_OWNER_F5_POLISH_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
