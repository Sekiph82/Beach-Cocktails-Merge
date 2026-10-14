class_name SaveManager
extends RefCounted

## Schema-versioned campaign persistence. Gameplay's legacy ConfigFile remains
## owned by GameManager; this service only reads it during campaign migration.

const SCHEMA_VERSION := 4
const DEFAULT_SAVE_PATH := "user://campaign_save.json"
const DEFAULT_BACKUP_PATH := "user://campaign_save.json.bak"
const DEFAULT_LEGACY_PATH := "user://save.cfg"
const TEMP_SUFFIX := ".tmp"

const STATUS_VALID := "valid"
const STATUS_MISSING := "missing"
const STATUS_MIGRATED := "migrated"
const STATUS_RECOVERED := "recovered"
const STATUS_FALLBACK := "fallback"
const STATUS_UNSUPPORTED := "unsupported"


func create_default_state() -> Dictionary:
    return {
        "schema_version": SCHEMA_VERSION,
        "unlocked_islands": ["sunny_cove"],
        "islands": {
            "sunny_cove": {
                "highest_unlocked_level": 1,
                "completed_levels": {},
                "claimed_milestones": [],
                "claimed_star_rewards": [],
            },
        },
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 100,
        "gems": 5,
        "energy": 100,
        "energy_last_update_unix": int(Time.get_unix_time_from_system()),
        "energy_regen_remainder_sec": 0,
        "retired_focus_inventory": 0,
        "reward_ledger": [],
        "transaction_ledger": [],
        "daily_claim_ledger": {},
        "daily_high_water_utc_date": "",
    }


func schema_version() -> int:
    return SCHEMA_VERSION


