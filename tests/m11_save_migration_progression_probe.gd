extends SceneTree

## M11 persistence/progression probe.
## Every file is explicitly under this probe-only user:// directory. The
## production user://campaign_save.json and user://save.cfg are never opened.

const TEST_ROOT := "user://m11_save_probe"
var failures: Array[String] = []
var save_script = preload("res://scripts/campaign/save_manager.gd")
var database_script = preload("res://scripts/campaign/level_database.gd")
var campaign_script = preload("res://scripts/campaign/campaign_manager.gd")


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M11_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M11_PROBE FAIL: %s" % label)


func _path(name: String) -> String:
    return "%s/%s" % [TEST_ROOT, name]


func _remove(path: String) -> void:
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _write_text(path: String, text: String) -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
    var file := FileAccess.open(path, FileAccess.WRITE)
    file.store_string(text)
    file.close()


func _clean(name: String) -> void:
    var primary := _path(name)
    _remove(primary)
    _remove(primary + ".bak")
    _remove(primary + ".tmp")


func _legacy_save(path: String, score: int) -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
    var legacy := ConfigFile.new()
    legacy.set_value("records", "best", score)
    legacy.save(path)


func _valid_islands() -> Dictionary:
    return {
        "schema_version": 1,
        "islands": [
            {"id": "sunny_cove", "display_name": "Sunny Cove", "order_index": 1, "level_count": 2, "unlock_rule": {"type": "default_open"}, "next_island_id": "tiki_island", "map_background": "", "reward_track": {"milestones": [2]}},
            {"id": "tiki_island", "display_name": "Tiki Island", "order_index": 2, "level_count": 0, "unlock_rule": {"type": "requires_island_completion", "island_id": "sunny_cove", "level_id": 2}, "next_island_id": "", "map_background": "", "reward_track": {"milestones": []}},
        ],
    }


func _level(island_id: String, level_id: int) -> Dictionary:
    return {"island_id": island_id, "level_id": level_id, "time_limit_sec": 20, "orders": [{"cocktail_level": 5, "quantity": 1}], "vip": null, "rewards": {"coins": 0}, "score_star_thresholds": {}, "feature_flags": {}}


func _valid_levels() -> Dictionary:
    return {"schema_version": 1, "island_id": "sunny_cove", "levels": [_level("sunny_cove", 1), _level("sunny_cove", 2)]}


func _database():
    var database = database_script.new()
    _check("test campaign definitions load in FULL mode", database.load_from_data(_valid_islands(), _valid_levels(), database_script.ValidationMode.FULL))
    return database


