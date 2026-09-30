extends SceneTree

## M18 V02-R01 focused remediation probe. It proves that cumulative-star
## thresholds remain unclaimed until an economy grant succeeds, then reconcile
## correctly for late attachment, failed grants, duplicate ledgers, and reload.

const ISLAND_ID := "sunny_cove"
const DATABASE_SCRIPT := preload("res://scripts/campaign/level_database.gd")
const CAMPAIGN_SCRIPT := preload("res://scripts/campaign/campaign_manager.gd")
const ECONOMY_SCRIPT := preload("res://scripts/campaign/game_economy.gd")
const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const FAILING_ECONOMY_SCRIPT := preload("res://tests/fixtures/m18_failing_economy.gd")
const SAVE_PATH := "user://m18_v02_r01_cumulative_claim.json"
const BACKUP_PATH := "user://m18_v02_r01_cumulative_claim.json.bak"

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M18_CUMULATIVE_REWARD_REMEDIATION_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M18_CUMULATIVE_REWARD_REMEDIATION_PROBE FAIL: %s" % label)


func _database():
    var database = DATABASE_SCRIPT.new()
    _check("canonical Sunny Cove loads in FULL validation", database.load_canonical("res://data/campaign/islands.json", "res://data/campaign/levels/sunny_cove.json", DATABASE_SCRIPT.ValidationMode.FULL))
    return database


func _records() -> Dictionary:
    var completed := {}
    for level_id in range(1, 10):
        completed[str(level_id)] = {"completed": true, "stars": 3, "best_score": level_id * 100}
    completed["10"] = {"completed": true, "stars": 2, "best_score": 200}
    return completed


func _state(ledger: Array = [], claimed: Array = []) -> Dictionary:
    return {
        "schema_version": 2,
        "unlocked_islands": [ISLAND_ID],
        "islands": {
            ISLAND_ID: {
                "highest_unlocked_level": 100,
                "completed_levels": _records(),
                "claimed_milestones": [],
                "claimed_star_rewards": claimed,
            },
        },
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 0,
        "reward_ledger": ledger,
    }


func _campaign(database, state: Dictionary):
    var campaign = CAMPAIGN_SCRIPT.new()
    _check("campaign configures without an economy", campaign.configure(database, state))
    return campaign


