extends SceneTree

## Focused M18-001 probe. It exercises the explicit star contract and the
## existing GameplaySessionBridge/CampaignManager progression boundary.

const ISLAND_ID := "m18_star_fixture"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const BRIDGE_SCRIPT := preload("res://scripts/campaign/gameplay_session_bridge.gd")

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M18_STAR_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M18_STAR_PROBE FAIL: %s" % label)


func _level(level_id: int, vip: Variant, thresholds: Dictionary) -> Dictionary:
    return {
        "island_id": ISLAND_ID,
        "level_id": level_id,
        "time_limit_sec": 10,
        "orders": [{"cocktail_level": 6, "quantity": 1}],
        "vip": vip,
        "rewards": {"coins": 0},
        "score_star_thresholds": thresholds,
        "feature_flags": {"timed": true, "vip": vip is Dictionary, "boosters": false},
    }


func _database():
    var database = DATABASE_SCRIPT.new()
    var islands := {
        "schema_version": 1,
        "islands": [{
            "id": ISLAND_ID,
            "display_name": "M18 Star Fixture",
            "order_index": 1,
            "level_count": 2,
            "unlock_rule": {"type": "default_open"},
            "next_island_id": "",
            "map_asset": "",
            "map_position": [0.5, 0.5],
            "reward_track": {"milestones": []},
        }],
    }
    var levels := {
        "schema_version": 1,
        "island_id": ISLAND_ID,
        "levels": [
            _level(1, {"enabled": true, "cocktail_level": 5, "quantity": 1}, {"one_star": 0, "two_stars": 100, "three_stars": 250}),
            _level(2, null, {"one_star": 0, "two_stars": 100, "three_stars": null}),
        ],
    }
    _check("fixture database loads", database.load_from_data(islands, levels, DATABASE_SCRIPT.ValidationMode.FULL))
    return database


func _campaign(database):
    var campaign = CAMPAIGN_SCRIPT.new()
    var state := {
        "schema_version": 2,
        "unlocked_islands": [ISLAND_ID],
        "islands": {ISLAND_ID: {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": []}},
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 0,
    }
    _check("campaign configures", campaign.configure(database, state))
    return campaign


func _run() -> void:
    var bridge = BRIDGE_SCRIPT.new()
    var vip_definition := {"vip": {"enabled": true}, "score_star_thresholds": {"two_stars": 100, "three_stars": 250}}
    var no_vip_definition := {"vip": null, "score_star_thresholds": {"two_stars": 100, "three_stars": 250}}
    var disabled_vip_definition := {"vip": {"enabled": false}, "score_star_thresholds": {"two_stars": null, "three_stars": 250}}
    _check("incomplete result earns zero stars", bridge.calculate_stars(false, true, 999, vip_definition) == 0)
    _check("normal completion earns the base star", bridge.calculate_stars(true, false, 0, vip_definition) == 1)
    _check("VIP completion raises mastery to two stars", bridge.calculate_stars(true, true, 0, vip_definition) == 2)
    _check("configured score mastery raises a completed result", bridge.calculate_stars(true, false, 100, no_vip_definition) == 2)
    _check("VIP plus configured score mastery earns three stars", bridge.calculate_stars(true, true, 250, vip_definition) == 3)
    _check("disabled VIP cannot create a false VIP star", bridge.calculate_stars(true, true, 0, disabled_vip_definition) == 1)
    _check("star result is clamped to three", bridge.calculate_stars(true, true, 999999, vip_definition) == 3)

    var database = _database()
    var campaign = _campaign(database)
    var runtime_bridge = BRIDGE_SCRIPT.new()
    _check("runtime bridge configures", runtime_bridge.configure(database, campaign))
    runtime_bridge.start_session(ISLAND_ID, 1)
    runtime_bridge.mark_gameplay_ready()
    var terminal: Dictionary = runtime_bridge.record_to_go_delivery(6, 1, "normal-completion", 0)["terminal"]
    _check("normal bridge completion reports one star", terminal.get("outcome", "") == "WIN" and terminal.get("stars", 0) == 1)
    _check("one-star completion unlocks the next level", campaign.is_level_unlocked(ISLAND_ID, 2))
    _check("stars do not gate progression", campaign.get_next_level(ISLAND_ID, 1).get("ok", false))

    if failures.is_empty():
        print("M18_STAR_CONTRACT_RESULT=PASS")
        quit(0)
        return
    print("M18_STAR_CONTRACT_RESULT=FAIL failures=%d" % failures.size())
    quit(1)
