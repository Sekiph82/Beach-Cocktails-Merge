class_name SaveManager
extends RefCounted

## M10 save schema/API boundary.
##
## M10 deliberately does not read or write the live user save. M11 owns
## user:// persistence, atomic replacement, backups, and migration execution.

const SCHEMA_VERSION := 1
const DEFAULT_SAVE_PATH := "user://campaign_save.json"
const LIVE_PERSISTENCE_DEFERRED := "LIVE_PERSISTENCE_DEFERRED_TO_M11"


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
        "boosters": {},
        "coins": 0,
    }


func schema_version() -> int:
    return SCHEMA_VERSION


func validate_state(state: Variant) -> Dictionary:
    if not state is Dictionary:
        return {"ok": false, "reason": "STATE_MUST_BE_OBJECT"}
    if int(state.get("schema_version", -1)) != SCHEMA_VERSION:
        return {"ok": false, "reason": "UNSUPPORTED_SCHEMA_VERSION"}
    for key in ["unlocked_islands", "islands", "boosters", "coins"]:
        if not state.has(key):
            return {"ok": false, "reason": "MISSING_KEY:%s" % key}
    if not state["unlocked_islands"] is Array or not state["islands"] is Dictionary or not state["boosters"] is Dictionary:
        return {"ok": false, "reason": "INVALID_STATE_SHAPE"}
    if int(state["coins"]) < 0:
        return {"ok": false, "reason": "NEGATIVE_COINS"}
    return {"ok": true}


func encode_state(state: Dictionary) -> String:
    var validation := validate_state(state)
    if not validation["ok"]:
        return ""
    return JSON.stringify(state, "\t")


func decode_state(serialized: String) -> Dictionary:
    var parsed = JSON.parse_string(serialized)
    if not validate_state(parsed)["ok"]:
        return {}
    return parsed.duplicate(true)


func read_state(_path: String = DEFAULT_SAVE_PATH) -> Dictionary:
    ## Contract placeholder: M10 returns a safe default and never touches disk.
    return create_default_state()


func write_state(state: Dictionary, _path: String = DEFAULT_SAVE_PATH) -> Dictionary:
    ## Contract placeholder: M11 will atomically write temp -> backup -> final.
    var validation := validate_state(state)
    if not validation["ok"]:
        return validation
    return {"ok": false, "reason": LIVE_PERSISTENCE_DEFERRED, "serialized": encode_state(state)}


func migrate_state(_state: Dictionary, _from_version: int) -> Dictionary:
    ## M11 migration entry point. No live migration occurs in M10.
    return {"ok": false, "reason": LIVE_PERSISTENCE_DEFERRED}
