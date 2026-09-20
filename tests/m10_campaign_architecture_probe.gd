extends SceneTree

## Focused M10 architecture/data probe. It does not instantiate the gameplay scene.

var failures: Array[String] = []
var database_script = preload("res://scripts/campaign/level_database.gd")
var campaign_script = preload("res://scripts/campaign/campaign_manager.gd")
var save_script = preload("res://scripts/campaign/save_manager.gd")
var economy_script = preload("res://scripts/campaign/game_economy.gd")
var bridge_script = preload("res://scripts/campaign/gameplay_session_bridge.gd")


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M10_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M10_PROBE FAIL: %s" % label)


func _valid_islands() -> Dictionary:
    return {
        "schema_version": 1,
        "islands": [
            {"id": "sunny_cove", "display_name": "Sunny Cove", "order_index": 1, "level_count": 2, "unlock_rule": {"type": "default_open"}, "next_island_id": "tiki_island", "map_background": "res://assets/environment/game_board_background.png", "reward_track": {"milestones": []}},
            {"id": "tiki_island", "display_name": "Tiki Island", "order_index": 2, "level_count": 0, "unlock_rule": {"type": "requires_island_completion"}, "next_island_id": "", "map_background": "", "reward_track": {"milestones": []}},
        ],
    }


func _valid_levels() -> Dictionary:
    return {
        "schema_version": 1,
        "island_id": "sunny_cove",
        "levels": [
            {"island_id": "sunny_cove", "level_id": 1, "time_limit_sec": 20, "orders": [{"cocktail_level": 5, "quantity": 1}], "vip": null, "rewards": {"coins": 0}, "score_star_thresholds": {}, "feature_flags": {}},
            {"island_id": "sunny_cove", "level_id": 2, "time_limit_sec": 20, "orders": [{"cocktail_level": 5, "quantity": 1}], "vip": null, "rewards": {"coins": 0}, "score_star_thresholds": {}, "feature_flags": {}},
        ],
    }


func _new_database(islands: Dictionary = {}, levels: Dictionary = {}):
    if islands.is_empty():
        islands = _valid_islands()
    if levels.is_empty():
        levels = _valid_levels()
    var database = database_script.new()
    _check("valid islands and levels load", database.load_from_data(islands, levels))
    return database


