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
var economy


func configure(database, progression_state: Dictionary = {}, configured_economy = null) -> bool:
    if database == null or not database.is_loaded():
        return false
    level_database = database
    economy = configured_economy
    _state = _normalized_state(progression_state)
    _refresh_island_unlocks()
    current_island_id = _first_unlocked_island()
    selected_level_id = _highest_unlocked_level(current_island_id)
    return not current_island_id.is_empty()


func set_economy(configured_economy) -> void:
    economy = configured_economy


func select_level(island_id: String, level_id: int) -> bool:
    if not is_level_unlocked(island_id, level_id):
        return false
    current_island_id = island_id
    selected_level_id = level_id
    selection_changed.emit(island_id, level_id)
    return true


func select_island(island_id: String) -> bool:
    if not is_island_unlocked(island_id):
        return false
    current_island_id = island_id
    selected_level_id = _highest_unlocked_level(island_id)
    selection_changed.emit(island_id, selected_level_id)
    return true


func get_island_unlock_feedback(island_id: String) -> Dictionary:
    if level_database == null:
        return {
            "unlocked": false,
            "reason": "Campaign data is not loaded.",
            "progress": "Campaign unavailable",
        }
    var island: Dictionary = level_database.get_island(island_id)
    if island.is_empty():
        return {
            "unlocked": false,
            "reason": "This island is not in the campaign data.",
            "progress": "Unknown island",
        }
    if is_island_unlocked(island_id):
        return {
            "unlocked": true,
            "reason": "Island available",
            "progress": _island_progress_text(island_id),
        }

    var rule: Dictionary = island.get("unlock_rule", {})
    var rule_type := str(rule.get("type", ""))
    if rule_type == "requires_island_completion":
        var required_island_id := str(rule.get("island_id", ""))
        var required_level_id := int(rule.get("level_id", 0))
        var required_island: Dictionary = level_database.get_island(required_island_id)
        var required_name := str(required_island.get("display_name", required_island_id))
        return {
            "unlocked": false,
            "reason": "Complete %s to unlock" % required_name,
            "progress": "%s • Level %d required" % [_island_progress_text(required_island_id), required_level_id],
        }
    return {
        "unlocked": false,
        "reason": "This island is not available yet.",
        "progress": "Progress required",
    }


func get_island_progress(island_id: String) -> Dictionary:
    var island: Dictionary = level_database.get_island(island_id) if level_database != null else {}
    var level_count := int(island.get("level_count", 0))
    var completed_count := 0
    var completed: Dictionary = _get_island_state(island_id).get("completed_levels", {})
    for level_id in completed:
        if bool(completed[level_id].get("completed", false)):
            completed_count += 1
    return {
        "completed": completed_count,
        "total": level_count,
        "island_complete": is_island_complete(island_id),
    }


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


func get_frontier_level_id(island_id: String = "") -> int:
    var resolved_island_id := island_id if not island_id.is_empty() else current_island_id
    if level_database == null or level_database.get_island(resolved_island_id).is_empty():
        return 0
    var level_count := int(level_database.get_island(resolved_island_id).get("level_count", 0))
    if level_count <= 0:
        return 0
    return clampi(_highest_unlocked_level(resolved_island_id), 1, level_count)