func validate_state(state: Variant) -> Dictionary:
    if not state is Dictionary:
        return {"ok": false, "reason": "STATE_MUST_BE_OBJECT"}
    var schema_value = state.get("schema_version", null)
    if (typeof(schema_value) != TYPE_INT and typeof(schema_value) != TYPE_FLOAT) or int(schema_value) != SCHEMA_VERSION or not is_equal_approx(float(schema_value), float(SCHEMA_VERSION)):
        return {"ok": false, "reason": "UNSUPPORTED_SCHEMA_VERSION"}
    for key in ["unlocked_islands", "islands", "legacy_best_score", "boosters", "coins", "energy", "energy_last_update_unix", "energy_regen_remainder_sec", "retired_focus_inventory", "daily_claim_ledger", "daily_high_water_utc_date"]:
        if not state.has(key):
            return {"ok": false, "reason": "MISSING_KEY:%s" % key}
    if not state["unlocked_islands"] is Array or not state["islands"] is Dictionary or not state["boosters"] is Dictionary:
        return {"ok": false, "reason": "INVALID_STATE_SHAPE"}
    if not _is_non_negative_number(state["coins"]) or not _is_non_negative_number(state["legacy_best_score"]):
        return {"ok": false, "reason": "NEGATIVE_OR_INVALID_GLOBAL_VALUE"}
    if not _is_non_negative_integer(state["energy"]) or int(state["energy"]) > 100 or not _is_non_negative_integer(state["energy_last_update_unix"]) or not _is_non_negative_integer(state["energy_regen_remainder_sec"]) or int(state["energy_regen_remainder_sec"]) >= 180 or not _is_non_negative_integer(state["retired_focus_inventory"]):
        return {"ok": false, "reason": "INVALID_ENERGY_OR_RETIRED_INVENTORY"}
    if not _is_non_negative_number(state.get("gems", 0)) or not is_equal_approx(float(state.get("gems", 0)), float(int(state.get("gems", 0)))):
        return {"ok": false, "reason": "INVALID_GEMS"}
    for booster_id in state["boosters"]:
        var booster_quantity = state["boosters"][booster_id]
        if typeof(booster_id) != TYPE_STRING or str(booster_id).is_empty() or not _is_non_negative_number(booster_quantity) or not is_equal_approx(float(booster_quantity), float(int(booster_quantity))):
            return {"ok": false, "reason": "INVALID_BOOSTER_INVENTORY"}
    if state.has("reward_ledger"):
        if not state["reward_ledger"] is Array:
            return {"ok": false, "reason": "INVALID_REWARD_LEDGER"}
        for reward_id in state["reward_ledger"]:
            if typeof(reward_id) != TYPE_STRING or str(reward_id).is_empty():
                return {"ok": false, "reason": "INVALID_REWARD_ID"}
    if state.has("transaction_ledger"):
        if not state["transaction_ledger"] is Array:
            return {"ok": false, "reason": "INVALID_TRANSACTION_LEDGER"}
        for transaction_id in state["transaction_ledger"]:
            if typeof(transaction_id) != TYPE_STRING or str(transaction_id).is_empty():
                return {"ok": false, "reason": "INVALID_TRANSACTION_ID"}
    if not state["daily_claim_ledger"] is Dictionary or not _valid_utc_date_or_empty(str(state["daily_high_water_utc_date"])):
        return {"ok": false, "reason": "INVALID_DAILY_REWARD_STATE"}
    for claim_key in state["daily_claim_ledger"]:
        var entry = state["daily_claim_ledger"][claim_key]
        if typeof(claim_key) != TYPE_STRING or not _valid_daily_claim_key(str(claim_key)) or not entry is Dictionary or typeof(entry.get("transaction_id", null)) != TYPE_STRING or typeof(entry.get("receipt", null)) != TYPE_STRING:
            return {"ok": false, "reason": "INVALID_DAILY_CLAIM_ENTRY"}
        var split_at := str(claim_key).rfind(":")
        var slot := int(str(claim_key).substr(split_at + 1))
        var expected_transaction := "daily:%s:%d" % [str(claim_key).substr(0, split_at), slot]
        var transactions: Array = state.get("transaction_ledger", [])
        if str(entry["transaction_id"]) != expected_transaction or not transactions.has(expected_transaction):
            return {"ok": false, "reason": "INVALID_DAILY_CLAIM_TRANSACTION"}
        var receipt := str(entry["receipt"])
        if slot == 1 and not receipt.is_empty():
            return {"ok": false, "reason": "INVALID_FREE_DAILY_RECEIPT"}
        if slot > 1 and (receipt.is_empty() or not transactions.has("daily-provider-receipt:%s" % receipt)):
            return {"ok": false, "reason": "INVALID_REWARDED_DAILY_RECEIPT"}
    for island_id in state["unlocked_islands"]:
        if typeof(island_id) != TYPE_STRING or str(island_id).is_empty():
            return {"ok": false, "reason": "INVALID_UNLOCKED_ISLAND"}
    for island_id in state["islands"]:
        var island_state = state["islands"][island_id]
        if not island_state is Dictionary:
            return {"ok": false, "reason": "INVALID_ISLAND_STATE:%s" % island_id}
        if not _is_non_negative_number(island_state.get("highest_unlocked_level", -1)) or int(island_state.get("highest_unlocked_level", 0)) < 1:
            return {"ok": false, "reason": "INVALID_HIGHEST_LEVEL:%s" % island_id}
        if not island_state.get("completed_levels", {}) is Dictionary or not island_state.get("claimed_milestones", []) is Array or not island_state.get("claimed_star_rewards", []) is Array:
            return {"ok": false, "reason": "INVALID_ISLAND_COLLECTIONS:%s" % island_id}
        for threshold in island_state.get("claimed_star_rewards", []):
            if not _is_positive_integer(threshold):
                return {"ok": false, "reason": "INVALID_CUMULATIVE_REWARD_CLAIM:%s" % island_id}
        for level_id in island_state["completed_levels"]:
            var record = island_state["completed_levels"][level_id]
            if not record is Dictionary or not _is_bounded_stars(record.get("stars", 0)) or not _is_non_negative_number(record.get("best_score", 0)):
                return {"ok": false, "reason": "INVALID_COMPLETION_RECORD:%s/%s" % [island_id, level_id]}
    return {"ok": true, "reason": "VALID"}


