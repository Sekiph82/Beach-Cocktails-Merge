extends SceneTree

## Focused M18-003 probe. It exercises the owner-approved Sunny Cove
## cumulative-star payload through the canonical data, CampaignManager,
## GameEconomy ledger, and SaveManager boundaries.

const ISLAND_ID := "sunny_cove"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const SAVE_PATH := "user://m18_cumulative_star_rewards_probe.json"
const BACKUP_PATH := "user://m18_cumulative_star_rewards_probe.json.bak"

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M18_CUMULATIVE_REWARDS_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M18_CUMULATIVE_REWARDS_PROBE FAIL: %s" % label)


func _database():
    var database = DATABASE_SCRIPT.new()
    _check("canonical Sunny Cove loads in FULL validation", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
    return database


func _records(level_stars: Dictionary) -> Dictionary:
    var completed := {}
    for level_id in level_stars:
        completed[str(level_id)] = {
            "completed": true,
            "stars": int(level_stars[level_id]),
            "best_score": int(level_stars[level_id]) * 100,
        }
    return completed


func _state(completed: Dictionary, highest_unlocked_level: int = 100, claimed: Array = []) -> Dictionary:
    return {
        "schema_version": 2,
        "unlocked_islands": [ISLAND_ID],
        "islands": {
            ISLAND_ID: {
                "highest_unlocked_level": highest_unlocked_level,
                "completed_levels": completed,
                "claimed_milestones": [],
                "claimed_star_rewards": claimed,
            },
        },
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 0,
        "reward_ledger": [],
    }


func _campaign(database, state: Dictionary):
    var economy = ECONOMY_SCRIPT.new()
    _check("economy configures from campaign state", economy.configure_from_state(state)["ok"])
    var campaign = CAMPAIGN_SCRIPT.new()
    _check("CampaignManager configures with economy authority", campaign.configure(database, state, economy))
    return {"campaign": campaign, "economy": economy}


func _all_stars(count: int, stars: int) -> Dictionary:
    var result := {}
    for level_id in range(1, count + 1):
        result[level_id] = stars
    return result


func _thresholds(result: Dictionary) -> Array:
    var values: Array = []
    for reward in result.get("cumulative_rewards", []):
        values.append(int(reward.get("threshold", 0)))
    return values


func _remove(path: String) -> void:
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _run() -> void:
    var database = _database()
    var track: Array = database.get_island(ISLAND_ID).get("reward_track", {}).get("cumulative_star_rewards", [])
    var expected_thresholds := [30, 60, 90, 120, 150, 180, 210, 240, 270, 300]
    _check("canonical reward track contains the exact ten thresholds", _thresholds({"cumulative_rewards": track}) == expected_thresholds)
    var expected_boosters := ["time", "time", "time", "time", "upgrade", "time", "time", "time", "time", "upgrade"]
    var payload_exact := track.size() == expected_thresholds.size()
    for index in range(mini(track.size(), expected_thresholds.size())):
        var entry: Dictionary = track[index]
        var reward: Dictionary = entry.get("reward", {})
        payload_exact = payload_exact and int(entry.get("threshold", 0)) == expected_thresholds[index] and reward.get("type", "") == "booster" and reward.get("id", "") == expected_boosters[index] and int(reward.get("quantity", 0)) == 1
    _check("canonical reward track has the exact approved booster payload and no coins", payload_exact)

    var partial_bundle = _campaign(database, _state(_records({1: 3, 2: 3, 3: 1})))
    _check("partial cumulative progress is deterministic", partial_bundle["campaign"].get_cumulative_stars(ISLAND_ID) == 7)

    var crossing_bundle = _campaign(database, _state(_records({1: 3, 2: 3, 3: 3, 4: 3, 5: 3, 6: 3, 7: 3, 8: 3, 9: 3, 10: 2})))
    var crossing: Dictionary = crossing_bundle["campaign"].mark_level_completed(ISLAND_ID, 10, {"stars": 3, "score": 350})
    _check("29 to 30 crosses the first threshold", crossing["cumulative_stars"] == 30 and _thresholds(crossing) == [30])
    _check("30-star reward grants one time booster", crossing_bundle["economy"].get_booster_count("time") == 1)
    var worse: Dictionary = crossing_bundle["campaign"].mark_level_completed(ISLAND_ID, 10, {"stars": 1, "score": 1})
    _check("worse replay with no new best is idempotent", not worse["changed"] and worse["cumulative_rewards"].is_empty() and crossing_bundle["economy"].get_booster_count("time") == 1)

    var catchup_bundle = _campaign(database, _state(_records(_all_stars(50, 3))))
    var catchup: Dictionary = catchup_bundle["campaign"].mark_level_completed(ISLAND_ID, 50, {"stars": 3, "score": 300})
    _check("multiple unclaimed thresholds catch up in order", _thresholds(catchup) == [30, 60, 90, 120, 150])
    _check("catch-up grants four time and one upgrade booster", catchup_bundle["economy"].get_booster_count("time") == 4 and catchup_bundle["economy"].get_booster_count("upgrade") == 1)

    var upgrade_bundle = _campaign(database, _state(_records(_all_stars(49, 3)).merged({50: 2})))
    var upgrade: Dictionary = upgrade_bundle["campaign"].mark_level_completed(ISLAND_ID, 50, {"stars": 3, "score": 300})
    _check("149 to 150 grants the approved upgrade reward", _thresholds(upgrade) == [30, 60, 90, 120, 150] and upgrade_bundle["economy"].get_booster_count("upgrade") == 1)

    var final_records := _all_stars(99, 3)
    final_records[100] = 2
    var final_bundle = _campaign(database, _state(_records(final_records)))
    var final_upgrade: Dictionary = final_bundle["campaign"].mark_level_completed(ISLAND_ID, 100, {"stars": 3, "score": 300})
    _check("299 to 300 grants the final approved upgrade", _thresholds(final_upgrade) == expected_thresholds and final_upgrade["cumulative_stars"] == 300 and final_bundle["economy"].get_booster_count("upgrade") == 2)
    var duplicate_final: Dictionary = final_bundle["campaign"].mark_level_completed(ISLAND_ID, 100, {"stars": 3, "score": 300})
    _check("final threshold claim remains duplicate-safe", duplicate_final["cumulative_rewards"].is_empty() and final_bundle["economy"].get_booster_count("upgrade") == 2)

    _remove(SAVE_PATH)
    _remove(BACKUP_PATH)
    var save := SAVE_SCRIPT.new()
    var saved_state: Dictionary = crossing_bundle["campaign"].get_progression_state()
    var economy_state: Dictionary = crossing_bundle["economy"].export_state()
    saved_state["boosters"] = economy_state["boosters"]
    saved_state["reward_ledger"] = economy_state["reward_ledger"]
    _check("claimed threshold state saves", save.write_state(saved_state, SAVE_PATH, BACKUP_PATH)["ok"])
    var loaded: Dictionary = save.read_state(SAVE_PATH, BACKUP_PATH, "user://m18_cumulative_star_rewards_probe_legacy.cfg")
    var reloaded_bundle = _campaign(database, loaded["state"])
    _check("claimed threshold persists across save/reload", loaded["ok"] and loaded["state"]["islands"][ISLAND_ID]["claimed_star_rewards"] == [30] and reloaded_bundle["economy"].get_booster_count("time") == 1)
    var reload_replay: Dictionary = reloaded_bundle["campaign"].mark_level_completed(ISLAND_ID, 10, {"stars": 3, "score": 350})
    _check("replay after reload does not duplicate the claimed reward", reload_replay["cumulative_rewards"].is_empty() and reloaded_bundle["economy"].get_booster_count("time") == 1)

    var progression_bundle = _campaign(database, _state({}, 1))
    var progression: Dictionary = progression_bundle["campaign"].mark_level_completed(ISLAND_ID, 1, {"stars": 1, "score": 0})
    _check("one-star completion advances progression without a reward gate", progression["ok"] and progression_bundle["campaign"].is_level_unlocked(ISLAND_ID, 2))

    _remove(SAVE_PATH)
    _remove(BACKUP_PATH)
    if failures.is_empty():
        print("M18_CUMULATIVE_STAR_REWARDS_RESULT=PASS")
        quit(0)
        return
    print("M18_CUMULATIVE_STAR_REWARDS_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
