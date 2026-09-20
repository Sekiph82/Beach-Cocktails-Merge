class_name CampaignManager
extends RefCounted

## Deterministic campaign progression over LevelDatabase definitions.
## SaveManager owns disk IO; this service owns in-memory state transitions.

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
    _state = _normalized_state(progression_state)
    _refresh_island_unlocks()
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
    if level_database == null:
        return false
    var island: Dictionary = level_database.get_island(island_id)
    if island.is_empty():
        return false
    if _state.get("unlocked_islands", []).has(island_id):
        return true
    return _unlock_rule_satisfied(island.get("unlock_rule", {}))


func is_level_unlocked(island_id: String, level_id: int) -> bool:
    if not is_island_unlocked(island_id) or level_database == null:
        return false
    if level_database.get_level(island_id, level_id).is_empty():
        return false
    return level_id >= 1 and level_id <= _highest_unlocked_level(island_id)


func mark_level_completed(island_id: String, level_id: int, result: Dictionary = {}) -> Dictionary:
    if not is_level_unlocked(island_id, level_id):
        return {"ok": false, "reason": "LEVEL_LOCKED", "changed": false}
    var island_state := _get_island_state(island_id)
    var completed: Dictionary = island_state["completed_levels"].duplicate(true)
    var key := str(level_id)
    var old_record: Dictionary = completed.get(key, {})
    var old_highest_level := int(island_state.get("highest_unlocked_level", 1))
    var new_record: Dictionary = old_record.duplicate(true)
    new_record["stars"] = maxi(int(old_record.get("stars", 0)), clampi(int(result.get("stars", 1)), 1, 3))
    new_record["best_score"] = maxi(int(old_record.get("best_score", 0)), maxi(0, int(result.get("score", 0))))
    new_record["completed"] = true
    if result.has("vip_completed"):
        new_record["vip_completed"] = bool(old_record.get("vip_completed", false)) or bool(result["vip_completed"])
    completed[key] = new_record
    island_state["completed_levels"] = completed
    var declared_count := int(level_database.get_island(island_id).get("level_count", 0))
    if declared_count > 0:
        island_state["highest_unlocked_level"] = mini(declared_count, maxi(int(island_state.get("highest_unlocked_level", 1)), level_id + 1))
    else:
        island_state["highest_unlocked_level"] = maxi(int(island_state.get("highest_unlocked_level", 1)), level_id + 1)
    _set_island_state(island_id, island_state)
    var changed := old_record != new_record or int(island_state.get("highest_unlocked_level", 1)) != old_highest_level
    var unlock_changed := _refresh_island_unlocks()
    changed = changed or unlock_changed
    if changed:
        progression_changed.emit(island_id, level_id)
    return {
        "ok": true,
        "changed": changed,
        "record": new_record.duplicate(true),
        "island_complete": is_island_complete(island_id),
        "next_level": resolve_next_level(island_id, level_id),
        "next_island": resolve_next_island(island_id),
    }


func is_level_completed(island_id: String, level_id: int) -> bool:
    return bool(_get_island_state(island_id).get("completed_levels", {}).get(str(level_id), {}).get("completed", false))


func is_island_complete(island_id: String) -> bool:
    if level_database == null or not is_island_unlocked(island_id):
        return false
    var island: Dictionary = level_database.get_island(island_id)
    var level_count := int(island.get("level_count", 0))
    if level_count <= 0:
        return false
    for level_id in range(1, level_count + 1):
        if level_database.get_level(island_id, level_id).is_empty() or not is_level_completed(island_id, level_id):
            return false
    return true


func resolve_next_level(island_id: String, level_id: int) -> Dictionary:
    if level_database == null:
        return {"ok": false, "reason": "DATABASE_NOT_CONFIGURED"}
    var next_level_id := level_id + 1
    if not level_database.get_level(island_id, next_level_id).is_empty() and is_level_unlocked(island_id, next_level_id):
        return {"ok": true, "island_id": island_id, "level_id": next_level_id, "level": level_database.get_level(island_id, next_level_id)}
    return {"ok": false, "reason": "NO_NEXT_LEVEL", "island_id": island_id, "level_id": level_id}


func get_next_level(island_id: String, level_id: int) -> Dictionary:
    return resolve_next_level(island_id, level_id)


func resolve_next_island(island_id: String) -> Dictionary:
    if level_database == null or not is_island_complete(island_id):
        return {"ok": false, "reason": "ISLAND_INCOMPLETE", "island_id": island_id}
    var next_id := str(level_database.get_island(island_id).get("next_island_id", ""))
    if next_id.is_empty():
        return {"ok": false, "reason": "NO_NEXT_ISLAND", "island_id": island_id}
    if not is_island_unlocked(next_id):
        return {"ok": false, "reason": "NEXT_ISLAND_LOCKED", "island_id": next_id}
    return {"ok": true, "island_id": next_id, "island": level_database.get_island(next_id)}