func encode_state(state: Dictionary) -> String:
    var validation := validate_state(state)
    if not validation["ok"]:
        return ""
    return JSON.stringify(state, "\t")


func decode_state(serialized: String) -> Dictionary:
    var parsed = JSON.parse_string(serialized)
    parsed = _normalize_json_numbers(parsed)
    parsed = _normalize_m15_fields(parsed)
    if not validate_state(parsed)["ok"]:
        return {}
    return parsed.duplicate(true)


func read_state(
        path: String = DEFAULT_SAVE_PATH,
        backup_path: String = "",
        legacy_path: String = DEFAULT_LEGACY_PATH
    ) -> Dictionary:
    return load_state(path, backup_path, legacy_path)


func load_state(
        path: String = DEFAULT_SAVE_PATH,
        backup_path: String = "",
        legacy_path: String = DEFAULT_LEGACY_PATH
    ) -> Dictionary:
    var resolved_backup := _resolve_backup_path(path, backup_path)
    var primary := _read_candidate(path)
    var selected: Dictionary = {}
    var status := ""
    var reason := ""
    var source := ""
    var should_persist_recovery := false

    if primary["ok"]:
        selected = _normalize_m15_fields(primary["state"].duplicate(true))
        status = STATUS_MIGRATED if primary["migrated"] else STATUS_VALID
        reason = primary["reason"]
        source = "primary"
        should_persist_recovery = bool(primary["migrated"])
    else:
        var backup := _read_candidate(resolved_backup)
        if backup["ok"]:
            selected = _normalize_m15_fields(backup["state"].duplicate(true))
            status = STATUS_RECOVERED
            reason = "PRIMARY_%s_BACKUP_VALID" % primary["reason"]
            source = "backup"
            should_persist_recovery = true
        else:
            selected = create_default_state()
            source = "default"
            if primary["status"] == STATUS_MISSING and backup["status"] == STATUS_MISSING:
                status = STATUS_MISSING
                reason = "NO_CAMPAIGN_SAVE"
            elif primary["reason"] == "UNSUPPORTED_SCHEMA_VERSION":
                status = STATUS_UNSUPPORTED
                reason = "UNSUPPORTED_SCHEMA_WITHOUT_VALID_BACKUP"
            else:
                status = STATUS_FALLBACK
                reason = "NO_VALID_PRIMARY_OR_BACKUP"

    var legacy := migrate_legacy_best_score(selected, legacy_path)
    if legacy["ok"] and legacy["changed"]:
        selected = legacy["state"].duplicate(true)
        should_persist_recovery = true
        if status == STATUS_VALID:
            status = STATUS_MIGRATED
            reason = "LEGACY_BEST_SCORE_MIGRATED"
        elif status == STATUS_MISSING:
            reason = "LEGACY_BEST_SCORE_MIGRATED_FROM_FRESH_STATE"
        else:
            reason += ";LEGACY_BEST_SCORE_MIGRATED"

    if should_persist_recovery:
        var persisted := write_state(selected, path, resolved_backup)
        if not persisted["ok"]:
            reason += ";PERSIST_AFTER_LOAD_FAILED:%s" % persisted["reason"]

    return _load_result(true, status, reason, selected, source, legacy.get("changed", false))


