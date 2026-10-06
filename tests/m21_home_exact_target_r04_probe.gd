extends SceneTree

## BCM-M21-001-R04 production Home composition and input probe.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const LAYOUT_PATH := "res://coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/HOME_TARGET_LAYOUT_R04.json"
const HOME_ROOT := "res://assets/ui_assets/screens/home/"
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence/owner-critique-v04"

var failures: Array[String] = []
var shell


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_HOME_R04 PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_HOME_R04 FAIL: %s" % label)


func _frames(count: int = 3) -> void:
	for _index in range(count):
		await process_frame


func _capture(name: String, size: Vector2i) -> Image:
	root.content_scale_size = size
	root.size = size
	await _frames(3)
	var viewport_texture := root.get_viewport().get_texture()
	if viewport_texture == null:
		_check("renderer provides an actual production viewport texture", false)
		return Image.new()
	var result := viewport_texture.get_image()
	if result.is_empty():
		_check("renderer returns non-empty production pixels", false)
		return result
	var error := result.save_png(ProjectSettings.globalize_path("%s/%s.png" % [EVIDENCE_DIR, name]))
	_check("saved %s at %dx%d" % [name, size.x, size.y], error == OK and result.get_size() == size)
	return result


func _click(position: Vector2) -> void:
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


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH))
	_check("layout JSON loads", parsed is Dictionary)
	var layout: Dictionary = parsed if parsed is Dictionary else {}
	var reference_size: Dictionary = layout.get("reference_size", {})
	_check("layout uses 941x1672 reference", int(reference_size.get("width", 0)) == 941 and int(reference_size.get("height", 0)) == 1672)
	root.size = Vector2i(720, 1280)
	shell = SHELL_SCENE.instantiate()
	shell.onboarding_storage_path = "user://m21_home_exact_target_r04_onboarding.json"
	root.add_child(shell)
	await _frames(4)
	if shell.is_onboarding_visible():
		shell.skip_onboarding()
	await _frames()
	var navigation = shell.get_campaign_navigation()
	var database = DATABASE_SCRIPT.new()
	_check("canonical campaign data loads", database.load_canonical())
	var campaign = CAMPAIGN_SCRIPT.new()
	var state := {
		"schema_version": 2,
		"unlocked_islands": ["sunny_cove"],
		"islands": {"sunny_cove": {"highest_unlocked_level": 12, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}},
		"legacy_best_score": 0,
		"boosters": {},
		"coins": 4250,
		"reward_ledger": [],
	}
	_check("fixture campaign configures", campaign.configure(database, state))
	_check("existing navigation accepts deterministic fixture", navigation.configure_campaign(database, campaign))
	navigation.economy.coins = 4250
	shell._refresh_home_values()
	_check("fixture selected level is 12", campaign.selected_level_id == 12)
	_check("Level and Continue use live level 12", shell._home_value_labels.level.text == "12" and shell._home_value_labels.continue.text == "CONTINUE LEVEL 12")
	_check("coins bind to canonical economy and format 4250 as 4.250", shell._home_value_labels.coins.text == "4.250" and navigation.economy.coins == 4250)
	_check("energy and gems are display-only 100 and 85", shell._home_value_labels.energy.text == "100" and shell._home_value_labels.gems.text == "85")
	_check("Level and Continue update with a different live selected level", campaign.select_level("sunny_cove", 7))
	shell._refresh_home_values()
	_check("dynamic level change is not fixed to 12", shell._home_value_labels.level.text == "7" and shell._home_value_labels.continue.text == "CONTINUE LEVEL 7")
	_check("fixture returns to target level 12", campaign.select_level("sunny_cove", 12))
	shell._refresh_home_values()
	campaign.select_level("sunny_cove", 12)

	var expected_counts := {"home background.png": 1, "level bari.png": 1, "enerji bari.png": 1, "coin bari.png": 1, "elmas bari.png": 1, "ekle gorseli.png": 3, "settings.png": 1, "play butonu.png": 1, "world map.png": 1, "shop.png": 1, "Events.png": 1, "daily rewards.png": 1, "achievements.png": 1}
	var observed_counts: Dictionary = {}
	for child in shell._menu_layer.get_children():
		var path := ""
		if child is TextureRect and child.texture != null:
			path = child.texture.resource_path
		elif child is TextureButton and child.texture_normal != null:
			path = child.texture_normal.resource_path
		if path.begins_with(HOME_ROOT):
			var file_name := path.trim_prefix(HOME_ROOT)
			observed_counts[file_name] = int(observed_counts.get(file_name, 0)) + 1
	_check("all supplied runtime images have exact occurrence counts", observed_counts == expected_counts)
	_check("reference TARGET is never a runtime texture", not observed_counts.has("TARGET beach cocktails merge home.png"))
	_check("old R02 composition nodes are absent", shell._menu_layer.find_child("TropicalSkyOceanUnderlay", true, false) == null and shell._menu_layer.find_child("BeachCocktailsLogo", true, false) == null and shell._menu_layer.find_child("LeftTropicalDecor", true, false) == null and shell._menu_layer.find_child("RightTropicalDecor", true, false) == null)
	_check("three action images are distinct input controls", shell.get_menu_controls().play is TextureButton and shell.get_menu_controls().world_map is TextureButton and shell.get_menu_controls().settings is TextureButton and shell.get_menu_controls().play != shell.get_menu_controls().world_map and shell.get_menu_controls().world_map != shell.get_menu_controls().settings)
	_check("layout asset count matches runtime visual count", layout.get("items", []).size() == 15)
	var layout_items: Dictionary = {}
	for item_value in layout.get("items", []):
		var item: Dictionary = item_value
		layout_items[str(item.get("id", ""))] = item
	var expected_bar_rects := {"level_bar": Vector2(179.25, 89.0), "energy_bar": Vector2(136.125, 81.0), "coin_bar": Vector2(203.4375, 81.0), "diamond_bar": Vector2(165.75, 82.0)}
	for bar_id in expected_bar_rects:
		var bar_rect: Dictionary = layout_items.get(bar_id, {}).get("target_rect", {})
		var expected_bar: Vector2 = expected_bar_rects[bar_id]
		_check("%s has its owner-directed width and preserved height" % bar_id, absf(float(bar_rect.get("width", 0.0)) - expected_bar.x) < 0.01 and absf(float(bar_rect.get("height", 0.0)) - expected_bar.y) < 0.01)
	var energy_rect: Dictionary = layout_items.get("energy_bar", {}).get("target_rect", {})
	var coin_rect: Dictionary = layout_items.get("coin_bar", {}).get("target_rect", {})
	_check("Energy width is 25% smaller than V03 and its right endpoint is fixed", absf(float(energy_rect.get("width", 0.0)) - 181.5 * 0.75) < 0.01 and absf(float(energy_rect.get("x", 0.0)) + float(energy_rect.get("width", 0.0)) - 410.5) < 0.01)
	_check("Coin width is 25% larger than V03 and its right endpoint is fixed", absf(float(coin_rect.get("width", 0.0)) - 162.75 * 1.25) < 0.01 and absf(float(coin_rect.get("x", 0.0)) + float(coin_rect.get("width", 0.0)) - 606.75) < 0.01)
	var plus_centers := {"energy_plus": 393.0, "coin_plus": 589.0, "diamond_plus": 802.0}
	var plus_bars := {"energy_plus": "energy_bar", "coin_plus": "coin_bar", "diamond_plus": "diamond_bar"}
	var plus_alignment := true
	for plus_id in plus_centers:
		var plus_rect: Dictionary = layout_items.get(plus_id, {}).get("target_rect", {})
		var matching_bar: Dictionary = layout_items.get(plus_bars[plus_id], {}).get("target_rect", {})
		var plus_center := Vector2(float(plus_rect.get("x", 0.0)) + float(plus_rect.get("width", 0.0)) / 2.0, float(plus_rect.get("y", 0.0)) + float(plus_rect.get("height", 0.0)) / 2.0)
		var bar_center_y := float(matching_bar.get("y", 0.0)) + float(matching_bar.get("height", 0.0)) / 2.0
		if absf(plus_center.x - float(plus_centers[plus_id])) > 0.01 or absf(plus_center.y - bar_center_y) > 0.01:
			plus_alignment = false
	_check("three white plus centers align to owner lines and icon centers match bar midlines", plus_alignment)
	var play_rect: Dictionary = layout_items.get("play", {}).get("target_rect", {})
	var world_rect: Dictionary = layout_items.get("world_map", {}).get("target_rect", {})
	var action_ids := ["play", "world_map", "shop", "events", "daily_rewards", "achievements"]
	var action_scale_consistent := true
	for action_id in action_ids:
		var rect: Dictionary = layout_items.get(action_id, {}).get("target_rect", {})
		var base_rect: Dictionary = {"play": {"x": 118.0, "y": 945.0, "width": 698.0, "height": 299.0}, "world_map": {"x": 110.0, "y": 1196.0, "width": 730.0, "height": 243.0}, "shop": {"x": 67.0, "y": 1417.0, "width": 164.0, "height": 150.0}, "events": {"x": 269.0, "y": 1417.0, "width": 164.0, "height": 150.0}, "daily_rewards": {"x": 469.0, "y": 1417.0, "width": 160.0, "height": 158.0}, "achievements": {"x": 672.0, "y": 1417.0, "width": 164.0, "height": 150.0}}[action_id]
		var scale_x := float(rect.get("width", 0.0)) / float(base_rect.width)
		var scale_y := float(rect.get("height", 0.0)) / float(base_rect.height)
		var center_x := float(rect.get("x", 0.0)) + float(rect.get("width", 0.0)) / 2.0
		var expected_center_x := 470.5 + (float(base_rect.x) + float(base_rect.width) / 2.0 - 470.5) * (6.0 / 7.0)
		if absf(scale_x - 6.0 / 7.0) > 0.002 or absf(scale_y - 6.0 / 7.0) > 0.002 or absf(center_x - expected_center_x) > 0.02:
			action_scale_consistent = false
	_check("all six lower actions retain their relative layout at a uniform 6/7 scale", action_scale_consistent)
	_check("PLAY starts at the owner's marked y=1050 line", absf(float(play_rect.get("y", 0.0)) - 1050.0) < 0.01)
	var lower_group_bottom := 0.0
	for action_id in action_ids:
		var rect: Dictionary = layout_items.get(action_id, {}).get("target_rect", {})
		lower_group_bottom = maxf(lower_group_bottom, float(rect.get("y", 0.0)) + float(rect.get("height", 0.0)))
	_check("lower action group ends at the marked y=1590 bottom", absf(lower_group_bottom - 1590.0) < 0.02)
	var continue_rect: Dictionary = layout.get("dynamic_text", []).filter(func(entry): return entry.get("id", "") == "continue")[0].target_rect
	var continue_center := Vector2(float(continue_rect.x) + float(continue_rect.width) / 2.0, float(continue_rect.y) + float(continue_rect.height) / 2.0)
	_check("Continue label is centered horizontally and raised 12 px total", continue_center.distance_to(Vector2(467.5, 1224.857)) < 0.02)
	_check("Continue label uses the requested smaller 23 px font", int(layout.get("dynamic_text", []).filter(func(entry): return entry.get("id", "") == "continue")[0].font_size) == 23)

	await _capture("02_home_owner_critique_v04_941x1672", Vector2i(941, 1672))
	var rects_match := true
	for item_value in layout.get("items", []):
		var item: Dictionary = item_value
		var normalized: Dictionary = item.get("normalized_rect", {})
		var visual = shell._home_layout_nodes.get(str(item.get("id", "")))
		if not is_instance_valid(visual):
			rects_match = false
			continue
		var expected_pos := Vector2(float(normalized.get("x", -10.0)) * 941.0, float(normalized.get("y", -10.0)) * 1672.0)
		var expected_size := Vector2(float(normalized.get("width", -10.0)) * 941.0, float(normalized.get("height", -10.0)) * 1672.0)
		if visual.position.distance_to(expected_pos) > 1.0 or visual.size.distance_to(expected_size) > 1.0:
			print("M21_HOME_R04_RECT: %s actual=%s/%s expected=%s/%s" % [item.get("id", ""), str(visual.position), str(visual.size), str(expected_pos), str(expected_size)])
			rects_match = false
	_check("all production art rects match normalized layout at 941x1672", rects_match)
	await _capture("03_home_owner_critique_v04_720x1280", Vector2i(720, 1280))
	await _capture("04_home_owner_critique_v04_800x1422", Vector2i(800, 1422))
	root.size = Vector2i(720, 1280)
	await _frames()
	var controls: Dictionary = shell.get_menu_controls()
	_check("current player level 7 is available for the welcome-screen Continue action", campaign.select_level("sunny_cove", 7))
	shell._refresh_home_values()
	_check("welcome screen Continue text reflects the player's current level 7", shell._home_value_labels.continue.text == "CONTINUE LEVEL 7")
	controls = shell.get_menu_controls()
	await _click(controls.play.position + controls.play.size / 2.0)
	_check("PLAY image resumes the player's current level 7", shell.get_current_view() == "CAMPAIGN" and navigation.current_view == navigation.VIEW_GAMEPLAY and navigation._session_bridge.active_level_id == 7)
	await _capture("05_home_owner_critique_v04_play_navigation", Vector2i(720, 1280))
	shell.show_main_menu()
	await _frames()
	controls = shell.get_menu_controls()
	await _click(controls.world_map.position + controls.world_map.size / 2.0)
	_check("WORLD MAP image opens and displays production World Map", shell.get_current_view() == "CAMPAIGN" and navigation.current_view == navigation.VIEW_WORLD_MAP and navigation._world_map.visible)
	await _capture("06_home_owner_critique_v04_world_map_navigation", Vector2i(720, 1280))
	shell.show_main_menu()
	await _frames()
	controls = shell.get_menu_controls()
	await _click(controls.settings.position + controls.settings.size / 2.0)
	_check("SETTINGS image opens existing Settings", shell.get_current_view() == "SETTINGS" and shell.is_settings_visible())
	await _capture("07_home_owner_critique_v04_settings_navigation", Vector2i(720, 1280))

	shell.queue_free()
	await process_frame
	if failures.is_empty():
		print("M21_HOME_R04_RESULT=PASS")
		quit(0)
		return
	print("M21_HOME_R04_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
