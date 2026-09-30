extends SceneTree

## Focused M18-005 probe. It proves completed-level replay visibility and
## selected/scroll context restoration through the production map/navigation
## boundary without creating duplicate map or gameplay instances.

const ISLAND_ID := "m18_replay_map_fixture"
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M18_ISLAND_MAP_REPLAY_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M18_ISLAND_MAP_REPLAY_PROBE FAIL: %s" % label)


func _database():
    var database = DATABASE_SCRIPT.new()
    var islands := {
        "schema_version": 1,
        "islands": [{
            "id": ISLAND_ID,
            "display_name": "M18 Replay Map Fixture",
            "order_index": 1,
            "level_count": 100,
            "unlock_rule": {"type": "default_open"},
            "next_island_id": "",
            "map_background": "",
            "map_asset": "res://assets/ui_assets/campaign/world_map/sunny_cove.png",
            "map_position": [0.5, 0.5],
            "reward_track": {"milestones": []},
        }],
    }
    var levels: Array[Dictionary] = []
    for level_id in range(1, 101):
        levels.append({
            "island_id": ISLAND_ID,
            "level_id": level_id,
            "time_limit_sec": 10,
            "orders": [{"cocktail_level": 5, "quantity": 1}],
            "vip": null,
            "rewards": {"coins": 0},
            "score_star_thresholds": {"one_star": 0, "two_stars": null, "three_stars": null},
            "feature_flags": {"timed": true, "vip": false, "boosters": false},
        })
    _check("replay fixture loads in FULL validation", database.load_from_data(islands, {"schema_version": 1, "island_id": ISLAND_ID, "levels": levels}, DATABASE_SCRIPT.ValidationMode.FULL))
    return database


func _state() -> Dictionary:
    var completed := {}
    for level_id in range(1, 6):
        completed[str(level_id)] = {"completed": true, "stars": 2, "best_score": 500 + level_id}
    return {
        "schema_version": 2,
        "unlocked_islands": [ISLAND_ID],
        "islands": {ISLAND_ID: {"highest_unlocked_level": 6, "completed_levels": completed, "claimed_milestones": []}},
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 0,
        "reward_ledger": [],
    }


func _run() -> void:
    var database = _database()
    var campaign = CAMPAIGN_SCRIPT.new()
    _check("replay campaign configures", campaign.configure(database, _state()))

    var navigation = NAVIGATION_SCENE.instantiate()
    _check("navigation accepts replay campaign", navigation.configure_campaign(database, campaign))
    root.add_child(navigation)
    await process_frame
    await process_frame
    _check("one reusable map pair is mounted", navigation.get_map_instance_count() == 2)
    _check("Island Map opens for the replay fixture", navigation.show_island_map(ISLAND_ID))
    await process_frame
    await process_frame
    var map = navigation.get_island_map()
    _check("completed level remains selectable for replay", map.get_level_state(5) == "COMPLETE" and map.get_level_button(5).is_selectable())
    _check("authoritative prior stars and best score are visible", map.get_level_stars(5) == 2 and map.get_level_button(5).get_best_score() == 505 and map.get_level_button(5).text.contains("BEST 505"))

    map.set_scroll_vertical(913)
    _check("worse replay preserves stored state", not campaign.mark_level_completed(ISLAND_ID, 5, {"stars": 1, "score": 1})["changed"] and map.get_level_stars(5) == 2 and map.get_level_button(5).get_best_score() == 505)
    map.refresh()
    await process_frame
    await process_frame
    _check("better replay refreshes authoritative visible state", campaign.mark_level_completed(ISLAND_ID, 5, {"stars": 3, "score": 900})["changed"] and map.get_level_stars(5) == 2)
    map.refresh()
    await process_frame
    await process_frame
    _check("better replay state is visible after refresh", map.get_level_stars(5) == 3 and map.get_level_button(5).get_best_score() == 900 and map.get_level_button(5).text.contains("BEST 900"))

    # Re-enter through the actual gameplay-return boundary. Selection and the
    # manually chosen scroll location must survive without a second map host.
    _check("replay launch uses one gameplay instance", map.select_level(5) and navigation.get_gameplay_instance_count() == 1)
    var saved_scroll: int = map.get_scroll_vertical()
    var bridge = navigation.get_session_bridge()
    bridge.resolve_lose("REPLAY_RETURN")
    _check("terminal replay can return to the Island Map", navigation.return_to_island_map())
    await process_frame
    await process_frame
    map = navigation.get_island_map()
    _check("return restores selected level and scroll/focus context", navigation.get_current_view() == "ISLAND_MAP" and map.get_selected_level_id() == 5 and map.get_focus_level_id() == 5 and map.get_scroll_vertical() == saved_scroll)
    _check("replay return disposes gameplay without duplicating maps", navigation.get_gameplay_instance_count() == 0 and navigation.get_map_instance_count() == 2 and map.get_level_button_count() == 100)

    navigation.queue_free()
    await process_frame
    if failures.is_empty():
        print("M18_ISLAND_MAP_REPLAY_RESULT=PASS")
        quit(0)
        return
    print("M18_ISLAND_MAP_REPLAY_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