func _run() -> void:
    var database = database_script.new()
    _check("canonical seed loads deterministically", database.load_canonical())
    _check("Sunny Cove is default-open", database.get_island("sunny_cove").get("unlock_rule", {}).get("type") == "default_open")
    _check("get_island works", database.get_island("sunny_cove").get("display_name") == "Sunny Cove")
    _check("get_level works", database.get_level("sunny_cove", 1).get("level_id") == 1)
    _check("get_levels_for_island works", database.get_levels_for_island("sunny_cove").size() == 2)
    _check("seed does not contain full Sunny Cove dataset", database.get_levels_for_island("sunny_cove").size() < 100)

    var duplicate_island := _valid_islands()
    duplicate_island["islands"].append(duplicate_island["islands"][0].duplicate(true))
    var duplicate_database = database_script.new()
    _check("duplicate island id is rejected", not duplicate_database.load_from_data(duplicate_island, _valid_levels()))

    var duplicate_level := _valid_levels()
    duplicate_level["levels"].append(duplicate_level["levels"][0].duplicate(true))
    var duplicate_level_database = database_script.new()
    _check("duplicate level id is rejected", not duplicate_level_database.load_from_data(_valid_islands(), duplicate_level))

    var malformed_level := _valid_levels()
    malformed_level["levels"][0].erase("orders")
    var malformed_database = database_script.new()
    _check("malformed level is rejected", not malformed_database.load_from_data(_valid_islands(), malformed_level))

    var unresolved_level := _valid_levels()
    unresolved_level["island_id"] = "missing_island"
    unresolved_level["levels"][0]["island_id"] = "missing_island"
    var unresolved_database = database_script.new()
    _check("unresolved island reference is rejected", not unresolved_database.load_from_data(_valid_islands(), unresolved_level))

    var invalid_timer := _valid_levels()
    invalid_timer["levels"][0]["time_limit_sec"] = 0
    var invalid_timer_database = database_script.new()
    _check("non-positive time limit is rejected", not invalid_timer_database.load_from_data(_valid_islands(), invalid_timer))

    var invalid_order := _valid_levels()
    invalid_order["levels"][0]["orders"][0]["quantity"] = 0
    var invalid_order_database = database_script.new()
    _check("invalid order quantity is rejected", not invalid_order_database.load_from_data(_valid_islands(), invalid_order))

    var invalid_target := _valid_levels()
    invalid_target["levels"][0]["orders"][0]["cocktail_level"] = 13
    var invalid_target_database = database_script.new()
    _check("out-of-range cocktail target is rejected", not invalid_target_database.load_from_data(_valid_islands(), invalid_target))

    var strict_database = database_script.new()
    _check("full validation rejects partial declared level count", not strict_database.load_canonical(LevelDatabase.DEFAULT_ISLANDS_PATH, LevelDatabase.DEFAULT_LEVELS_PATH, LevelDatabase.ValidationMode.FULL))

    var campaign = campaign_script.new()
    _check("CampaignManager configures without gameplay scene", campaign.configure(_new_database()))
    _check("CampaignManager exposes selection", campaign.select_level("sunny_cove", 1) and campaign.current_island_id == "sunny_cove")
    var first_completion: Dictionary = campaign.mark_level_completed("sunny_cove", 1, {"stars": 2, "score": 100})
    var replay_completion: Dictionary = campaign.mark_level_completed("sunny_cove", 1, {"stars": 1, "score": 50})
    _check("CampaignManager completion update is idempotent and preserves best result", first_completion["ok"] and replay_completion["ok"] and not replay_completion["changed"] and replay_completion["record"]["stars"] == 2 and replay_completion["record"]["best_score"] == 100)

    var bridge = bridge_script.new()
    bridge.configure(campaign.level_database)
    var session := bridge.start_session("sunny_cove", 1)
    _check("GameplaySessionBridge resolves immutable level definition", not session.is_empty() and session["level_definition"]["level_id"] == 1 and session["level_definition"].is_read_only() and session["timer_configured"] == false)
    var definition: Dictionary = session["level_definition"]
    _check("bridge configuration is a detached snapshot", definition == campaign.level_database.get_level("sunny_cove", 1))

    var economy = economy_script.new()
    economy.configure()
    var grant := economy.grant_reward("level-1", {"coins": 25, "booster_id": "upgrade", "booster_quantity": 1})
    var duplicate_grant := economy.grant_reward("level-1", {"coins": 25, "booster_id": "upgrade", "booster_quantity": 1})
    _check("GameEconomy grants a reward", grant["granted"] and economy.coins == 25 and economy.get_booster_count("upgrade") == 1)
    _check("GameEconomy duplicate reward is idempotent", duplicate_grant["duplicate"] and economy.coins == 25 and economy.get_booster_count("upgrade") == 1)

    var save = save_script.new()
    var default_state: Dictionary = save.create_default_state()
    _check("SaveManager schema version API exists", save.schema_version() == 1 and default_state["schema_version"] == 1)
    _check("SaveManager write API is deferred", not save.write_state(default_state)["ok"] and save.write_state(default_state)["reason"] == save.LIVE_PERSISTENCE_DEFERRED)
    var decoded_state: Dictionary = save.decode_state(save.encode_state(default_state))
    _check("SaveManager encode/decode round trip works", decoded_state.get("schema_version") == 1 and decoded_state.get("unlocked_islands", []).has("sunny_cove") and decoded_state.get("coins") == 0)
    _check("SaveManager read API is non-mutating M10 default", save.read_state()["schema_version"] == 1)

    if failures.is_empty():
        print("M10_CAMPAIGN_ARCHITECTURE_RESULT=PASS")
        quit(0)
        return
    print("M10_CAMPAIGN_ARCHITECTURE_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
