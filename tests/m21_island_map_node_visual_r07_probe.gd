extends SceneTree

## R07 production Island Map node label, star and marker contract.

const ISLAND_ID := "sunny_cove"
const ISLAND_MAP_SCENE := preload("res://scenes/campaign/IslandMapScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/evidence"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_ISLAND_MAP_NODE_R07 PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_ISLAND_MAP_NODE_R07 FAIL: %s" % label)


func _frames(count: int = 3) -> void:
	for _index in range(count):
		await process_frame


func _capture_full(map) -> Image:
	await _frames()
	var image := root.get_viewport().get_texture().get_image()
	_check("levels 1–10 production page screenshot saved", not image.is_empty() and image.save_png(ProjectSettings.globalize_path("%s/island_map_levels_1_10.png" % EVIDENCE_DIR)) == OK)
	return image


func _capture_crop(image: Image, button, file_name: String) -> void:
	var rect: Rect2 = button.get_global_rect()
	var left := maxi(0, int(floor(rect.position.x - 20.0)))
	var top := maxi(0, int(floor(rect.position.y - 20.0)))
	var right := mini(image.get_width(), int(ceil(rect.end.x + 20.0)))
	var bottom := mini(image.get_height(), int(ceil(rect.end.y + 20.0)))
	var crop_rect := Rect2i(left, top, right - left, bottom - top)
	var crop := image.get_region(crop_rect)
	var path := "%s/%s.png" % [EVIDENCE_DIR, file_name]
	_check("close crop saved: %s" % file_name, not crop.is_empty() and crop.save_png(ProjectSettings.globalize_path(path)) == OK)


func _record(stars: int, score: int) -> Dictionary:
	return {"completed": true, "stars": stars, "best_score": score}


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	root.size = Vector2i(720, 1280)
	var database = DATABASE_SCRIPT.new()
	_check("canonical database passes full validation", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
	var campaign = CAMPAIGN_SCRIPT.new()
	var state := {
		"schema_version": 2,
		"unlocked_islands": [ISLAND_ID],
		"islands": {ISLAND_ID: {"highest_unlocked_level": 6, "completed_levels": {"1": _record(1, 101), "2": _record(2, 202), "3": _record(3, 303), "4": {"completed": true, "stars": 3, "best_score": 404, "vip_completed": true}}, "claimed_milestones": [], "claimed_star_rewards": []}},
		"legacy_best_score": 0,
		"boosters": {},
		"coins": 0,
		"reward_ledger": [],
	}
	_check("production campaign fixture configures at frontier 6", campaign.configure(database, state))
	var map = ISLAND_MAP_SCENE.instantiate()
	_check("production Sunny Cove map configures", map.configure_island(ISLAND_ID, database, campaign))
	root.add_child(map)
	await _frames(5)
	var plaque: TextureRect = map.get_node("IslandMapHeader/IslandNamePlaque")
	var title: Label = map.get_node("IslandMapHeader/IslandName")
	var texture_scale := minf(plaque.size.x / 440.0, plaque.size.y / 190.0)
	var displayed_texture_size := Vector2(440.0, 190.0) * texture_scale
	var displayed_texture_origin := plaque.position + (plaque.size - displayed_texture_size) * 0.5
	var inner_rect := Rect2(displayed_texture_origin + Vector2(74.0, 65.0) * texture_scale, Vector2(291.0, 66.0) * texture_scale)
	var header: Control = map.get_node("IslandMapHeader")
	var title_center_error := title.get_global_rect().get_center().distance_to(header.get_global_rect().position + inner_rect.get_center())
	_check("Sunny Cove title center is within 2px of plaque inner center", title_center_error <= 2.0)
	_check("Sunny Cove title fits inside plaque inner frame", title.get_minimum_size().x <= title.size.x and title.get_minimum_size().y <= title.size.y)
	_check("actual map exposes all 100 production level nodes", map.get_level_button_count() == 100)
	var labels_ok := true
	var stars_ok := true
	var no_best_ui := true
	var level_font_ok := true
	var star_font_ok := true
	var outline_ok := true
	for level_id in range(1, 101):
		var button = map.get_level_button(level_id)
		var level_label: Label = button.get_node("LevelNumber")
		var stars_label: Label = button.get_node("EarnedStars")
		labels_ok = labels_ok and level_label.text == "LV%d" % level_id
		stars_ok = stars_ok and stars_label.text.length() == 3
		no_best_ui = no_best_ui and button.get_node_or_null("BestScore") == null and not button.tooltip_text.contains("Best score")
		level_font_ok = level_font_ok and level_label.get_theme_font_size("font_size") >= 24
		star_font_ok = star_font_ok and stars_label.get_theme_font_size("font_size") >= 20
		outline_ok = outline_ok and level_label.get_theme_constant("outline_size") >= 2 and stars_label.get_theme_constant("outline_size") >= 2
	_check("all nodes use dynamic LV1–LV100 labels", labels_ok)
	_check("all nodes always show exactly three star positions", stars_ok)
	_check("BEST/SCORE node UI and tooltip text are absent", no_best_ui)
	_check("LV labels are at least 24 reference px", level_font_ok)
	_check("star labels are at least 20 reference px", star_font_ok)
	_check("LV and star labels use strong font outlines", outline_ok)
	_check("one-star completed label is ★☆☆", map.get_level_button(1).get_node("EarnedStars").text == "★☆☆")
	_check("two-star completed label is ★★☆", map.get_level_button(2).get_node("EarnedStars").text == "★★☆")
	_check("three-star completed label is ★★★", map.get_level_button(3).get_node("EarnedStars").text == "★★★")
	_check("VIP-complete node retains its three-star mastery", map.get_level_button(4).get_node("EarnedStars").text == "★★★" and map.get_level_button(4).is_vip_marker_visible())
	_check("open node shows ☆☆☆", map.get_level_button(5).get_node("EarnedStars").text == "☆☆☆" and map.get_level_state(5) == "OPEN")
	_check("current node shows ☆☆☆", map.get_level_button(6).get_node("EarnedStars").text == "☆☆☆" and map.get_level_state(6) == "CURRENT")
	_check("locked node shows subdued ☆☆☆", map.get_level_button(7).get_node("EarnedStars").text == "☆☆☆" and map.get_level_state(7) == "LOCKED" and map.get_level_button(7).get_node("EarnedStars").get_theme_color("font_color") == Color("#c4d0d1"))
	_check("milestone chest marker remains separate", map.get_level_button(10).get_node("MilestoneMarker").visible and map.is_level_milestone(10))
	_check("VIP marker remains separate on a VIP node", map.get_level_button(4).is_vip_marker_visible() and map.get_level_button(4).get_node_or_null("BestScore") == null)
	_check("best score remains available internally", map.get_level_button(3).get_best_score() == 303)
	_check("existing node art remains in use", map.get_level_button(2).get_skin_path().ends_with("level_node_two_star.png"))
	_check("focus exposes LV100 text", map.get_level_button(100).get_node("LevelNumber").text == "LV100")
	var image := await _capture_full(map)
	_capture_crop(image, map.get_level_button(1), "node_completed_1_star")
	_capture_crop(image, map.get_level_button(2), "node_completed_2_star")
	_capture_crop(image, map.get_level_button(3), "node_completed_3_star")
	_capture_crop(image, map.get_level_button(5), "node_open")
	_capture_crop(image, map.get_level_button(4), "node_vip_complete_3_star")
	_capture_crop(image, map.get_level_button(6), "node_current_open")
	_capture_crop(image, map.get_level_button(7), "node_locked")
	_capture_crop(image, map.get_level_button(10), "node_milestone")
	var selected: Array[int] = []
	map.level_selected.connect(func(_island: String, level_id: int) -> void: selected.append(level_id))
	_check("node still accepts selection input", map.select_level(4) and selected == [4])
	map.queue_free()
	await _frames()
	if failures.is_empty():
		print("M21_ISLAND_MAP_NODE_R07_RESULT=PASS")
		quit(0)
		return
	print("M21_ISLAND_MAP_NODE_R07_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
