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
        {"id": "sunny_cove", "display_name": "Sunny Cove", "order_index": 1, "level_count": 2, "unlock_rule": {"type": "default_open"}, "next_island_id": "tiki_island", "map_background": "", "reward_track": {"milestones": [2]}},
        {"id": "tiki_island", "display_name": "Tiki Island", "order_index": 2, "level_count": 0, "unlock_rule": {"type": "requires_island_completion", "island_id": "sunny_cove", "level_id": 2}, "next_island_id": "", "map_background": "", "reward_track": {"milestones": []}},
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
    world_map.queue_free()
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
    _check("CURRENT state follows campaign island selection", complete_map.select_island("tiki_island") and complete_map.get_entry_state("tiki_island") == "CURRENT")

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
