extends SceneTree

## Normal-window evidence capture for M12. No production save path is loaded.

const OUTPUT_ROOT := "res://docs/evidence/m12"
const WORLD_MAP_SCENE := preload("res://scenes/campaign/WorldMapScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")


func _init() -> void:
    call_deferred("_capture")


func _level(level_id: int) -> Dictionary:
    return {
        "island_id": "sunny_cove",
        "level_id": level_id,
        "time_limit_sec": 20,
        "orders": [{"cocktail_level": 5, "quantity": 1}],
        "vip": null,
        "rewards": {"coins": 0},
        "score_star_thresholds": {},
        "feature_flags": {},
    }


func _database(level_count: int):
    var database = DATABASE_SCRIPT.new()
    var levels: Array[Dictionary] = []
    for level_id in range(1, level_count + 1):
        levels.append(_level(level_id))
    var islands := {
        "schema_version": 1,
        "islands": [
            {"id": "sunny_cove", "display_name": "Sunny Cove", "order_index": 1, "level_count": level_count, "unlock_rule": {"type": "default_open"}, "next_island_id": "tiki_island", "map_background": "", "map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png", "map_position": [0.18, 0.72], "reward_track": {"milestones": []}},
            {"id": "tiki_island", "display_name": "Tiki Island", "order_index": 2, "level_count": 0, "unlock_rule": {"type": "requires_island_completion", "island_id": "sunny_cove", "level_id": level_count}, "next_island_id": "", "map_background": "", "map_asset": "res://assets/ui_assets/campaign/world_map/tiki_island.png", "map_position": [0.72, 0.38], "reward_track": {"milestones": []}},
        ],
    }
    var level_root := {"schema_version": 1, "island_id": "sunny_cove", "levels": levels}
    database.load_from_data(islands, level_root)
    return database


func _campaign(database):
    var campaign = CAMPAIGN_SCRIPT.new()
    campaign.configure(database, SAVE_SCRIPT.new().create_default_state())
    return campaign


func _mount(database, campaign):
    var world_map = WORLD_MAP_SCENE.instantiate()
    world_map.level_database = database
    world_map.campaign_manager = campaign
    root.add_child(world_map)
    await process_frame
    await process_frame
    return world_map


func _save(name: String) -> void:
    var image := get_root().get_texture().get_image()
    image.save_png("%s/%s" % [OUTPUT_ROOT, name])


func _capture() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))

    var canonical_database = DATABASE_SCRIPT.new()
    canonical_database.load_canonical()
    var fresh_map = await _mount(canonical_database, _campaign(canonical_database))
    await process_frame
    _save("world_map_fresh_720x1280.png")
    fresh_map.select_island("tiki_island")
    await process_frame
    _save("world_map_locked_feedback_720x1280.png")
    fresh_map.queue_free()
    await process_frame

    var fixture_database = _database(2)
    var fixture_campaign = _campaign(fixture_database)
    fixture_campaign.mark_level_completed("sunny_cove", 1, {"stars": 2, "score": 100})
    fixture_campaign.mark_level_completed("sunny_cove", 2, {"stars": 3, "score": 200})
    var complete_map = await _mount(fixture_database, fixture_campaign)
    await process_frame
    _save("world_map_complete_fixture_720x1280.png")
    complete_map.queue_free()
    await process_frame
    print("M12_GUI_CAPTURE_RESULT=PASS")
    quit(0)
