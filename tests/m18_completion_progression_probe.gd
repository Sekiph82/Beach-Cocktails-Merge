extends SceneTree

## Focused M18-004 probe. It proves completion, rather than perfect-star
## replay, is the progression and next-island authority.

const SUNNY_COVE := "sunny_cove"
const TIKI_ISLAND := "tiki_island"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M18_COMPLETION_PROGRESSION_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M18_COMPLETION_PROGRESSION_PROBE FAIL: %s" % label)


func _islands() -> Dictionary:
    return {
        "schema_version": 1,
        "islands": [
            {
                "id": SUNNY_COVE,
                "display_name": "Sunny Cove",
                "order_index": 1,
                "level_count": 100,
                "unlock_rule": {"type": "default_open"},
                "next_island_id": TIKI_ISLAND,
                "map_asset": "",
                "map_position": [0.5, 0.5],
                "reward_track": {"milestones": []},
            },
            {
                "id": TIKI_ISLAND,
                "display_name": "Tiki Island",
                "order_index": 2,
                "level_count": 0,
                "unlock_rule": {"type": "requires_island_completion", "island_id": SUNNY_COVE, "level_id": 100},
                "next_island_id": "",
                "map_asset": "",
                "map_position": [0.7, 0.5],
                "reward_track": {"milestones": []},
            },
        ],
    }


func _levels() -> Dictionary:
    var levels: Array[Dictionary] = []
    for level_id in range(1, 101):
        levels.append({
            "island_id": SUNNY_COVE,
            "level_id": level_id,
            "time_limit_sec": 10,
            "orders": [{"cocktail_level": 5, "quantity": 1}],
            "vip": null,
            "rewards": {"coins": 0},
            "score_star_thresholds": {"one_star": 0, "two_stars": null, "three_stars": null},
            "feature_flags": {"timed": true, "vip": false, "boosters": false},
        })
    return {"schema_version": 1, "island_id": SUNNY_COVE, "levels": levels}


func _state() -> Dictionary:
    return {
        "schema_version": 2,
        "unlocked_islands": [SUNNY_COVE],
        "islands": {
            SUNNY_COVE: {
                "highest_unlocked_level": 1,
                "completed_levels": {},
                "claimed_milestones": [],
            },
        },
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 0,
        "reward_ledger": [],
    }


func _database():
    var database = DATABASE_SCRIPT.new()
    _check("100-level completion fixture loads in FULL validation", database.load_from_data(_islands(), _levels(), DATABASE_SCRIPT.ValidationMode.FULL))
    return database


func _campaign(database):
    var campaign = CAMPAIGN_SCRIPT.new()
    _check("completion campaign configures", campaign.configure(database, _state()))
    return campaign


func _run() -> void:
    var database = _database()
    var campaign = _campaign(database)

    var lose_bridge = BRIDGE_SCRIPT.new()
    _check("lose bridge configures", lose_bridge.configure(database, campaign))
    _check("level 1 session starts", not lose_bridge.start_session(SUNNY_COVE, 1).is_empty() and lose_bridge.mark_gameplay_ready())
    var lose_result: Dictionary = lose_bridge.resolve_lose("TIMEOUT")
    _check("lose/incomplete does not advance level 2", lose_result.get("outcome", "") == "LOSE" and not campaign.is_level_unlocked(SUNNY_COVE, 2))

    var win_bridge = BRIDGE_SCRIPT.new()
    _check("win bridge configures", win_bridge.configure(database, campaign))
    var win_configuration: Dictionary = win_bridge.start_session(SUNNY_COVE, 1)
    var win_started := not win_configuration.is_empty() and win_bridge.mark_gameplay_ready()
    for move in range(1, 13):
        win_bridge.record_committed_shot("one-star-%d" % move)
    var one_star_result: Dictionary = win_bridge.record_to_go_delivery(5, 1, "normal-completion", 0)
    _check("one-star completion resolves WIN at the 300 percent move boundary", win_started and int(win_configuration.get("theoretical_shots_total", 0)) == 4 and int(win_configuration.get("move_limit", 0)) == 16 and one_star_result.get("terminal", {}).get("outcome", "") == "WIN" and one_star_result.get("terminal", {}).get("stars", 0) == 1)
    _check("one-star completion unlocks next level", campaign.is_level_unlocked(SUNNY_COVE, 2))
    var next_one: Dictionary = campaign.resolve_next_level(SUNNY_COVE, 1)
    var next_two: Dictionary = campaign.resolve_next_level(SUNNY_COVE, 1)
    _check("next-level resolution is deterministic and idempotent", next_one == next_two and next_one.get("ok", false) and next_one.get("level_id", 0) == 2)

    var full_campaign = _campaign(database)
    var all_one_star := true
    var final_result: Dictionary = {}
    for level_id in range(1, 101):
        final_result = full_campaign.mark_level_completed(SUNNY_COVE, level_id, {"stars": 1, "score": level_id})
        all_one_star = all_one_star and bool(final_result.get("ok", false)) and int(final_result.get("record", {}).get("stars", 0)) == 1
    _check("all 100 levels accept normal one-star completion", all_one_star and full_campaign.is_island_complete(SUNNY_COVE))
    _check("Sunny Cove level 100 completion unlocks Tiki without perfect stars", full_campaign.is_island_unlocked(TIKI_ISLAND) and full_campaign.get_next_island(SUNNY_COVE).get("island_id", "") == TIKI_ISLAND)
    _check("100% completion is independent of perfect-star replay", full_campaign.get_cumulative_stars(SUNNY_COVE) == 100 and not full_campaign.is_level_unlocked(TIKI_ISLAND, 1))

    if failures.is_empty():
        print("M18_COMPLETION_PROGRESSION_RESULT=PASS")
        quit(0)
        return
    print("M18_COMPLETION_PROGRESSION_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
