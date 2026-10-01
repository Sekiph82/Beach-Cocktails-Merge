extends SceneTree

## BCM-M20-006 focused probe for campaign persistence and preference isolation.

const SAVE_SCRIPT := preload("res://scripts/campaign/save_manager.gd")
const SETTINGS_SCRIPT := preload("res://scripts/campaign/user_settings.gd")
const SHELL_SCENE := preload("res://scenes/campaign/ApplicationShellScene.tscn")

var failures: Array[String] = []


func _init() -> void:
    call_deferred("_run")


func _check(label: String, condition: bool) -> void:
    if condition:
        print("M20_CHILD_06_PROBE PASS: %s" % label)
    else:
        failures.append(label)
        print("M20_CHILD_06_PROBE FAIL: %s" % label)


func _path(stem: String) -> String:
    return "user://m20_migration_%s_%s" % [str(Time.get_ticks_usec()), stem]


func _write_text(path: String, text: String) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    file.store_string(text)
    file = null


func _read_text(path: String) -> String:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return ""
    var text := file.get_as_text()
    file = null
    return text


func _valid_state(save) -> Dictionary:
    var state: Dictionary = save.create_default_state()
    state["coins"] = 37
    state["legacy_best_score"] = 914
    state["boosters"] = {"ice": 2}
    state["reward_ledger"] = ["sunny_cove:level_1:star_3"]
    state["islands"]["sunny_cove"]["highest_unlocked_level"] = 3
    state["islands"]["sunny_cove"]["claimed_milestones"] = [2]
    state["islands"]["sunny_cove"]["claimed_star_rewards"] = [3]
    state["islands"]["sunny_cove"]["completed_levels"] = {
        "1": {"stars": 3, "best_score": 914},
        "2": {"stars": 2, "best_score": 702},
    }
    return state


func _mount_shell(onboarding_path: String, settings_path: String):
    var shell = SHELL_SCENE.instantiate()
    shell.onboarding_storage_path = onboarding_path
    shell.settings_storage_path = settings_path
    root.add_child(shell)
    await process_frame
    await process_frame
    return shell


func _run() -> void:
    var save = SAVE_SCRIPT.new()
    var campaign_path := _path("campaign.json")
    var backup_path := campaign_path + ".bak"
    var legacy_path := _path("legacy.cfg")
    var current_state := _valid_state(save)

    var write_result := save.write_state(current_state, campaign_path, backup_path)
    var roundtrip := save.read_state(campaign_path, backup_path, legacy_path)
    _check("current campaign save round-trips without data loss", write_result["ok"] and roundtrip["status"] == save.STATUS_VALID and roundtrip["state"] == current_state)

    var v1_path := _path("v1.json")
    var v1_state: Dictionary = current_state.duplicate(true)
    v1_state["schema_version"] = 1
    v1_state.erase("legacy_best_score")
    v1_state.erase("boosters")
    v1_state.erase("coins")
    v1_state.erase("reward_ledger")
    v1_state["islands"]["sunny_cove"].erase("claimed_star_rewards")
    _write_text(v1_path, JSON.stringify(v1_state))
    var migrated := save.read_state(v1_path, v1_path + ".bak", _path("v1_legacy.cfg"))
    _check("v1 campaign save migrates to the current schema", migrated["status"] == save.STATUS_MIGRATED and migrated["state"]["schema_version"] == save.schema_version())
    _check("M15/M18 stars, replay score, and reward fields survive migration", migrated["state"]["islands"]["sunny_cove"]["completed_levels"]["1"]["stars"] == 3 and migrated["state"]["islands"]["sunny_cove"]["completed_levels"]["1"]["best_score"] == 914 and migrated["state"]["islands"]["sunny_cove"].has("claimed_star_rewards") and migrated["state"].has("reward_ledger"))

    var legacy_path_json := _path("legacy_campaign.json")
    var legacy_cfg_path := _path("legacy.cfg")
    var legacy := ConfigFile.new()
    legacy.set_value("records", "best", 1234)
    legacy.save(legacy_cfg_path)
    var legacy_result := save.read_state(legacy_path_json, legacy_path_json + ".bak", legacy_cfg_path)
    _check("legacy best score migrates without rewriting the legacy source", legacy_result["legacy_migrated"] and legacy_result["state"]["legacy_best_score"] == 1234 and ConfigFile.new().load(legacy_cfg_path) == OK)

    var recovery_path := _path("recovery.json")
    var recovery_a: Dictionary = _valid_state(save)
    recovery_a["coins"] = 11
    var recovery_b: Dictionary = recovery_a.duplicate(true)
    recovery_b["coins"] = 22
    _check("recovery fixture writes two valid generations", save.write_state(recovery_a, recovery_path, recovery_path + ".bak")["ok"] and save.write_state(recovery_b, recovery_path, recovery_path + ".bak")["ok"])
    _write_text(recovery_path, "{\"schema_version\":2,\"islands\":")
    var recovered := save.read_state(recovery_path, recovery_path + ".bak", _path("recovery_legacy.cfg"))
    _check("corrupt primary recovers the valid backup", recovered["status"] == save.STATUS_RECOVERED and recovered["source"] == "backup" and recovered["state"]["coins"] == 11)

    var future_path := _path("future.json")
    var future_text := JSON.stringify({"schema_version": 99, "unlocked_islands": [], "islands": {}, "legacy_best_score": 0, "boosters": {}, "coins": 0})
    _write_text(future_path, future_text)
    var future_before := _read_text(future_path)
    var future := save.read_state(future_path, future_path + ".bak", _path("future_legacy.cfg"))
    _check("future schema is reported unsupported", future["status"] == save.STATUS_UNSUPPORTED and future["reason"] == "UNSUPPORTED_SCHEMA_WITHOUT_VALID_BACKUP")
    _check("unsupported future save remains non-destructive", _read_text(future_path) == future_before and not FileAccess.file_exists(future_path + ".bak"))

    var onboarding_path := _path("onboarding.json")
    var settings_path := _path("settings.json")
    var shell = await _mount_shell(onboarding_path, settings_path)
    if shell.is_onboarding_visible():
        shell.skip_onboarding()
        await process_frame
    var campaign_bytes_before := _read_text(campaign_path)
    shell.set_setting("reduced_motion", true)
    shell.set_setting("high_contrast", true)
    shell.set_setting("haptics_enabled", false)
    shell.reset_onboarding_state()
    await process_frame
    shell.skip_onboarding()
    await process_frame
    _check("settings and onboarding use independent storage files", FileAccess.file_exists(settings_path) and FileAccess.file_exists(onboarding_path) and _read_text(campaign_path) == campaign_bytes_before)
    shell.queue_free()
    await process_frame

    var corrupt_settings_path := _path("corrupt_settings.json")
    _write_text(corrupt_settings_path, "not-json")
    var settings = SETTINGS_SCRIPT.new()
    var settings_state := settings.load_settings(corrupt_settings_path)
    _check("corrupt settings fall back to safe defaults", settings_state["schema_version"] == settings.SCHEMA_VERSION and is_equal_approx(float(settings_state["master_volume"]), 1.0) and bool(settings_state["haptics_enabled"]))
    _check("missing or corrupt settings do not alter campaign save", _read_text(campaign_path) == campaign_bytes_before)

    if failures.is_empty():
        print("M20_CHILD_06_RESULT=PASS")
        quit(0)
        return
    print("M20_CHILD_06_RESULT=FAIL failures=%s" % str(failures))
    quit(1)
