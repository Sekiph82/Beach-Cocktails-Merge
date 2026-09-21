extends SceneTree

## Focused M12 World Map probe. It uses in-memory campaign fixtures and an
## isolated user:// path only for the reload assertion; production save paths
## are never opened.

const TEST_ROOT := "user://m12_world_map_probe"

var failures: Array[String] = []
var database_script = preload("res://scripts/campaign/level_database.gd")
var campaign_script = preload("res://scripts/campaign/campaign_manager.gd")
var save_script = preload("res://scripts/campaign/save_manager.gd")
var scene = preload("res://scenes/campaign/WorldMapScene.tscn")


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M12_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M12_PROBE FAIL: %s" % label)


func _level(island_id: String, level_id: int) -> Dictionary:
    return {
        "island_id": island_id,
        "level_id": level_id,
        "time_limit_sec": 20,
        "orders": [{"cocktail_level": 5, "quantity": 1}],
        "vip": null,
        "rewards": {"coins": 0},
        "score_star_thresholds": {},
        "feature_flags": {},
    }


func _two_island_data() -> Array[Dictionary]:
    return [
        {"id": "sunny_cove", "display_name": "Sunny Cove", "order_index": 1, "level_count": 2, "unlock_rule": {"type": "default_open"}, "next_island_id": "tiki_island", "map_background": "", "map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png", "map_position": [0.18, 0.72], "reward_track": {"milestones": [2]}},
        {"id": "tiki_island", "display_name": "Tiki Island", "order_index": 2, "level_count": 0, "unlock_rule": {"type": "requires_island_completion", "island_id": "sunny_cove", "level_id": 2}, "next_island_id": "", "map_background": "", "map_asset": "res://assets/ui_assets/campaign/world_map/tiki_island.png", "map_position": [0.72, 0.38], "reward_track": {"milestones": []}},
    ]


func _ten_island_data() -> Array[Dictionary]:
    var islands: Array[Dictionary] = []
    for index in range(10):
        var island_id := "island_%02d" % (index + 1)
        islands.append({
            "id": island_id,
            "display_name": "Island %02d" % (index + 1),
            "order_index": index + 1,
            "level_count": 0,
            "unlock_rule": {"type": "default_open"},
            "next_island_id": "" if index == 9 else "island_%02d" % (index + 2),
            "map_background": "",
            "map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png",
            "map_position": [0.18, 0.72],
            "reward_track": {"milestones": []},
        })
    return islands


func _database(islands: Array[Dictionary], levels: Array[Dictionary]):
    var database = database_script.new()
    var levels_root := {
        "schema_version": 1,
        "island_id": "sunny_cove" if not levels.is_empty() else "island_01",
        "levels": levels,
    }
    _check("fixture campaign definitions load", database.load_from_data({"schema_version": 1, "islands": islands}, levels_root))
    return database


func _fresh_campaign(database):
    var campaign = campaign_script.new()
    var save = save_script.new()
    _check("fresh campaign configures", campaign.configure(database, save.create_default_state()))
    return campaign


func _mount(database, campaign):
    var world_map = scene.instantiate()
    world_map.level_database = database
    world_map.campaign_manager = campaign
    root.add_child(world_map)
    await process_frame
    await process_frame
    return world_map