func _run() -> void:
    var save = save_script.new()

    var first_name := "first_boot.json"
    _clean(first_name)
    var first_path := _path(first_name)
    var first := save.read_state(first_path, first_path + ".bak", _path("first_legacy.cfg"))
    _check("first boot returns a fresh default", first["ok"] and first["status"] == save.STATUS_MISSING and first["state"]["schema_version"] == save.schema_version() and first["state"]["unlocked_islands"].has("sunny_cove"))

    var roundtrip_name := "roundtrip.json"
    _clean(roundtrip_name)
    var roundtrip_path := _path(roundtrip_name)
    var roundtrip_state: Dictionary = save.create_default_state()
    roundtrip_state["coins"] = 42
    var write_roundtrip := save.write_state(roundtrip_state, roundtrip_path, roundtrip_path + ".bak")
    var read_roundtrip := save.read_state(roundtrip_path, roundtrip_path + ".bak", _path("roundtrip_legacy.cfg"))
    _check("valid write/read round trip", write_roundtrip["ok"] and read_roundtrip["status"] == save.STATUS_VALID and read_roundtrip["state"] == roundtrip_state)

    var backup_name := "backup.json"
    _clean(backup_name)
    var backup_path := _path(backup_name)
    var backup_a: Dictionary = save.create_default_state()
    backup_a["coins"] = 11
    var backup_b: Dictionary = backup_a.duplicate(true)
    backup_b["coins"] = 22
    _check("first persistence write succeeds", save.write_state(backup_a, backup_path, backup_path + ".bak")["ok"])
    _check("second persistence write succeeds", save.write_state(backup_b, backup_path, backup_path + ".bak")["ok"])
    var backup_saved := save.decode_state(FileAccess.open(backup_path + ".bak", FileAccess.READ).get_as_text())
    _check("backup contains the last known good primary", backup_saved.get("coins") == 11)

    _write_text(backup_path, "{\"schema_version\":2,\"islands\":")
    var recovered := save.read_state(backup_path, backup_path + ".bak", _path("backup_legacy.cfg"))
    _check("malformed primary recovers valid backup", recovered["status"] == save.STATUS_RECOVERED and recovered["source"] == "backup" and recovered["state"]["coins"] == 11)

    var fallback_name := "fallback.json"
    _clean(fallback_name)
    var fallback_path := _path(fallback_name)
    _write_text(fallback_path, "partial")
    _write_text(fallback_path + ".bak", "also partial")
    var fallback := save.read_state(fallback_path, fallback_path + ".bak", _path("fallback_legacy.cfg"))
    _check("malformed primary and backup use safe fallback", fallback["status"] == save.STATUS_FALLBACK and fallback["source"] == "default" and fallback["state"]["unlocked_islands"].has("sunny_cove"))

    var unsupported_name := "unsupported.json"
    _clean(unsupported_name)
    var unsupported_path := _path(unsupported_name)
    _write_text(unsupported_path, JSON.stringify({"schema_version": 99, "unlocked_islands": [], "islands": {}, "legacy_best_score": 0, "boosters": {}, "coins": 0}))
    var unsupported := save.read_state(unsupported_path, unsupported_path + ".bak", _path("unsupported_legacy.cfg"))
    _check("future schema is surfaced as unsupported", unsupported["status"] == save.STATUS_UNSUPPORTED and unsupported["reason"] == "UNSUPPORTED_SCHEMA_WITHOUT_VALID_BACKUP")

    var old_name := "older_schema.json"
    _clean(old_name)
    var old_path := _path(old_name)
    var old_state := save.create_default_state()
    old_state.erase("legacy_best_score")
    old_state["schema_version"] = 1
    _write_text(old_path, JSON.stringify(old_state))
    var migrated := save.read_state(old_path, old_path + ".bak", _path("older_legacy.cfg"))
    _check("older schema uses the migration entry point", migrated["status"] == save.STATUS_MIGRATED and migrated["state"]["schema_version"] == save.schema_version() and migrated["state"].has("legacy_best_score"))

    var legacy_name := "legacy_campaign.json"
    _clean(legacy_name)
    var legacy_path := _path(legacy_name)
    var legacy_cfg_path := _path("legacy_save.cfg")
    _remove(legacy_cfg_path)
    _legacy_save(legacy_cfg_path, 1234)
    var legacy_first := save.read_state(legacy_path, legacy_path + ".bak", legacy_cfg_path)
    var legacy_second := save.read_state(legacy_path, legacy_path + ".bak", legacy_cfg_path)
    _check("legacy best score migrates without rewriting legacy save", legacy_first["legacy_migrated"] and legacy_first["state"]["legacy_best_score"] == 1234 and legacy_second["state"]["legacy_best_score"] == 1234 and ConfigFile.new().load(legacy_cfg_path) == OK)
    var higher_state: Dictionary = legacy_second["state"].duplicate(true)
    higher_state["legacy_best_score"] = 2000
    _check("higher campaign best is preserved over repeated legacy migration", save.write_state(higher_state, legacy_path, legacy_path + ".bak")["ok"] and save.read_state(legacy_path, legacy_path + ".bak", legacy_cfg_path)["state"]["legacy_best_score"] == 2000)

    var invalid_name := "invalid_write.json"
    _clean(invalid_name)
    var invalid_path := _path(invalid_name)
    var valid_before: Dictionary = save.create_default_state()
    valid_before["coins"] = 77
    _check("baseline for failed write is stored", save.write_state(valid_before, invalid_path, invalid_path + ".bak")["ok"])
    var invalid_state := valid_before.duplicate(true)
    invalid_state["coins"] = -1
    var invalid_write := save.write_state(invalid_state, invalid_path, invalid_path + ".bak")
    var after_invalid := save.read_state(invalid_path, invalid_path + ".bak", _path("invalid_legacy.cfg"))
    _check("invalid write does not destroy previous valid state", not invalid_write["ok"] and after_invalid["state"]["coins"] == 77)

    var database = _database()
    var campaign = campaign_script.new()
    var initial_campaign_state: Dictionary = save.create_default_state()
    _check("CampaignManager configures from loaded state", campaign.configure(database, initial_campaign_state) and campaign.is_island_unlocked("sunny_cove") and not campaign.is_island_unlocked("tiki_island"))
    var complete_one := campaign.mark_level_completed("sunny_cove", 1, {"stars": 2, "score": 100})
    _check("completion unlocks next level", complete_one["ok"] and campaign.is_level_unlocked("sunny_cove", 2) and campaign.get_next_level("sunny_cove", 1)["level_id"] == 2)
    var worse_replay := campaign.mark_level_completed("sunny_cove", 1, {"stars": 1, "score": 50})
    _check("worse replay preserves best stars and score without state change", worse_replay["ok"] and not worse_replay["changed"] and worse_replay["record"]["stars"] == 2 and worse_replay["record"]["best_score"] == 100)
    var better_replay := campaign.mark_level_completed("sunny_cove", 1, {"stars": 3, "score": 150})
    _check("better replay upgrades stars and score", better_replay["changed"] and better_replay["record"]["stars"] == 3 and better_replay["record"]["best_score"] == 150)
    var complete_final := campaign.mark_level_completed("sunny_cove", 2, {"stars": 1, "score": 80})
    _check("final level unlocks next island by canonical rule", complete_final["ok"] and campaign.is_island_complete("sunny_cove") and campaign.is_island_unlocked("tiki_island") and campaign.get_next_island("sunny_cove")["island_id"] == "tiki_island")
    var milestone := campaign.claim_milestone("sunny_cove", 2)
    var duplicate_milestone := campaign.claim_milestone("sunny_cove", 2)
    _check("milestone claim is one-time and idempotent", milestone["changed"] and duplicate_milestone["duplicate"] and campaign.is_milestone_claimed("sunny_cove", 2))

    var progression_path := _path("progression.json")
    _clean("progression.json")
    var progression_state: Dictionary = campaign.get_progression_state()
    _check("progression state persists", save.write_state(progression_state, progression_path, progression_path + ".bak")["ok"])
    var reloaded := save.read_state(progression_path, progression_path + ".bak", _path("progression_legacy.cfg"))
    var campaign_reloaded = campaign_script.new()
    _check("persisted progression reloads identically", reloaded["ok"] and reloaded["state"] == progression_state and campaign_reloaded.configure(database, reloaded["state"]) and campaign_reloaded.is_island_unlocked("tiki_island") and campaign_reloaded.is_milestone_claimed("sunny_cove", 2))

    if failures.is_empty():
        print("M11_SAVE_MIGRATION_PROGRESSION_RESULT=PASS")
        quit(0)
        return
    print("M11_SAVE_MIGRATION_PROGRESSION_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
