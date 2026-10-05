extends SceneTree

## BCM-M21-001-R04 production Home composition and input probe.

const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const LAYOUT_PATH := "res://coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/HOME_TARGET_LAYOUT_R04.json"
const HOME_ROOT := "res://assets/ui_assets/screens/home/"
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/evidence"

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

	await _capture("02_home_reference_941x1672", Vector2i(941, 1672))
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
	await _capture("03_home_720x1280", Vector2i(720, 1280))
	await _capture("04_home_800x1422", Vector2i(800, 1422))
	root.size = Vector2i(720, 1280)
	await _frames()
	var controls: Dictionary = shell.get_menu_controls()
	await _click(controls.play.position + controls.play.size / 2.0)
	_check("PLAY image starts selected campaign level", shell.get_current_view() == "CAMPAIGN" and navigation.current_view == navigation.VIEW_GAMEPLAY)
	await _capture("05_home_play_navigation", Vector2i(720, 1280))
	shell.show_main_menu()
	await _frames()
	controls = shell.get_menu_controls()
	await _click(controls.world_map.position + controls.world_map.size / 2.0)
	_check("WORLD MAP image opens production World Map", shell.get_current_view() == "CAMPAIGN" and navigation.current_view == navigation.VIEW_WORLD_MAP)
	await _capture("06_home_world_map_navigation", Vector2i(720, 1280))
	shell.show_main_menu()
	await _frames()
	controls = shell.get_menu_controls()
	await _click(controls.settings.position + controls.settings.size / 2.0)
	_check("SETTINGS image opens existing Settings", shell.get_current_view() == "SETTINGS" and shell.is_settings_visible())
	await _capture("07_home_settings_navigation", Vector2i(720, 1280))

	shell.queue_free()
	await process_frame
	if failures.is_empty():
		print("M21_HOME_R04_RESULT=PASS")
		quit(0)
		return
	print("M21_HOME_R04_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
