extends SceneTree

## Focused M13 probe. It uses one in-memory 100-level island so M13 proves
## reusable scalability without authoring production Sunny Cove content.

const ISLAND_ID := "m13_fixture"
const TEST_ROOT := "user://m13_island_map_probe"
const ISLAND_MAP_SCENE := preload("res://scenes/campaign/IslandMapScene.tscn")
const LEVEL_BUTTON_SCENE := preload("res://scenes/campaign/LevelButton.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _check(label: String, condition: bool) -> void:
	if condition:
		print("M13_PROBE PASS: %s" % label)
	else:
		failures.append(label)
		print("M13_PROBE FAIL: %s" % label)


func _islands() -> Dictionary:
	return {
		"schema_version": 1,
		"islands": [{
			"id": ISLAND_ID,
			"display_name": "M13 Fixture Island",
			"order_index": 1,
			"level_count": 100,
			"unlock_rule": {"type": "default_open"},
			"next_island_id": "",
			"map_background": "",
			"reward_track": {"milestones": [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]},
		}],
	}


func _levels() -> Dictionary:
	var rows: Array[Dictionary] = []
	for level_id in range(1, 101):
		rows.append({
			"island_id": ISLAND_ID,
			"level_id": level_id,
			"time_limit_sec": 20,
			"orders": [{"cocktail_level": 5, "quantity": 1}],
			"vip": null,
			"rewards": {"coins": 0},
			"score_star_thresholds": {"one_star": 0, "two_stars": null, "three_stars": null},
			"feature_flags": {"timed": false, "vip": false, "boosters": false},
		})
	return {"schema_version": 1, "island_id": ISLAND_ID, "levels": rows}


func _state(highest_unlocked: int, completed_stars: Dictionary) -> Dictionary:
	var completed: Dictionary = {}
	for level_id in completed_stars:
		completed[str(level_id)] = {
			"completed": true,
			"stars": int(completed_stars[level_id]),
			"best_score": int(completed_stars[level_id]) * 100,
		}
	return {
		"schema_version": 2,
		"unlocked_islands": [ISLAND_ID],
		"islands": {
			ISLAND_ID: {
				"highest_unlocked_level": highest_unlocked,
				"completed_levels": completed,
				"claimed_milestones": [],
			},
		},
		"legacy_best_score": 0,
		"boosters": {},
		"coins": 0,
	}


func _database():
	var database = DATABASE_SCRIPT.new()
	_check("100-level fixture loads in FULL validation", database.load_from_data(_islands(), _levels(), DATABASE_SCRIPT.ValidationMode.FULL))
	return database


func _campaign(database, state: Dictionary):
	var campaign = CAMPAIGN_SCRIPT.new()
	_check("fixture campaign configures from progression state", campaign.configure(database, state))
	return campaign


func _mount(database, campaign, restoration: Dictionary = {}):
	var map = ISLAND_MAP_SCENE.instantiate()
	_check("generic IslandMapScene accepts island_id", map.configure_island(ISLAND_ID, database, campaign, restoration))
	root.add_child(map)
	await process_frame
	await process_frame
	return map


func _remove(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _run() -> void:
	var source_text := FileAccess.get_file_as_string("res://scenes/campaign/IslandMapScene.tscn")
	var button_text := FileAccess.get_file_as_string("res://scenes/campaign/LevelButton.tscn")
	_check("reusable IslandMapScene resource exists", source_text.contains("island_map_controller.gd"))
	_check("reusable LevelButton resource exists", button_text.contains("level_button.gd"))

	var database = _database()
	var campaign = _campaign(database, _state(6, {1: 0, 2: 1, 3: 2, 5: 3}))
	var map = await _mount(database, campaign)

	_check("100-level fixture renders 100 reusable nodes", map.get_level_button_count() == 100)
	_check("path is vertically scrollable at 720x1280", bool(map.get_layout_report(Vector2(720, 1280))["vertical_scrollable"]))
	_check("path has no horizontal clipping at 720x1280", not bool(map.get_layout_report(Vector2(720, 1280))["horizontal_clipping"]))
	_check("path uses one reusable button scene", int(map.get_layout_report()["reusable_scene_count"]) == 1)
	_check("state COMPLETE is rendered", map.get_level_state(1) == "COMPLETE")
	_check("state OPEN is rendered", map.get_level_state(4) == "OPEN")
	_check("state CURRENT is rendered", map.get_level_state(6) == "CURRENT")
	_check("state LOCKED is rendered", map.get_level_state(7) == "LOCKED")
	_check("0 stars are preserved", map.get_level_stars(1) == 0)
	_check("1 star is preserved", map.get_level_stars(2) == 1)
	_check("2 stars are preserved", map.get_level_stars(3) == 2)
	_check("3 stars are preserved", map.get_level_stars(5) == 3)

	var milestone_ok := true
	for level_id in range(10, 101, 10):
		milestone_ok = milestone_ok and map.is_level_milestone(level_id)
	_check("milestones are present at every tenth level", milestone_ok)
	_check("focus chooses highest unlocked unfinished level", map.get_focus_level_id() == 6)

	var selected: Array[String] = []
	map.level_selected.connect(func(selected_island_id: String, selected_level_id: int) -> void:
		selected.append("%s/%d" % [selected_island_id, selected_level_id])
	)
	_check("locked level selection is rejected", not map.select_level(7) and selected.is_empty())
	_check("selectable level emits bounded selection event", map.select_level(4) and selected == ["m13_fixture/4"])
	_check("selection remains a boundary and does not launch gameplay", map.get_node_or_null("GameplaySessionBridge") == null)

	map.refresh()
	map.refresh()
	map.refresh()
	await process_frame
	await process_frame
	_check("repeated refresh has no duplicate level nodes", map.get_level_button_count() == 100 and not bool(map.get_layout_report()["duplicate_nodes"]))

	var summary: Dictionary = map.get_summary()
	_check("summary exposes display name", summary["display_name"] == "M13 Fixture Island")
	_check("summary exposes completed/configured counts", summary["completed"] == 4 and summary["total"] == 100)
	_check("summary exposes earned stars", summary["stars"] == 6)
	_check("summary exposes next milestone", summary["next_milestone"] == 10)
	_check("summary exposes incomplete state", not bool(summary["island_complete"]))

	var restoration: Dictionary = map.get_restoration_state()
	var second_map = await _mount(database, campaign, restoration)
	_check("selected level restores safely on re-entry", second_map.get_selected_level_id() == restoration["selected_level_id"])
	_check("scroll focus restores safely on re-entry", second_map.get_focus_level_id() == restoration["scroll_focus_level_id"])

	var returned := []
	second_map.return_requested.connect(func() -> void: returned.append(true))
	second_map.request_back_to_world_map()
	_check("back navigation emits World Map boundary", returned == [true])

	var save = SAVE_SCRIPT.new()
	var save_path := "%s/progression.json" % TEST_ROOT
	_remove(save_path)
	_remove(save_path + ".bak")
	var write_result: Dictionary = save.write_state(campaign.get_progression_state(), save_path, save_path + ".bak")
	var read_result: Dictionary = save.read_state(save_path, save_path + ".bak", "%s/legacy.cfg" % TEST_ROOT)
	var reloaded_campaign = _campaign(database, read_result["state"])
	var reload_map = await _mount(database, reloaded_campaign, restoration)
	_check("save/progression reload preserves completion", write_result["ok"] and read_result["ok"] and reload_map.get_level_state(1) == "COMPLETE")
	_check("save/progression reload preserves stars", reload_map.get_level_stars(5) == 3)

	var all_complete_stars: Dictionary = {}
	for level_id in range(1, 101):
		all_complete_stars[level_id] = 3
	var complete_campaign = _campaign(database, _state(100, all_complete_stars))
	var complete_map = await _mount(database, complete_campaign)
	_check("all-complete map keeps 100 nodes", complete_map.get_level_button_count() == 100)
	_check("all-complete map focuses final configured level", complete_map.get_focus_level_id() == 100)
	_check("all-complete summary reports completion", bool(complete_map.get_summary()["island_complete"]))

	map.queue_free()
	second_map.queue_free()
	reload_map.queue_free()
	complete_map.queue_free()
	await process_frame
	_remove(save_path)
	_remove(save_path + ".bak")

	if failures.is_empty():
		print("M13_ISLAND_MAP_RESULT=PASS")
		quit(0)
		return
	print("M13_ISLAND_MAP_RESULT=FAIL failures=%s" % str(failures))
	quit(1)