func write_state(
        state: Dictionary,
        path: String = DEFAULT_SAVE_PATH,
        backup_path: String = ""
    ) -> Dictionary:
    var validation := validate_state(state)
    if not validation["ok"]:
        return {"ok": false, "status": "rejected", "reason": validation["reason"]}
    var serialized := encode_state(state)
    if serialized.is_empty():
        return {"ok": false, "status": "rejected", "reason": "SERIALIZATION_FAILED"}

    var resolved_backup := _resolve_backup_path(path, backup_path)
    var temp_path := path + TEMP_SUFFIX
    if not _ensure_parent_directory(path) or not _ensure_parent_directory(resolved_backup):
        return {"ok": false, "status": "failed", "reason": "SAVE_DIRECTORY_CREATE_FAILED"}

    var temp_file := FileAccess.open(temp_path, FileAccess.WRITE)
    if temp_file == null:
        return {"ok": false, "status": "failed", "reason": "TEMP_OPEN_FAILED"}
    temp_file.store_string(serialized)
    temp_file.flush()
    temp_file.close()

    # Preserve only a valid previous primary. A malformed primary must never
    # overwrite a valid backup during recovery or repair.
    if FileAccess.file_exists(path) and _raw_file_is_recoverable(path):
        var backup_error: Error = DirAccess.copy_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(resolved_backup))
        if backup_error != OK:
            _remove_file(temp_path)
            return {"ok": false, "status": "failed", "reason": "BACKUP_COPY_FAILED:%s" % backup_error}

    var replace_error: Error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(path))
    if replace_error != OK:
        _remove_file(temp_path)
        return {"ok": false, "status": "failed", "reason": "ATOMIC_REPLACE_FAILED:%s" % replace_error}
    return {"ok": true, "status": "written", "reason": "SAVE_WRITTEN", "state": state.duplicate(true)}


func migrate_state(state: Dictionary, from_version: int) -> Dictionary:
    if from_version == SCHEMA_VERSION:
        var current_validation := validate_state(state)
        if current_validation["ok"]:
            return {"ok": true, "state": state.duplicate(true), "changed": false, "reason": "CURRENT_SCHEMA"}
        return {"ok": false, "reason": current_validation["reason"]}
    if from_version < 1 or from_version > 3:
        return {"ok": false, "reason": "UNSUPPORTED_SCHEMA_VERSION"}
    var migrated := state.duplicate(true)
    migrated["schema_version"] = SCHEMA_VERSION
    if not migrated.has("daily_claim_ledger"):
        migrated["daily_claim_ledger"] = {}
    if not migrated.has("daily_high_water_utc_date"):
        migrated["daily_high_water_utc_date"] = ""
    if not migrated.has("legacy_best_score"):
        migrated["legacy_best_score"] = 0
    if not migrated.has("boosters"):
        migrated["boosters"] = {}
    if not migrated.has("coins"):
        migrated["coins"] = 0
    if not migrated.has("gems"):
        migrated["gems"] = 0
    if not migrated.has("reward_ledger"):
        migrated["reward_ledger"] = []
    if not migrated.has("transaction_ledger"):
        migrated["transaction_ledger"] = []
    if not migrated.has("energy"):
        migrated["energy"] = 100
    if not migrated.has("energy_last_update_unix"):
        migrated["energy_last_update_unix"] = int(Time.get_unix_time_from_system())
    if not migrated.has("energy_regen_remainder_sec"):
        migrated["energy_regen_remainder_sec"] = 0
    if not migrated.has("retired_focus_inventory"):
        migrated["retired_focus_inventory"] = 0
    var legacy_boosters: Dictionary = migrated.get("boosters", {}).duplicate(true)
    if legacy_boosters.has("focus"):
        migrated["retired_focus_inventory"] = int(migrated["retired_focus_inventory"]) + maxi(0, int(legacy_boosters["focus"]))
        legacy_boosters.erase("focus")
        migrated["boosters"] = legacy_boosters
    for island_id in migrated.get("islands", {}):
        var island_state: Dictionary = migrated["islands"][island_id]
        if not island_state.has("completed_levels"):
            island_state["completed_levels"] = {}
        if not island_state.has("claimed_milestones"):
            island_state["claimed_milestones"] = []
        if not island_state.has("claimed_star_rewards"):
            island_state["claimed_star_rewards"] = []
        if not island_state.has("highest_unlocked_level"):
            island_state["highest_unlocked_level"] = 1
        for level_id in island_state["completed_levels"]:
            var record: Variant = island_state["completed_levels"][level_id]
            if record is Dictionary:
                record["stars"] = clampi(int(record.get("stars", 0)), 0, 3)
                record["best_score"] = maxi(0, int(record.get("best_score", 0)))
    var validation := validate_state(migrated)
    if not validation["ok"]:
        return {"ok": false, "reason": "MIGRATION_INVALID:%s" % validation["reason"]}
    return {"ok": true, "state": migrated, "changed": true, "reason": "MIGRATED_V%d_TO_V%d" % [from_version, SCHEMA_VERSION]}