func _remove(path: String) -> void:
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _run() -> void:
    var database = _database()

    # The level completion and cumulative progression are successful, but the
    # reward must remain pending while no economy authority is attached.
    var pending_campaign = _campaign(database, _state())
    var pending: Dictionary = pending_campaign.mark_level_completed(ISLAND_ID, 10, {"stars": 3, "score": 350})
    var pending_state: Dictionary = pending_campaign.get_progression_state()
    _check("29 to 30 completes without economy", pending.get("ok", false) and pending.get("cumulative_stars", 0) == 30 and pending.get("cumulative_rewards", []).is_empty())
    _check("economy-unavailable threshold remains unclaimed", pending_state["islands"][ISLAND_ID]["claimed_star_rewards"].is_empty())
    _check("level completion still advances progression without reward authority", pending_campaign.is_level_completed(ISLAND_ID, 10) and pending_campaign.is_level_unlocked(ISLAND_ID, 11))

    # Attaching the real economy later reconciles the pending threshold once.
    var late_economy = ECONOMY_SCRIPT.new()
    _check("late economy attaches from pending state", late_economy.configure_from_state(pending_state).get("ok", false))
    pending_campaign.set_economy(late_economy)
    var reconciled: Dictionary = pending_campaign.mark_level_completed(ISLAND_ID, 10, {"stars": 3, "score": 350})
    _check("late economy retry claims threshold", reconciled.get("cumulative_rewards", []).size() == 1 and reconciled["cumulative_rewards"][0].get("threshold", 0) == 30)
    _check("late economy grants exactly one time booster", late_economy.get_booster_count("time") == 1 and pending_campaign.get_progression_state()["islands"][ISLAND_ID]["claimed_star_rewards"] == [30])

    # A failed grant must not consume the threshold or mutate progression
    # ownership. A later successful economy can still reconcile it.
    var failed_campaign = _campaign(database, _state())
    var failed_crossing: Dictionary = failed_campaign.mark_level_completed(ISLAND_ID, 10, {"stars": 3, "score": 350})
    var failing_economy = FAILING_ECONOMY_SCRIPT.new()
    failed_campaign.set_economy(failing_economy)
    var failed_retry: Dictionary = failed_campaign.mark_level_completed(ISLAND_ID, 10, {"stars": 3, "score": 350})
    _check("forced failed grant leaves threshold unclaimed", failed_crossing.get("cumulative_rewards", []).is_empty() and failed_retry.get("cumulative_rewards", []).is_empty() and failed_campaign.get_progression_state()["islands"][ISLAND_ID]["claimed_star_rewards"].is_empty() and failing_economy.grant_calls == 1)

    # A persisted reward ledger is an idempotent grant success: the threshold
    # becomes claimed, but inventory is not incremented a second time.
    var reward_id := "cumulative-stars:%s:30" % ISLAND_ID
    var duplicate_campaign = _campaign(database, _state([reward_id]))
    var duplicate_economy = ECONOMY_SCRIPT.new()
    _check("duplicate-ledger economy configures", duplicate_economy.configure_from_state(duplicate_campaign.get_progression_state()).get("ok", false))
    duplicate_campaign.set_economy(duplicate_economy)
    var duplicate: Dictionary = duplicate_campaign.mark_level_completed(ISLAND_ID, 10, {"stars": 3, "score": 350})
    var duplicate_again: Dictionary = duplicate_campaign.mark_level_completed(ISLAND_ID, 10, {"stars": 3, "score": 350})
    _check("duplicate ledger claims state without duplicate inventory", duplicate.get("cumulative_rewards", []).size() == 1 and not duplicate["cumulative_rewards"][0]["grant"].get("granted", true) and duplicate_economy.get_booster_count("time") == 0 and duplicate_again.get("cumulative_rewards", []).is_empty())
    _check("duplicate ledger leaves claim consistent", duplicate_campaign.get_progression_state()["islands"][ISLAND_ID]["claimed_star_rewards"] == [30])

    # Save/reload keeps the normal 29->30 grant and remains duplicate-safe.
    _remove(SAVE_PATH)
    _remove(BACKUP_PATH)
    var save := SAVE_SCRIPT.new()
    var persisted_state: Dictionary = pending_campaign.get_progression_state()
    var economy_state: Dictionary = late_economy.export_state()
    persisted_state["boosters"] = economy_state["boosters"]
    persisted_state["reward_ledger"] = economy_state["reward_ledger"]
    var written: Dictionary = save.write_state(persisted_state, SAVE_PATH, BACKUP_PATH)
    var loaded: Dictionary = save.read_state(SAVE_PATH, BACKUP_PATH, "user://m18_v02_r01_legacy.cfg")
    var reloaded_economy = ECONOMY_SCRIPT.new()
    var reloaded_campaign = CAMPAIGN_SCRIPT.new()
    _check("normal 29 to 30 reward state saves and reloads", written.get("ok", false) and loaded.get("ok", false) and reloaded_economy.configure_from_state(loaded["state"]).get("ok", false) and reloaded_campaign.configure(database, loaded["state"], reloaded_economy))
    var reload_replay: Dictionary = reloaded_campaign.mark_level_completed(ISLAND_ID, 10, {"stars": 3, "score": 350})
    _check("save/reload replay does not duplicate reward", reload_replay.get("cumulative_rewards", []).is_empty() and reloaded_economy.get_booster_count("time") == 1 and loaded["state"]["islands"][ISLAND_ID]["claimed_star_rewards"] == [30])

    _remove(SAVE_PATH)
    _remove(BACKUP_PATH)
    if failures.is_empty():
        print("M18_CUMULATIVE_REWARD_REMEDIATION_RESULT=PASS")
        quit(0)
        return
    print("M18_CUMULATIVE_REWARD_REMEDIATION_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
