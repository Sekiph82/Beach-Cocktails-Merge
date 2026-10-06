extends SceneTree

## R07 progression/restoration probe against the production navigation and map.

const ISLAND_ID := "sunny_cove"
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const BOUNDARIES := [10, 20, 30, 40, 50, 60, 70, 80, 90]
const EVIDENCE_DIR := "res://coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/evidence"

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M21_ISLAND_MAP_PAGE_R07 PASS: %s" % label)
	else:
		failures.append(label)
		print("M21_ISLAND_MAP_PAGE_R07 FAIL: %s" % label)


func _frames(count: int = 3) -> void:
	for _index in range(count):
		await process_frame


func _state(frontier: int) -> Dictionary:
	var completed := {}
	for level_id in range(1, frontier):
		completed[str(level_id)] = {"completed": true, "stars": 1, "best_score": 100}
	return {
		"schema_version": 2,
		"unlocked_islands": [ISLAND_ID],
		"islands": {ISLAND_ID: {"highest_unlocked_level": frontier, "completed_levels": completed, "claimed_milestones": [], "claimed_star_rewards": []}},
		"legacy_best_score": 0,
		"boosters": {},
		"coins": 0,
		"reward_ledger": [],
	}


func _map_for(database, campaign):
	var navigation = NAVIGATION_SCENE.instantiate()
	_check("production navigation accepts boundary fixture", navigation.configure_campaign(database, campaign))
	root.add_child(navigation)
	await _frames()
	_check("production Sunny Cove Island Map opens", navigation.show_island_map(ISLAND_ID))
	await _frames()
	return navigation


func _capture(name: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [EVIDENCE_DIR, name]
	_check("saved actual production viewport %s" % name, not image.is_empty() and image.save_png(ProjectSettings.globalize_path(path)) == OK)


func _verify_boundary(database, boundary: int) -> void:
	var campaign = CAMPAIGN_SCRIPT.new()
	_check("campaign configures at frontier %d" % boundary, campaign.configure(database, _state(boundary)))
	var navigation = await _map_for(database, campaign)
	var map = navigation.get_island_map()
	_check("before completion focus is level %d" % boundary, map.get_focus_level_id() == boundary)
	var old_restoration: Dictionary = map.get_restoration_state()
	_check("old map state records frontier %d" % boundary, int(old_restoration.get("frontier_level_id", 0)) == boundary)
	_check("production route stores old-page restoration", navigation.show_world_map())
	var completion: Dictionary = campaign.mark_level_completed(ISLAND_ID, boundary, {"stars": 1, "score": 100})
	_check("first completion %d unlocks %d" % [boundary, boundary + 1], completion.get("ok", false) and campaign.get_frontier_level_id(ISLAND_ID) == boundary + 1)
	_check("production route returns to Island Map", navigation.show_island_map(ISLAND_ID))
	await _frames(5)
	map = navigation.get_island_map()
	var page_size := int(map.get_layout_report()["page_size"])
	var page_height := float(map._active_layout.get("page_height", 0.0))
	var expected_page_top := int(floor(float(boundary) / float(page_size)) * page_height)
	var max_scroll := maxi(0, int(map._content.size.y - map._scroll.size.y))
	var expected_scroll := mini(expected_page_top, max_scroll)
	_check("%d→%d focuses new frontier" % [boundary, boundary + 1], map.get_focus_level_id() == boundary + 1)
	_check("%d→%d scrolls to new page top" % [boundary, boundary + 1], map.get_scroll_vertical() == expected_scroll)
	var focus_button = map.get_level_button(boundary + 1)
	var visible_rect: Rect2 = focus_button.get_global_rect().intersection(map._scroll.get_global_rect())
	_check("new frontier node %d is visible without manual scroll" % (boundary + 1), visible_rect.has_area())
	if boundary == 10:
		await _capture("frontier_10_to_11")
	elif boundary == 20:
		await _capture("frontier_20_to_21")
	elif boundary == 90:
		await _capture("frontier_90_to_91")
	navigation.queue_free()
	await _frames()


func _verify_old_replay_does_not_lower_frontier(database) -> void:
	var campaign = CAMPAIGN_SCRIPT.new()
	_check("replay fixture configures with frontier 11", campaign.configure(database, _state(11)))
	var navigation = await _map_for(database, campaign)
	var map = navigation.get_island_map()
	_check("old level 4 can be manually selected", map.select_level(4))
	_check("manual selection leaves frontier at 11", campaign.get_frontier_level_id(ISLAND_ID) == 11)
	_check("manual old-page browse stores restoration", navigation.show_world_map())
	var replay: Dictionary = campaign.mark_level_completed(ISLAND_ID, 4, {"stars": 2, "score": 500})
	_check("old replay improves mastery without lowering frontier", replay.get("ok", false) and campaign.get_frontier_level_id(ISLAND_ID) == 11)
	_check("old replay can return to the production map", navigation.show_island_map(ISLAND_ID))
	await _frames(4)
	map = navigation.get_island_map()
	_check("same-page browsing restoration remains available", campaign.get_frontier_level_id(ISLAND_ID) == 11 and map.get_focus_level_id() == 4)
	navigation.queue_free()
	await _frames()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE_DIR))
	root.size = Vector2i(720, 1280)
	var database = DATABASE_SCRIPT.new()
	_check("canonical Sunny Cove database passes full validation", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
	for boundary in BOUNDARIES:
		await _verify_boundary(database, boundary)
	await _verify_old_replay_does_not_lower_frontier(database)
	if failures.is_empty():
		print("M21_ISLAND_MAP_PAGE_R07_RESULT=PASS boundaries=9")
		quit(0)
		return
	print("M21_ISLAND_MAP_PAGE_R07_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