func migrate_legacy_best_score(state: Dictionary, legacy_path: String = DEFAULT_LEGACY_PATH) -> Dictionary:
    var result := state.duplicate(true)
    if not FileAccess.file_exists(legacy_path):
        return {"ok": true, "changed": false, "reason": "LEGACY_SAVE_MISSING", "state": result}
    var legacy := ConfigFile.new()
    var load_error := legacy.load(legacy_path)
    if load_error != OK:
        return {"ok": false, "changed": false, "reason": "LEGACY_SAVE_READ_FAILED:%s" % load_error, "state": result}
    var raw_score = legacy.get_value("records", "best", null)
    if raw_score == null or not _is_non_negative_number(raw_score):
        return {"ok": true, "changed": false, "reason": "LEGACY_BEST_SCORE_MISSING_OR_INVALID", "state": result}
    var legacy_score := int(raw_score)
    var current_score := int(result.get("legacy_best_score", 0))
    if legacy_score <= current_score:
        return {"ok": true, "changed": false, "reason": "LEGACY_BEST_SCORE_ALREADY_PRESERVED", "state": result}
    result["legacy_best_score"] = legacy_score
    return {"ok": true, "changed": true, "reason": "LEGACY_BEST_SCORE_COPIED", "state": result}


func _read_candidate(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {"ok": false, "status": STATUS_MISSING, "reason": "FILE_MISSING", "migrated": false}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {"ok": false, "status": STATUS_FALLBACK, "reason": "FILE_OPEN_FAILED", "migrated": false}
    var serialized := file.get_as_text()
    file.close()
    var parsed = JSON.parse_string(serialized)
    if parsed == null or not parsed is Dictionary:
        return {"ok": false, "status": STATUS_FALLBACK, "reason": "MALFORMED_JSON", "migrated": false}
    parsed = _normalize_json_numbers(parsed)
    parsed = _normalize_m15_fields(parsed)
    var validation := validate_state(parsed)
    if validation["ok"]:
        return {"ok": true, "status": STATUS_VALID, "reason": "PRIMARY_OR_BACKUP_VALID", "state": parsed.duplicate(true), "migrated": false}
    var raw_version = parsed.get("schema_version", null)
    if typeof(raw_version) != TYPE_INT and typeof(raw_version) != TYPE_FLOAT:
        return {"ok": false, "status": STATUS_FALLBACK, "reason": "MISSING_OR_INVALID_SCHEMA_VERSION", "migrated": false}
    if int(raw_version) > SCHEMA_VERSION:
        return {"ok": false, "status": STATUS_UNSUPPORTED, "reason": "UNSUPPORTED_SCHEMA_VERSION", "migrated": false}
    if int(raw_version) < SCHEMA_VERSION:
        var migration := migrate_state(parsed, int(raw_version))
        if migration["ok"]:
            return {"ok": true, "status": STATUS_MIGRATED, "reason": migration["reason"], "state": migration["state"].duplicate(true), "migrated": true}
        return {"ok": false, "status": STATUS_UNSUPPORTED, "reason": migration["reason"], "migrated": false}
    return {"ok": false, "status": STATUS_FALLBACK, "reason": validation["reason"], "migrated": false}


func _raw_file_is_recoverable(path: String) -> bool:
    if not FileAccess.file_exists(path):
        return false
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if validate_state(parsed)["ok"]:
        return true
    var raw_version = parsed.get("schema_version", null) if parsed is Dictionary else null
    if (typeof(raw_version) == TYPE_INT or typeof(raw_version) == TYPE_FLOAT) and int(raw_version) < SCHEMA_VERSION:
        return migrate_state(parsed, int(raw_version))["ok"]
    return false


func _load_result(ok: bool, status: String, reason: String, state: Dictionary, source: String, legacy_migrated: bool) -> Dictionary:
    return {
        "ok": ok,
        "status": status,
        "reason": reason,
        "source": source,
        "legacy_migrated": legacy_migrated,
        "state": state.duplicate(true),
    }


func _normalize_m15_fields(value: Variant) -> Variant:
    if not value is Dictionary:
        return value
    var normalized: Dictionary = value.duplicate(true)
    if not normalized.has("reward_ledger"):
        # Current-schema saves from before M15 are valid and intentionally load
        # with an empty ledger; no progression fields are rewritten or dropped.
        normalized["reward_ledger"] = []
    if not normalized.has("daily_claim_ledger"):
        normalized["daily_claim_ledger"] = {}
    if not normalized.has("daily_high_water_utc_date"):
        normalized["daily_high_water_utc_date"] = ""
    if normalized.has("islands") and normalized["islands"] is Dictionary:
        for island_id in normalized["islands"]:
            if normalized["islands"][island_id] is Dictionary and not normalized["islands"][island_id].has("claimed_star_rewards"):
                normalized["islands"][island_id]["claimed_star_rewards"] = []
    return normalized


func _valid_utc_date_or_empty(value: String) -> bool:
    return value.is_empty() or _valid_utc_date(value)


func _valid_utc_date(value: String) -> bool:
    if value.length() != 10 or value[4] != "-" or value[7] != "-":
        return false
    var parts := value.split("-")
    if parts.size() != 3 or not parts[0].is_valid_int() or not parts[1].is_valid_int() or not parts[2].is_valid_int():
        return false
    var year := int(parts[0])
    var month := int(parts[1])
    var day := int(parts[2])
    if month < 1 or month > 12 or day < 1 or day > 31:
        return false
    var unix := Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": day, "hour": 0, "minute": 0, "second": 0})
    var normalized: Dictionary = Time.get_datetime_dict_from_unix_time(unix)
    return int(normalized.get("year", -1)) == year and int(normalized.get("month", -1)) == month and int(normalized.get("day", -1)) == day


func _valid_daily_claim_key(value: String) -> bool:
    var split_at := value.rfind(":")
    if split_at != 10 or not _valid_utc_date(value.substr(0, split_at)):
        return false
    var slot := value.substr(split_at + 1)
    return slot.is_valid_int() and int(slot) >= 1 and int(slot) <= 5


func _resolve_backup_path(path: String, backup_path: String) -> String:
    return backup_path if not backup_path.is_empty() else path + ".bak"


func _ensure_parent_directory(path: String) -> bool:
    var parent := path.get_base_dir()
    if parent.is_empty() or parent == ".":
        return true
    return DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(parent)) == OK


func _remove_file(path: String) -> void:
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _is_non_negative_number(value: Variant) -> bool:
    return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and float(value) >= 0.0


func _is_bounded_stars(value: Variant) -> bool:
    return _is_non_negative_number(value) and is_equal_approx(float(value), float(int(value))) and int(value) <= 3


func _is_positive_integer(value: Variant) -> bool:
    return _is_non_negative_number(value) and is_equal_approx(float(value), float(int(value))) and int(value) > 0


func _is_non_negative_integer(value: Variant) -> bool:
    return _is_non_negative_number(value) and is_equal_approx(float(value), float(int(value)))


func _normalize_json_numbers(value: Variant) -> Variant:
    if value is Dictionary:
        var normalized := {}
        for key in value:
            normalized[key] = _normalize_json_numbers(value[key])
        return normalized
    if value is Array:
        var normalized_array: Array = []
        for item in value:
            normalized_array.append(_normalize_json_numbers(item))
        return normalized_array
    if typeof(value) == TYPE_FLOAT and is_equal_approx(float(value), float(int(value))):
        return int(value)
    return value