func get_next_island(island_id: String) -> Dictionary:
    return resolve_next_island(island_id)


func claim_milestone(island_id: String, milestone_id: Variant) -> Dictionary:
    if level_database == null or not is_island_unlocked(island_id):
        return {"ok": false, "reason": "ISLAND_LOCKED", "changed": false}
    var island: Dictionary = level_database.get_island(island_id)
    var milestones: Array = island.get("reward_track", {}).get("milestones", [])
    if not milestones.has(milestone_id):
        return {"ok": false, "reason": "UNKNOWN_MILESTONE", "changed": false}
    var island_state := _get_island_state(island_id)
    var claimed: Array = island_state["claimed_milestones"].duplicate(true)
    if claimed.has(milestone_id):
        return {"ok": true, "changed": false, "duplicate": true, "milestone_id": milestone_id}
    if not is_level_completed(island_id, int(milestone_id)):
        return {"ok": false, "reason": "MILESTONE_NOT_REACHED", "changed": false}
    claimed.append(milestone_id)
    claimed.sort()
    island_state["claimed_milestones"] = claimed
    _set_island_state(island_id, island_state)
    progression_changed.emit(island_id, int(milestone_id))
    return {"ok": true, "changed": true, "duplicate": false, "milestone_id": milestone_id}


func is_milestone_claimed(island_id: String, milestone_id: Variant) -> bool:
    return _get_island_state(island_id).get("claimed_milestones", []).has(milestone_id)


func get_progression_state() -> Dictionary:
    return _state.duplicate(true)


func _refresh_island_unlocks() -> bool:
    if level_database == null:
        return false
    var unlocked: Array = _state.get("unlocked_islands", []).duplicate(true)
    var changed := false
    for island_id in level_database.get_island_ids():
        if not unlocked.has(island_id) and _unlock_rule_satisfied(level_database.get_island(island_id).get("unlock_rule", {})):
            unlocked.append(island_id)
            changed = true
            if not _state.get("islands", {}).has(island_id):
                _set_island_state(island_id, {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": []})
    unlocked.sort()
    _state["unlocked_islands"] = unlocked
    return changed


func _unlock_rule_satisfied(rule: Variant) -> bool:
    if not rule is Dictionary:
        return false
    var rule_type := str(rule.get("type", ""))
    if rule_type == "default_open":
        return true
    if rule_type != "requires_island_completion":
        return false
    return is_island_complete(str(rule.get("island_id", ""))) and is_level_completed(str(rule.get("island_id", "")), int(rule.get("level_id", 0)))


func _normalized_state(progression_state: Dictionary) -> Dictionary:
    var state := progression_state.duplicate(true)
    if state.is_empty():
        state = {
            "unlocked_islands": ["sunny_cove"],
            "islands": {},
        }
    if not state.has("unlocked_islands") or not state["unlocked_islands"] is Array:
        state["unlocked_islands"] = []
    if not state.has("islands") or not state["islands"] is Dictionary:
        state["islands"] = {}
    if not state.has("coins"):
        state["coins"] = 0
    if not state.has("boosters"):
        state["boosters"] = {}
    if not state.has("legacy_best_score"):
        state["legacy_best_score"] = 0
    for island_id in state["unlocked_islands"]:
        if not state["islands"].has(island_id):
            state["islands"][island_id] = {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": []}
    return state


func _get_island_state(island_id: String) -> Dictionary:
    var islands: Dictionary = _state.get("islands", {})
    var island_state: Dictionary = islands.get(island_id, {}).duplicate(true)
    if not island_state.has("highest_unlocked_level"):
        island_state["highest_unlocked_level"] = 1
    if not island_state.has("completed_levels"):
        island_state["completed_levels"] = {}
    if not island_state.has("claimed_milestones"):
        island_state["claimed_milestones"] = []
    return island_state


func _set_island_state(island_id: String, island_state: Dictionary) -> void:
    var islands: Dictionary = _state.get("islands", {}).duplicate(true)
    islands[island_id] = island_state.duplicate(true)
    _state["islands"] = islands


func _first_unlocked_island() -> String:
    if level_database == null:
        return ""
    for island_id in level_database.get_island_ids():
        if is_island_unlocked(island_id):
            return island_id
    return ""


func _highest_unlocked_level(island_id: String) -> int:
    return maxi(1, int(_state.get("islands", {}).get(island_id, {}).get("highest_unlocked_level", 1)))
