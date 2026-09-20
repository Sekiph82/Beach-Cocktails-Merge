class_name SaveManager
extends RefCounted

## Schema-versioned campaign persistence. Gameplay's legacy ConfigFile remains
## owned by GameManager; this service only reads it during campaign migration.

const SCHEMA_VERSION := 2
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
            },
        },
        "legacy_best_score": 0,
        "boosters": {},
        "coins": 0,
    }


func schema_version() -> int:
    return SCHEMA_VERSION


func validate_state(state: Variant) -> Dictionary:
    if not state is Dictionary:
        return {"ok": false, "reason": "STATE_MUST_BE_OBJECT"}
    var schema_value = state.get("schema_version", null)
    if (typeof(schema_value) != TYPE_INT and typeof(schema_value) != TYPE_FLOAT) or int(schema_value) != SCHEMA_VERSION or not is_equal_approx(float(schema_value), float(SCHEMA_VERSION)):
        return {"ok": false, "reason": "UNSUPPORTED_SCHEMA_VERSION"}
    for key in ["unlocked_islands", "islands", "legacy_best_score", "boosters", "coins"]:
        if not state.has(key):
            return {"ok": false, "reason": "MISSING_KEY:%s" % key}
    if not state["unlocked_islands"] is Array or not state["islands"] is Dictionary or not state["boosters"] is Dictionary:
        return {"ok": false, "reason": "INVALID_STATE_SHAPE"}
    if not _is_non_negative_number(state["coins"]) or not _is_non_negative_number(state["legacy_best_score"]):
        return {"ok": false, "reason": "NEGATIVE_OR_INVALID_GLOBAL_VALUE"}
    for island_id in state["unlocked_islands"]:
        if typeof(island_id) != TYPE_STRING or str(island_id).is_empty():
            return {"ok": false, "reason": "INVALID_UNLOCKED_ISLAND"}
    for island_id in state["islands"]:
        var island_state = state["islands"][island_id]
        if not island_state is Dictionary:
            return {"ok": false, "reason": "INVALID_ISLAND_STATE:%s" % island_id}
        if not _is_non_negative_number(island_state.get("highest_unlocked_level", -1)) or int(island_state.get("highest_unlocked_level", 0)) < 1:
            return {"ok": false, "reason": "INVALID_HIGHEST_LEVEL:%s" % island_id}
        if not island_state.get("completed_levels", {}) is Dictionary or not island_state.get("claimed_milestones", []) is Array:
            return {"ok": false, "reason": "INVALID_ISLAND_COLLECTIONS:%s" % island_id}
        for level_id in island_state["completed_levels"]:
            var record = island_state["completed_levels"][level_id]
            if not record is Dictionary or not _is_non_negative_number(record.get("stars", 0)) or not _is_non_negative_number(record.get("best_score", 0)):
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
        selected = primary["state"].duplicate(true)
        status = STATUS_MIGRATED if primary["migrated"] else STATUS_VALID
        reason = primary["reason"]
        source = "primary"
        should_persist_recovery = bool(primary["migrated"])
    else:
        var backup := _read_candidate(resolved_backup)
        if backup["ok"]:
            selected = backup["state"].duplicate(true)
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
    if from_version != 1:
        return {"ok": false, "reason": "UNSUPPORTED_SCHEMA_VERSION"}
    var migrated := state.duplicate(true)
    migrated["schema_version"] = SCHEMA_VERSION
    if not migrated.has("legacy_best_score"):
        migrated["legacy_best_score"] = 0
    if not migrated.has("boosters"):
        migrated["boosters"] = {}
    if not migrated.has("coins"):
        migrated["coins"] = 0
    for island_id in migrated.get("islands", {}):
        var island_state: Dictionary = migrated["islands"][island_id]
        if not island_state.has("completed_levels"):
            island_state["completed_levels"] = {}
        if not island_state.has("claimed_milestones"):
            island_state["claimed_milestones"] = []
        if not island_state.has("highest_unlocked_level"):
            island_state["highest_unlocked_level"] = 1
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
