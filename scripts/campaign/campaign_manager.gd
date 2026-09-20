class_name CampaignManager
extends RefCounted

## Runtime campaign selection/progression boundary for M10.
## Static definitions remain owned by LevelDatabase; persistence is owned by
## SaveManager and is intentionally not invoked here.

signal selection_changed(island_id: String, level_id: int)
signal progression_changed(island_id: String, level_id: int)

var level_database
var current_island_id := ""
var selected_level_id := 0
var _state: Dictionary = {}


func configure(database, progression_state: Dictionary = {}) -> bool:
    if database == null or not database.is_loaded():
        return false
    level_database = database
    _state = progression_state.duplicate(true)
    current_island_id = _first_unlocked_island()
    selected_level_id = _highest_unlocked_level(current_island_id)
    return not current_island_id.is_empty()


func select_level(island_id: String, level_id: int) -> bool:
    if not is_level_unlocked(island_id, level_id):
        return false
    current_island_id = island_id
    selected_level_id = level_id
    selection_changed.emit(island_id, level_id)
    return true


func is_island_unlocked(island_id: String) -> bool:
    var island: Dictionary = level_database.get_island(island_id) if level_database != null else {}
    if island.is_empty():
        return false
    var unlocked: Array = _state.get("unlocked_islands", ["sunny_cove"])
    return unlocked.has(island_id) or str(island.get("unlock_rule", {}).get("type", "")) == "default_open"


func is_level_unlocked(island_id: String, level_id: int) -> bool:
    if not is_island_unlocked(island_id) or level_database == null:
        return false
    if level_database.get_level(island_id, level_id).is_empty():
        return false
    return level_id <= _highest_unlocked_level(island_id)


func mark_level_completed(island_id: String, level_id: int, result: Dictionary = {}) -> Dictionary:
    if not is_level_unlocked(island_id, level_id):
        return {"ok": false, "reason": "LEVEL_LOCKED"}
    var island_state: Dictionary = _state.get("islands", {}).get(island_id, {}).duplicate(true)
    var completed: Dictionary = island_state.get("completed_levels", {}).duplicate(true)
    var key := str(level_id)
    var old_record: Dictionary = completed.get(key, {})
    var new_record: Dictionary = old_record.duplicate(true)
    new_record["stars"] = maxi(int(old_record.get("stars", 0)), int(result.get("stars", 1)))
    new_record["best_score"] = maxi(int(old_record.get("best_score", 0)), int(result.get("score", 0)))
    new_record["completed"] = true
    completed[key] = new_record
    island_state["completed_levels"] = completed
    island_state["highest_unlocked_level"] = maxi(int(island_state.get("highest_unlocked_level", 1)), level_id + 1)
    var progression_islands: Dictionary = _state.get("islands", {}).duplicate(true)
    progression_islands[island_id] = island_state
    _state["islands"] = progression_islands
    progression_changed.emit(island_id, level_id)
    return {"ok": true, "changed": old_record != new_record, "record": new_record.duplicate(true)}


func get_progression_state() -> Dictionary:
    return _state.duplicate(true)


func _first_unlocked_island() -> String:
    if level_database == null:
        return ""
    for island_id in level_database.get_island_ids():
        if is_island_unlocked(island_id):
            return island_id
    return ""


func _highest_unlocked_level(island_id: String) -> int:
    return maxi(1, int(_state.get("islands", {}).get(island_id, {}).get("highest_unlocked_level", 1)))