func _remove(path: String) -> void:
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _run() -> void:
    var project_text := FileAccess.get_file_as_string("res://project.godot").to_lower()
    _check("normal startup excludes historical probe scripts", project_text.contains("run/main_scene=\"res://scenes/main.tscn\"") and not project_text.contains("tests/"))
    var database = _database(_two_island_data(), [_level("sunny_cove", 1), _level("sunny_cove", 2)])
    var campaign = _fresh_campaign(database)
    var world_map = await _mount(database, campaign)

    _check("WorldMapScene loads", world_map.get_entry_count() == 2)
    _check("entries are generated from LevelDatabase", world_map.get_entry_ids() == ["sunny_cove", "tiki_island"])
    _check("Sunny Cove is selectable on fresh state", world_map.is_entry_selectable("sunny_cove") and world_map.get_entry_state("sunny_cove") == "CURRENT")
    _check("Tiki Island is locked on fresh state", not world_map.is_entry_selectable("tiki_island") and world_map.get_entry_state("tiki_island") == "LOCKED")

    var selected: Array[String] = []
    world_map.island_selected.connect(func(island_id: String) -> void: selected.append(island_id))
    var navigation: Array[String] = []
    world_map.island_map_requested.connect(func(island_id: String) -> void: navigation.append(island_id))
    _check("locked Tiki selection is rejected", not world_map.select_island("tiki_island") and selected.is_empty() and navigation.is_empty())
    var feedback: Dictionary = world_map.get_locked_feedback()
    _check("locked feedback exposes reason and progress", feedback.get("island_id") == "tiki_island" and str(feedback.get("reason", "")).contains("Sunny Cove") and str(feedback.get("progress", "")).contains("Level 2"))
    _check("Sunny Cove selection emits id and navigation boundary", world_map.select_island("sunny_cove") and selected == ["sunny_cove"] and navigation == ["sunny_cove"])
    await process_frame

    var layout: Dictionary = world_map.get_layout_report(Vector2(720, 1280))
    _check("720x1280 layout has no horizontal clipping", not bool(layout["horizontal_clipping"]) and bool(layout["entries_fit_width"]))
    _check("720x1280 layout has no entry overlap", not bool(layout["overlap"]) and not bool(layout["navigation_overlap"]))
    _check("visual map creates spatial markers", world_map.get_visual_marker_count() == 2 and world_map.get_marker_position("sunny_cove") != world_map.get_marker_position("tiki_island"))
    world_map.queue_free()
    await process_frame

    var canonical_database = database_script.new()
    _check("canonical visual map definitions load", canonical_database.load_canonical())
    var canonical_campaign = _fresh_campaign(canonical_database)
    var canonical_map = await _mount(canonical_database, canonical_campaign)
    var canonical_ids: Array[String] = canonical_map.get_entry_ids()
    _check("canonical map displays ten planned destinations", canonical_ids.size() == 10 and canonical_map.get_visual_marker_count() == 10)
    var all_future_locked := true
    for canonical_id in canonical_ids:
        if canonical_id != "sunny_cove":
            all_future_locked = all_future_locked and canonical_map.get_entry_state(canonical_id) == "LOCKED" and not canonical_map.is_entry_selectable(canonical_id)
    _check("Sunny Cove is the only fresh selectable destination", canonical_map.is_entry_selectable("sunny_cove") and all_future_locked)
    var repeated_navigation: Array[String] = []
    canonical_map.island_map_requested.connect(func(island_id: String) -> void: repeated_navigation.append(island_id))
    for _attempt in range(3):
        _check("repeated Sunny Cove selection remains accepted", canonical_map.select_island("sunny_cove"))
        canonical_map.refresh()
    await process_frame
    await process_frame
    var repeated_layout: Dictionary = canonical_map.get_layout_report(Vector2(720, 1280))
    _check("repeated selection leaves no duplicate markers", canonical_map.get_map_node_count() == canonical_map.get_entry_count() and not bool(repeated_layout["duplicate_nodes"]))
    _check("repeated selection emits one boundary per selection", repeated_navigation == ["sunny_cove", "sunny_cove", "sunny_cove"])
    _check("visual map 720x1280 geometry remains clean", not bool(repeated_layout["horizontal_clipping"]) and not bool(repeated_layout["overlap"]))
    canonical_map.queue_free()
    await process_frame

    var ten_database = _database(_ten_island_data(), [])
    var ten_campaign = _fresh_campaign(ten_database)
    var ten_map = await _mount(ten_database, ten_campaign)
    _check("same entry/layout architecture handles ten islands", ten_map.get_entry_count() == 10 and ten_map.get_entry_ids()[9] == "island_10")
    ten_map.queue_free()
    await process_frame

    var complete_campaign = _fresh_campaign(database)
    complete_campaign.mark_level_completed("sunny_cove", 1, {"stars": 2, "score": 100})
    complete_campaign.mark_level_completed("sunny_cove", 2, {"stars": 3, "score": 200})
    var complete_map = await _mount(database, complete_campaign)
    _check("COMPLETE state is derived from CampaignManager", complete_map.get_entry_state("sunny_cove") == "COMPLETE")
    _check("unlocked next island is rendered open", complete_map.get_entry_state("tiki_island") == "OPEN" and complete_map.is_entry_selectable("tiki_island"))
    var selected_next: bool = complete_map.select_island("tiki_island")
    await process_frame
    _check("CURRENT state follows campaign island selection", selected_next and complete_map.get_entry_state("tiki_island") == "CURRENT")

    var save = save_script.new()
    var save_path := "%s/reload.json" % TEST_ROOT
    _remove(save_path)
    _remove(save_path + ".bak")
    var state: Dictionary = complete_campaign.get_progression_state()
    var written := save.write_state(state, save_path, save_path + ".bak")
    var reloaded := save.read_state(save_path, save_path + ".bak", "%s/legacy.cfg" % TEST_ROOT)
    var reloaded_campaign = campaign_script.new()
    _check("World Map state survives isolated SaveManager round-trip", written["ok"] and reloaded["ok"] and reloaded_campaign.configure(database, reloaded["state"]) and reloaded_campaign.is_island_complete("sunny_cove") and reloaded_campaign.is_island_unlocked("tiki_island"))
    complete_map.queue_free()
    await process_frame
    _remove(save_path)
    _remove(save_path + ".bak")

    if failures.is_empty():
        print("M12_WORLD_MAP_RESULT=PASS")
        quit(0)
        return
    print("M12_WORLD_MAP_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