func mark_level_completed(island_id: String, level_id: int, result: Dictionary = {}) -> Dictionary:
    if not is_level_unlocked(island_id, level_id):
        return {"ok": false, "reason": "LEVEL_LOCKED", "changed": false}
    var island_state := _get_island_state(island_id)
    var completed: Dictionary = island_state["completed_levels"].duplicate(true)
    var key := str(level_id)
    var old_record: Dictionary = completed.get(key, {})
    var old_highest_level := int(island_state.get("highest_unlocked_level", 1))
    var new_record: Dictionary = old_record.duplicate(true)
    var old_stars := clampi(int(old_record.get("stars", 0)), 0, 3)
    var old_best_score := maxi(0, int(old_record.get("best_score", 0)))
    new_record["stars"] = maxi(old_stars, clampi(int(result.get("stars", 1)), 1, 3))
    new_record["best_score"] = maxi(old_best_score, maxi(0, int(result.get("score", 0))))
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
    var cumulative_rewards := _claim_cumulative_star_rewards(island_id)
    changed = changed or not cumulative_rewards.is_empty()
    var unlock_changed := _refresh_island_unlocks()
    changed = changed or unlock_changed
    if changed:
        progression_changed.emit(island_id, level_id)
    return {
        "ok": true,
        "changed": changed,
        "first_clear": not bool(old_record.get("completed", false)),
        "record": new_record.duplicate(true),
        "island_complete": is_island_complete(island_id),
        "next_level": resolve_next_level(island_id, level_id),
        "next_island": resolve_next_island(island_id),
        "cumulative_stars": get_cumulative_stars(island_id),
        "cumulative_rewards": cumulative_rewards,
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
    var reward_result := {"ok": true, "granted": false, "duplicate": false}
    if economy != null:
        var reward := _milestone_reward(island, milestone_id)
        var reward_id := "milestone:%s:%s" % [island_id, str(milestone_id)]
        reward_result = economy.grant_reward(reward_id, reward)
        if not bool(reward_result.get("ok", false)):
            return {"ok": false, "reason": "MILESTONE_REWARD_REJECTED:%s" % str(reward_result.get("reason", "UNKNOWN")), "changed": false, "reward": reward_result}
    claimed.append(milestone_id)
    claimed.sort()
    island_state["claimed_milestones"] = claimed
    _set_island_state(island_id, island_state)
    progression_changed.emit(island_id, int(milestone_id))
    return {"ok": true, "changed": true, "duplicate": false, "milestone_id": milestone_id, "reward": reward_result}


func is_milestone_claimed(island_id: String, milestone_id: Variant) -> bool:
    return _get_island_state(island_id).get("claimed_milestones", []).has(milestone_id)


func get_progression_state() -> Dictionary:
    return _state.duplicate(true)


func get_cumulative_stars(island_id: String) -> int:
    var completed: Dictionary = _get_island_state(island_id).get("completed_levels", {})
    var total := 0
    for record in completed.values():
        if record is Dictionary and bool(record.get("completed", false)):
            total += clampi(int(record.get("stars", 0)), 0, 3)
    var island: Dictionary = level_database.get_island(island_id) if level_database != null else {}
    var maximum := maxi(0, int(island.get("level_count", 0)) * 3)
    return mini(total, maximum) if maximum > 0 else total


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
                _set_island_state(island_id, {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []})
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
    if not state.has("reward_ledger"):
        state["reward_ledger"] = []
    for island_id in state["unlocked_islands"]:
        if not state["islands"].has(island_id):
            state["islands"][island_id] = {"highest_unlocked_level": 1, "completed_levels": {}, "claimed_milestones": [], "claimed_star_rewards": []}
        elif not state["islands"][island_id].has("claimed_star_rewards"):
            state["islands"][island_id]["claimed_star_rewards"] = []
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
    if not island_state.has("claimed_star_rewards"):
        island_state["claimed_star_rewards"] = []
    return island_state


func _set_island_state(island_id: String, island_state: Dictionary) -> void:
    var islands: Dictionary = _state.get("islands", {}).duplicate(true)
    islands[island_id] = island_state.duplicate(true)
    _state["islands"] = islands


func _milestone_reward(island: Dictionary, milestone_id: Variant) -> Dictionary:
    var reward_track: Dictionary = island.get("reward_track", {})
    var rewards: Variant = reward_track.get("rewards", reward_track.get("milestone_rewards", {}))
    if rewards is Dictionary:
        var reward: Variant = rewards.get(str(milestone_id), rewards.get(milestone_id, null))
        if reward is Dictionary:
            return reward.duplicate(true)
    # A configured milestone with no economy payload is still claimable and is
    # recorded idempotently. Zero coins gives the ledger a deterministic mark.
    return {"coins": 0}


func _claim_cumulative_star_rewards(island_id: String) -> Array:
    if level_database == null:
        return []
    var island: Dictionary = level_database.get_island(island_id)
    var reward_track: Dictionary = island.get("reward_track", {})
    var configured: Variant = reward_track.get("cumulative_star_rewards", [])
    if not configured is Array:
        return []
    var cumulative_stars := get_cumulative_stars(island_id)
    var island_state := _get_island_state(island_id)
    var claimed: Array = island_state.get("claimed_star_rewards", []).duplicate(true)
    var newly_claimed: Array = []
    var changed := false
    for entry in configured:
        if not entry is Dictionary:
            continue
        var threshold := int(entry.get("threshold", 0))
        var reward: Variant = entry.get("reward", {})
        if threshold <= 0 or threshold > cumulative_stars or not reward is Dictionary:
            continue
        # Former +Time slots are intentionally unconfigured. Leave them
        # unclaimed and readable until the owner defines a replacement reward.
        if reward.is_empty():
            continue
        if claimed.has(threshold):
            continue
        # Progression may complete before the economy service is attached, but
        # a cumulative threshold is only claimed after a real grant attempt
        # succeeds. This preserves the threshold for later reconciliation.
        var grant := {"ok": false, "granted": false, "duplicate": false, "reason": "ECONOMY_UNAVAILABLE"}
        if economy != null:
            var reward_id := "cumulative-stars:%s:%d" % [island_id, threshold]
            grant = economy.grant_reward(reward_id, reward)
        if not bool(grant.get("ok", false)):
            continue
        claimed.append(threshold)
        newly_claimed.append({"threshold": threshold, "reward": reward.duplicate(true), "grant": grant.duplicate(true)})
        changed = true
    if changed:
        claimed.sort()
        island_state["claimed_star_rewards"] = claimed
        _set_island_state(island_id, island_state)
    return newly_claimed


func _first_unlocked_island() -> String:
    if level_database == null:
        return ""
    for island_id in level_database.get_island_ids():
        if is_island_unlocked(island_id):
            return island_id
    return ""


func _highest_unlocked_level(island_id: String) -> int:
    return maxi(1, int(_state.get("islands", {}).get(island_id, {}).get("highest_unlocked_level", 1)))


func _island_progress_text(island_id: String) -> String:
    var progress := get_island_progress(island_id)
    var total := int(progress["total"])
    if total <= 0:
        return "Campaign island"
    return "%d / %d levels complete" % [int(progress["completed"]), total]
