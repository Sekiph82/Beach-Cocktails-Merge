extends SceneTree

## Final M18 integration probe. It exercises the canonical Sunny Cove data and
## the production campaign/economy/save/navigation boundaries together.

const ISLAND_ID := "sunny_cove"
const TIKI_ID := "tiki_island"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const NAVIGATION_SCENE := preload("res://scenes/campaign/CampaignNavigationScene.tscn")
const SAVE_PATH := "user://m18_integration_probe.json"
const BACKUP_PATH := "user://m18_integration_probe.json.bak"

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M18_INTEGRATION_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M18_INTEGRATION_PROBE FAIL: %s" % label)


func _remove(path: String) -> void:
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _database():
    var database = DATABASE_SCRIPT.new()
    _check("canonical M18 database loads in FULL validation", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
    return database


func _state() -> Dictionary:
    return SAVE_SCRIPT.new().create_default_state()


func _run() -> void:
    _remove(SAVE_PATH)
    _remove(BACKUP_PATH)
    var database = _database()
    var save = SAVE_SCRIPT.new()
    var state := _state()
    var economy = ECONOMY_SCRIPT.new()
    _check("fresh economy configures", economy.configure_from_state(state)["ok"])
    var campaign = CAMPAIGN_SCRIPT.new()
    _check("fresh canonical campaign configures", campaign.configure(database, state, economy))

    var first: Dictionary = campaign.mark_level_completed(ISLAND_ID, 1, {"stars": 1, "score": 100})
    _check("integration records the base one-star award", first.get("ok", false) and first.get("record", {}).get("stars", 0) == 1 and campaign.is_level_unlocked(ISLAND_ID, 2))
    var worse: Dictionary = campaign.mark_level_completed(ISLAND_ID, 1, {"stars": 0, "score": 1})
    _check("integration preserves worse replay state", not worse.get("changed", true) and worse.get("record", {}).get("stars", 0) == 1 and worse.get("record", {}).get("best_score", 0) == 100)
    var better: Dictionary = campaign.mark_level_completed(ISLAND_ID, 1, {"stars": 3, "score": 300})
    _check("integration upgrades better replay state", better.get("changed", false) and better.get("record", {}).get("stars", 0) == 3 and better.get("record", {}).get("best_score", 0) == 300)

    var reward_crossed := false
    for level_id in range(2, 101):
        var result: Dictionary = campaign.mark_level_completed(ISLAND_ID, level_id, {"stars": 1, "score": level_id * 10})
        reward_crossed = reward_crossed or not result.get("cumulative_rewards", []).is_empty()
    _check("integration crosses and claims cumulative rewards", reward_crossed and campaign.get_cumulative_stars(ISLAND_ID) == 102 and economy.get_booster_count("time") >= 1)
    var time_before_replay := economy.get_booster_count("time")
    var idempotent: Dictionary = campaign.mark_level_completed(ISLAND_ID, 30, {"stars": 1, "score": 300})
    _check("integration cumulative claims are idempotent", idempotent.get("cumulative_rewards", []).is_empty() and economy.get_booster_count("time") == time_before_replay)
    _check("integration completes Sunny Cove and unlocks Tiki", campaign.is_island_complete(ISLAND_ID) and campaign.is_island_unlocked(TIKI_ID) and campaign.get_next_island(ISLAND_ID).get("island_id", "") == TIKI_ID)

    var progression_state: Dictionary = campaign.get_progression_state()
    var economy_state: Dictionary = economy.export_state()
    progression_state["schema_version"] = save.schema_version()
    progression_state["boosters"] = economy_state["boosters"]
    progression_state["reward_ledger"] = economy_state["reward_ledger"]
    _check("integration persists campaign and reward-ledger state", save.write_state(progression_state, SAVE_PATH, BACKUP_PATH)["ok"])
    var loaded: Dictionary = save.read_state(SAVE_PATH, BACKUP_PATH, "user://m18_integration_probe_legacy.cfg")
    var reloaded_economy = ECONOMY_SCRIPT.new()
    var reloaded_campaign = CAMPAIGN_SCRIPT.new()
    _check("integration reload preserves star/reward state", loaded.get("ok", false) and reloaded_economy.configure_from_state(loaded["state"])["ok"] and reloaded_campaign.configure(database, loaded["state"], reloaded_economy) and reloaded_campaign.get_progression_state()["islands"][ISLAND_ID]["claimed_star_rewards"].size() >= 1 and reloaded_campaign.is_island_unlocked(TIKI_ID))

    var navigation = NAVIGATION_SCENE.instantiate()
    _check("integration navigation configures from reloaded authority", navigation.configure_campaign(database, reloaded_campaign, reloaded_economy))
    root.add_child(navigation)
    await process_frame
    await process_frame
    _check("integration mounts exactly one reusable map pair", navigation.get_map_instance_count() == 2 and navigation.show_island_map(ISLAND_ID))
    await process_frame
    await process_frame
    var map = navigation.get_island_map()
    _check("integration map exposes replay-complete level state", map.get_level_state(1) == "COMPLETE" and map.get_level_stars(1) == 3 and map.get_level_button(1).get_best_score() == 300)
    map.set_scroll_vertical(913)
    _check("integration enters replay with one gameplay instance", map.select_level(1) and navigation.get_gameplay_instance_count() == 1)
    navigation.get_session_bridge().resolve_lose("M18_INTEGRATION_RETURN")
    _check("integration returns from replay through Island Map boundary", navigation.return_to_island_map())
    await process_frame
    await process_frame
    map = navigation.get_island_map()
    _check("integration restores replay context without duplicates", map.get_selected_level_id() == 1 and map.get_focus_level_id() == 1 and navigation.get_gameplay_instance_count() == 0 and navigation.get_map_instance_count() == 2)

    navigation.queue_free()
    await process_frame
    _remove(SAVE_PATH)
    _remove(BACKUP_PATH)
    if failures.is_empty():
        print("M18_INTEGRATION_RESULT=PASS")
        quit(0)
        return
    print("M18_INTEGRATION_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
