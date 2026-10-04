extends SceneTree

## Focused M18-002 probe. It proves monotonic level records through the
## CampaignManager authority and SaveManager round-trip/migration boundaries.

const ISLAND_ID := "m18_replay_fixture"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const SAVE_PATH := "user://m18_replay_persistence_probe.json"
const BACKUP_PATH := "user://m18_replay_persistence_probe.json.bak"

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M18_REPLAY_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M18_REPLAY_PROBE FAIL: %s" % label)


func _database():
    var database = DATABASE_SCRIPT.new()
    var islands := {
        "schema_version": 1,
        "islands": [{
            "id": ISLAND_ID,
            "display_name": "M18 Replay Fixture",
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
            {"island_id": ISLAND_ID, "level_id": 1, "time_limit_sec": 10, "orders": [{"cocktail_level": 6, "quantity": 1}], "vip": null, "rewards": {"coins": 0}, "score_star_thresholds": {"one_star": 0, "two_stars": null, "three_stars": null}, "feature_flags": {"timed": true, "vip": false, "boosters": false}},
            {"island_id": ISLAND_ID, "level_id": 2, "time_limit_sec": 10, "orders": [{"cocktail_level": 6, "quantity": 1}], "vip": null, "rewards": {"coins": 0}, "score_star_thresholds": {"one_star": 0, "two_stars": null, "three_stars": null}, "feature_flags": {"timed": true, "vip": false, "boosters": false}},
        ],
    }
    _check("fixture database loads", database.load_from_data(islands, levels, DATABASE_SCRIPT.ValidationMode.FULL))
    return database


func _state() -> Dictionary:
    return {
        "schema_version": 2,
        "unlocked_islands": [ISLAND_ID],
        "islands": {ISLAND_ID: {"highest_unlocked_level": 2, "completed_levels": {}, "claimed_milestones": []}},
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 0,
        "reward_ledger": [],
    }


func _campaign(database):
    var campaign = CAMPAIGN_SCRIPT.new()
    _check("campaign configures", campaign.configure(database, _state()))
    return campaign


func _record(campaign) -> Dictionary:
    return campaign.get_progression_state()["islands"][ISLAND_ID]["completed_levels"]["1"]


func _run() -> void:
    var database = _database()
    var campaign = _campaign(database)
    var first: Dictionary = campaign.mark_level_completed(ISLAND_ID, 1, {"stars": 1, "score": 100, "vip_completed": true})
    _check("first completion creates a bounded record", first["changed"] and _record(campaign)["stars"] == 1 and _record(campaign)["best_score"] == 100 and _record(campaign)["vip_completed"])

    var worse: Dictionary = campaign.mark_level_completed(ISLAND_ID, 1, {"stars": 0, "score": 50, "vip_completed": false})
    _check("worse replay preserves score, stars, and VIP history", not worse["changed"] and _record(campaign)["stars"] == 1 and _record(campaign)["best_score"] == 100 and _record(campaign)["vip_completed"])
    var equal: Dictionary = campaign.mark_level_completed(ISLAND_ID, 1, {"stars": 1, "score": 100, "vip_completed": false})
    _check("equal replay is idempotent", not equal["changed"] and _record(campaign)["stars"] == 1 and _record(campaign)["best_score"] == 100)
    var better: Dictionary = campaign.mark_level_completed(ISLAND_ID, 1, {"stars": 3, "score": 150, "vip_completed": false})
    _check("better replay upgrades both mastery fields", better["changed"] and _record(campaign)["stars"] == 3 and _record(campaign)["best_score"] == 150 and _record(campaign)["vip_completed"])
    _check("progression remains idempotent after replay", campaign.is_level_unlocked(ISLAND_ID, 2) and campaign.get_next_level(ISLAND_ID, 1)["ok"])

    var save = SAVE_SCRIPT.new()
    var state: Dictionary = campaign.get_progression_state()
    _check("atomic save accepts monotonic campaign state", save.write_state(state, SAVE_PATH, BACKUP_PATH)["ok"])
    var loaded: Dictionary = save.read_state(SAVE_PATH, BACKUP_PATH, "user://m18_replay_legacy_missing.cfg")
    _check("save reload preserves better score/stars", loaded["ok"] and loaded["state"]["islands"][ISLAND_ID]["completed_levels"]["1"]["stars"] == 3 and loaded["state"]["islands"][ISLAND_ID]["completed_levels"]["1"]["best_score"] == 150)
    var reloaded_campaign = CAMPAIGN_SCRIPT.new()
    _check("reloaded campaign preserves the same record", reloaded_campaign.configure(database, loaded["state"]) and _record(reloaded_campaign)["stars"] == 3 and _record(reloaded_campaign)["best_score"] == 150)

    var invalid: Dictionary = state.duplicate(true)
    invalid["islands"][ISLAND_ID]["completed_levels"]["1"]["stars"] = 4
    _check("current saves reject out-of-range stars", not save.validate_state(invalid)["ok"])
    var older: Dictionary = state.duplicate(true)
    older["schema_version"] = 1
    older.erase("reward_ledger")
    var migration: Dictionary = save.migrate_state(older, 1)
    _check("older save migration preserves bounded replay records", migration["ok"] and migration["state"]["schema_version"] == 2 and migration["state"]["islands"][ISLAND_ID]["completed_levels"]["1"]["stars"] == 3)

    DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
    DirAccess.remove_absolute(ProjectSettings.globalize_path(BACKUP_PATH))
    if failures.is_empty():
        print("M18_REPLAY_PERSISTENCE_RESULT=PASS")
        quit(0)
        return
    print("M18_REPLAY_PERSISTENCE_RESULT=FAIL failures=%d" % failures.size())
    quit(1)
