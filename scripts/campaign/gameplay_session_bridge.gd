class_name GameplaySessionBridge
extends RefCounted

## Boundary between campaign definitions and the existing gameplay scene.
## No timer, scene rewrite, VIP runtime, or physics configuration is performed.

var level_database
var active_island_id := ""
var active_level_id := 0
var _active_level: Dictionary = {}


func configure(database) -> void:
    level_database = database
    clear_session()


func start_session(island_id: String, level_id: int) -> Dictionary:
    if level_database == null or not level_database.is_loaded():
        return {}
    var level: Dictionary = level_database.get_level(island_id, level_id)
    if level.is_empty():
        return {}
    active_island_id = island_id
    active_level_id = level_id
    _active_level = level
    return get_session_configuration()


func get_session_configuration() -> Dictionary:
    if _active_level.is_empty():
        return {}
    var snapshot := _active_level.duplicate(true)
    snapshot.make_read_only()
    return {
        "island_id": active_island_id,
        "level_id": active_level_id,
        "level_definition": snapshot,
        "timer_configured": false,
        "vip_runtime_configured": false,
    }


func submit_result(result: Dictionary) -> Dictionary:
    if _active_level.is_empty():
        return {"ok": false, "reason": "NO_ACTIVE_SESSION"}
    return {
        "ok": true,
        "island_id": active_island_id,
        "level_id": active_level_id,
        "result": result.duplicate(true),
    }


func clear_session() -> void:
    active_island_id = ""
    active_level_id = 0
    _active_level.clear()
