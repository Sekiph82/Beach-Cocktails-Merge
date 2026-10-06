extends SceneTree

## Owner-directed follow-up proving complete Sunny Cove map art and aligned nodes.

const ISLAND_MAP_SCENE := preload("res://scenes/campaign/IslandMapScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/evidence/followup-full-background-r01"
const EXPECTED_CENTERS := [
	Vector2(353.0, 272.0), Vector2(647.0, 327.0), Vector2(169.0, 427.0),
	Vector2(402.0, 486.0), Vector2(616.0, 586.0), Vector2(66.0, 664.0),
	Vector2(642.0, 789.0), Vector2(386.0, 839.0), Vector2(162.0, 942.0),
	Vector2(553.0, 1078.0),
]

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_FULL_BACKGROUND_R01 PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_FULL_BACKGROUND_R01 FAIL: %s" % label)


func _frames(count: int = 4) -> void:
	for _index in range(count):
		await process_frame


func _capture(file_name: String) -> void:
	await _frames()
	var image := root.get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [EVIDENCE_DIR, file_name]
	_check("saved full 720x1280 production page %s" % file_name, image.get_size() == Vector2i(720, 1280) and image.save_png(ProjectSettings.globalize_path(path)) == OK)


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	root.size = Vector2i(720, 1280)
	var database = DATABASE_SCRIPT.new()
	_check("canonical Sunny Cove data loads", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
	var campaign = CAMPAIGN_SCRIPT.new()
	var state := {
		"schema_version": 2,
		"unlocked_islands": ["sunny_cove"],
		"islands": {"sunny_cove": {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}},
		"legacy_best_score": 0,
		"boosters": {},
		"coins": 0,
		"reward_ledger": [],
	}
	_check("production campaign configures", campaign.configure(database, state))
	var map = ISLAND_MAP_SCENE.instantiate()
	_check("production Sunny Cove Island Map configures", map.configure_island("sunny_cove", database, campaign))
	root.add_child(map)
	await _frames(6)

	var layout: Dictionary = database.get_island("sunny_cove").get("island_map_layout", {})
	var page_height := float(layout.get("page_height", 0.0))
	var page_size := int(layout.get("page_size", 0))
	_check("each ten-level map page uses the full 1280px source height", page_size == 10 and page_height == 1280.0 and float(layout.get("background_origin_y", -1.0)) == 0.0)
	_check("full-height map scroller leaves background visible behind fixed header/footer", map._scroll.get_rect().position == Vector2.ZERO and is_equal_approx(map._scroll.size.y, 1280.0) and map._scroll.offset_top == 0.0 and map._scroll.offset_bottom == 0.0)
	_check("all ten page backgrounds render the complete native-size source", map._page_backgrounds.size() == 10)
	var backgrounds_ok: bool = map._page_backgrounds.size() == 10
	for page in range(mini(10, map._page_backgrounds.size())):
		var background: TextureRect = map._page_backgrounds[page]
		backgrounds_ok = backgrounds_ok and background.texture.get_size() == Vector2(720.0, 1280.0)
		backgrounds_ok = backgrounds_ok and background.position == Vector2(0.0, float(page) * 1280.0)
		backgrounds_ok = backgrounds_ok and background.size == Vector2(720.0, 1280.0)
	_check("every background covers its whole page without crop or seam offset", backgrounds_ok)
	_check("header sky wash no longer covers the background's top pixels", is_equal_approx(map.get_node("IslandMapHeader/IslandMapSkyBand").modulate.a, 0.0))

	var landmarks: Array = layout.get("landmark_centers", [])
	var nodes_ok: bool = landmarks.size() == 10
	for level_id in range(1, 11):
		var expected: Vector2 = EXPECTED_CENTERS[level_id - 1]
		var actual: Vector2 = map.get_level_button(level_id).get_global_rect().get_center()
		nodes_ok = nodes_ok and actual.distance_to(expected) <= 1.0
		nodes_ok = nodes_ok and Vector2(float(landmarks[level_id - 1][0]), float(landmarks[level_id - 1][1])) == expected
		nodes_ok = nodes_ok and map.get_level_button(level_id).get_global_rect().position.y >= 0.0
		nodes_ok = nodes_ok and map.get_level_button(level_id).get_global_rect().end.y <= 1280.0
	_check("all ten node hit targets align to full-image landmarks and fit the page", nodes_ok)
	_check("page-one first and tenth levels remain fully visible at natural image scale", map.get_level_button(1).get_global_rect().position.y >= 0.0 and map.get_level_button(10).get_global_rect().end.y <= map._scroll.size.y)
	await _capture("sunny_cove_full_background_page_01")

	var progression_ok := true
	for level_id in range(1, 91):
		var completion: Dictionary = campaign.mark_level_completed("sunny_cove", level_id, {"stars": 1, "score": 0})
		progression_ok = progression_ok and bool(completion.get("ok", false))
	_check("production campaign advances through level 90", progression_ok and campaign.get_frontier_level_id("sunny_cove") == 91)
	_check("production Island Map reopens at the new last-page frontier", map.configure_island("sunny_cove", database, campaign))
	await _frames(6)
	_check("page ten presents level 91–100 over its full background", map._scroll.scroll_vertical == 9 * int(page_height) and map.get_level_button(91).get_global_rect().position.y >= 0.0 and map.get_level_button(100).get_global_rect().end.y <= map._scroll.size.y)
	await _capture("sunny_cove_full_background_page_10")

	if failures.is_empty():
		print("M21_FULL_BACKGROUND_R01_RESULT=PASS pages=10 levels_per_page=10 background=720x1280")
		quit(0)
		return
	print("M21_FULL_BACKGROUND_R01_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
