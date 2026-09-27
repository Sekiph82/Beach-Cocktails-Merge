class_name GameplaySessionBridge
extends RefCounted

## The single campaign-to-gameplay session authority.
##
## LevelDatabase owns definitions. This bridge owns one detached immutable
## snapshot plus the mutable runtime ledger for that snapshot. Gameplay may
## report deliveries and score, but it never owns campaign timer, objective,
## terminal, or progression decisions.

signal session_started(configuration: Dictionary)
signal session_terminal(result: Dictionary)
signal timer_started(time_limit_sec: float)
signal timer_updated(remaining_sec: float)
signal session_paused(reason: String)
signal session_resumed
signal island_map_requested(island_id: String)
signal economy_changed(state: Dictionary)
signal vip_state_changed(state: Dictionary)

const STATE_IDLE := "IDLE"
const STATE_READY := "READY"
const STATE_ACTIVE := "ACTIVE"
const STATE_PAUSED := "PAUSED"
const STATE_TERMINAL := "TERMINAL"

const OUTCOME_WIN := "WIN"
const OUTCOME_LOSE := "LOSE"

var level_database
var campaign_manager
var economy
var active_island_id := ""
var active_level_id := 0
var session_state := STATE_IDLE
var timer_remaining_sec := 0.0

var _active_level: Dictionary = {}
var _session_configuration: Dictionary = {}
var _normal_totals_by_level: Dictionary = {}
var _normal_remaining_by_level: Dictionary = {}
var _normal_completed_by_level: Dictionary = {}
var _delivery_ids: Dictionary = {}
var _vip_completed := false
var _background_paused := false
var _pause_reason := ""
var _current_score := 0
var _terminal_result: Dictionary = {}
var _progression_result: Dictionary = {}
var _session_serial := 0
var _progression_submitted := false


func configure(database, manager = null, configured_economy = null) -> bool:
    level_database = database
    campaign_manager = manager
    economy = configured_economy
    clear_session()
    return level_database != null and level_database.is_loaded()


func start_session(island_id: String, level_id: int) -> Dictionary:
    if not _can_start_session():
        return {}
    if level_database == null or not level_database.is_loaded():
        return {}
    if island_id.is_empty() or level_id <= 0:
        return {}
    if campaign_manager != null and not campaign_manager.is_level_unlocked(island_id, level_id):
        return {}

    var level: Dictionary = level_database.get_level(island_id, level_id)
    if level.is_empty():
        return {}

    _session_serial += 1
    active_island_id = island_id
    active_level_id = level_id
    _active_level = _deep_mutable_copy(level)
    _normal_totals_by_level.clear()
    _normal_remaining_by_level.clear()
    _normal_completed_by_level.clear()
    _delivery_ids.clear()
    _terminal_result = {}
    _progression_result = {}
    _progression_submitted = false
    _vip_completed = false
    vip_state_changed.emit(get_vip_state())
    _current_score = 0
    _background_paused = false
    timer_remaining_sec = float(_active_level.get("time_limit_sec", 0.0))
    _configure_objectives(_active_level.get("orders", []))
    _session_configuration = _build_session_configuration()
    session_state = STATE_READY
    session_started.emit(get_session_configuration())
    return get_session_configuration()


func get_session_configuration() -> Dictionary:
    if _session_configuration.is_empty():
        return {}
    return _session_configuration


func mark_gameplay_ready() -> bool:
    if session_state != STATE_READY:
        return false
    session_state = STATE_ACTIVE
    timer_remaining_sec = float(_active_level.get("time_limit_sec", 0.0))
    timer_started.emit(timer_remaining_sec)
    timer_updated.emit(timer_remaining_sec)
    return true


func start_timer() -> bool:
    return mark_gameplay_ready()


func tick(delta_sec: float) -> void:
    if session_state != STATE_ACTIVE or _background_paused:
        return
    if delta_sec <= 0.0:
        return
    timer_remaining_sec = maxf(0.0, timer_remaining_sec - delta_sec)
    timer_updated.emit(timer_remaining_sec)
    if timer_remaining_sec <= 0.0:
        resolve_lose("TIMEOUT")


func pause_session(reason: String = "GAME_PAUSE") -> bool:
    if session_state != STATE_ACTIVE:
        return false
    session_state = STATE_PAUSED
    _pause_reason = reason
    session_paused.emit(reason)
    return true


func resume_session() -> bool:
    if session_state != STATE_PAUSED:
        return false
    session_state = STATE_ACTIVE
    _pause_reason = ""
    session_resumed.emit()
    return true


func set_gameplay_paused(paused: bool) -> bool:
    return pause_session("GAME_PAUSE") if paused else resume_session()


func set_background_paused(paused: bool) -> bool:
    if session_state == STATE_TERMINAL or session_state == STATE_IDLE:
        return false
    _background_paused = paused
    if paused and session_state == STATE_ACTIVE:
        return pause_session("BACKGROUND")
    if not paused and session_state == STATE_PAUSED and _pause_reason == "BACKGROUND":
        return resume_session()
    return true


func is_session_active() -> bool:
    return session_state == STATE_READY or session_state == STATE_ACTIVE or session_state == STATE_PAUSED


func is_terminal() -> bool:
    return session_state == STATE_TERMINAL


func get_next_required_order_level() -> int:
    var levels: Array[int] = []
    for level in _normal_remaining_by_level:
        if int(_normal_remaining_by_level[level]) > 0:
            levels.append(int(level))
    levels.sort()
    return levels[0] if not levels.is_empty() else 0


func get_objective_state() -> Dictionary:
    return {
        "normal_totals": _normal_totals_by_level.duplicate(true),
        "normal_remaining": _normal_remaining_by_level.duplicate(true),
        "normal_completed": _normal_completed_by_level.duplicate(true),
        "vip_enabled": _vip_enabled(),
        "vip_completed": _vip_completed,
    }


func get_vip_state() -> Dictionary:
    var vip: Variant = _active_level.get("vip", null)
    if not _vip_enabled():
        return {"enabled": false, "completed": false, "cocktail_level": 0, "quantity": 0, "status": "HIDDEN"}
    var vip_config: Dictionary = vip
    return {
        "enabled": true,
        "completed": _vip_completed,
        "cocktail_level": int(vip_config.get("cocktail_level", 0)),
        "quantity": int(vip_config.get("quantity", 1)),
        "status": "COMPLETED" if _vip_completed else "PENDING",
    }


func get_economy():
    return economy


func set_current_score(score: int) -> void:
    _current_score = maxi(0, score)


func record_to_go_delivery(cocktail_level: int, quantity: int = 1, delivery_id: String = "", score: int = -1) -> Dictionary:
    if not is_session_active():
        return {"ok": false, "reason": "NO_ACTIVE_SESSION"}
    if session_state == STATE_PAUSED:
        return {"ok": false, "reason": "SESSION_PAUSED"}
    if score >= 0:
        set_current_score(score)
    if not delivery_id.is_empty():
        if _delivery_ids.has(delivery_id):
            return {"ok": true, "duplicate": true, "completed": _normal_completed_by_level.duplicate(true)}
        _delivery_ids[delivery_id] = true
    if quantity <= 0 or not _normal_remaining_by_level.has(cocktail_level):
        return {"ok": true, "accepted": 0, "completed": _normal_completed_by_level.duplicate(true)}

    var accepted := mini(quantity, int(_normal_remaining_by_level[cocktail_level]))
    _normal_remaining_by_level[cocktail_level] = int(_normal_remaining_by_level[cocktail_level]) - accepted
    _normal_completed_by_level[cocktail_level] = int(_normal_completed_by_level.get(cocktail_level, 0)) + accepted
    var response := {
        "ok": true,
        "accepted": accepted,
        "completed": _normal_completed_by_level.duplicate(true),
        "remaining": _normal_remaining_by_level.duplicate(true),
    }
    if _all_normal_orders_complete():
        response["terminal"] = resolve_win(_current_score)
    return response


func record_vip_delivery(cocktail_level: int, quantity: int = 1, score: int = -1) -> Dictionary:
    if score >= 0:
        set_current_score(score)
    if not _vip_enabled():
        return {"ok": false, "reason": "VIP_DISABLED", "vip_completed": false}
    var vip: Dictionary = _active_level.get("vip", {})
    if cocktail_level != int(vip.get("cocktail_level", 0)) or quantity < int(vip.get("quantity", 1)):
        return {"ok": false, "reason": "VIP_REQUIREMENT_NOT_MET", "vip_completed": _vip_completed}
    _vip_completed = true
    vip_state_changed.emit(get_vip_state())
    return {"ok": true, "vip_completed": true}


func set_vip_completed(completed: bool) -> bool:
    if not _vip_enabled():
        return false
    _vip_completed = completed
    vip_state_changed.emit(get_vip_state())
    return true


func apply_time_booster(extension_sec: float, booster_id: String = "time") -> Dictionary:
    if economy == null:
        return {"ok": false, "reason": "ECONOMY_NOT_CONFIGURED", "consumed": false}
    if (session_state != STATE_ACTIVE and session_state != STATE_PAUSED) or timer_remaining_sec <= 0.0:
        return {"ok": false, "reason": "SESSION_NOT_TIMED_ACTIVE", "consumed": false}
    if extension_sec <= 0.0:
        return {"ok": false, "reason": "EXTENSION_MUST_BE_POSITIVE", "consumed": false}
    var consumed: Dictionary = economy.consume_booster(booster_id, 1)
    if not bool(consumed.get("ok", false)):
        return {"ok": false, "reason": str(consumed.get("reason", "BOOSTER_NOT_CONSUMED")), "consumed": false}
    timer_remaining_sec += extension_sec
    timer_updated.emit(timer_remaining_sec)
    economy_changed.emit(economy.export_state())
    return {"ok": true, "consumed": true, "extension_sec": extension_sec, "remaining_time_sec": timer_remaining_sec}


func resolve_win(score: int = -1) -> Dictionary:
    if score >= 0:
        set_current_score(score)
    if not _all_normal_orders_complete():
        return {"ok": false, "reason": "NORMAL_ORDERS_INCOMPLETE"}
    return _resolve_terminal(OUTCOME_WIN, "NORMAL_OBJECTIVES_COMPLETE")


func resolve_lose(reason: String = "GAMEPLAY_LOSE", score: int = -1) -> Dictionary:
    if score >= 0:
        set_current_score(score)
    return _resolve_terminal(OUTCOME_LOSE, reason)


func get_terminal_result() -> Dictionary:
    return _terminal_result.duplicate(true)


func get_progression_result() -> Dictionary:
    return _progression_result.duplicate(true)


func retry_session() -> Dictionary:
    if not is_terminal() or active_island_id.is_empty() or active_level_id <= 0:
        return {}
    var retry_island := active_island_id
    var retry_level := active_level_id
    clear_session()
    return start_session(retry_island, retry_level)


func next_level_session() -> Dictionary:
    if not is_terminal() or _terminal_result.get("outcome", "") != OUTCOME_WIN or campaign_manager == null:
        return {}
    var next: Dictionary = campaign_manager.resolve_next_level(active_island_id, active_level_id)
    if not bool(next.get("ok", false)):
        return {}
    var next_island := str(next.get("island_id", ""))
    var next_level := int(next.get("level_id", 0))
    clear_session()
    return start_session(next_island, next_level)


func return_to_island_map() -> Dictionary:
    if active_island_id.is_empty():
        return {"ok": false, "reason": "NO_ACTIVE_SESSION"}
    var island_id := active_island_id
    clear_session()
    island_map_requested.emit(island_id)
    return {"ok": true, "island_id": island_id}


func submit_result(result: Dictionary) -> Dictionary:
    ## Compatibility entry point retained for the M10 boundary. M14 callers
    ## use resolve_win/resolve_lose so terminal state remains authoritative.
    if _active_level.is_empty():
        return {"ok": false, "reason": "NO_ACTIVE_SESSION"}
    var outcome := str(result.get("outcome", ""))
    if outcome == OUTCOME_WIN:
        return resolve_win(int(result.get("score", _current_score)))
    if outcome == OUTCOME_LOSE:
        return resolve_lose(str(result.get("reason", "GAMEPLAY_LOSE")), int(result.get("score", _current_score)))
    return {"ok": false, "reason": "UNKNOWN_OUTCOME"}


func clear_session() -> void:
    active_island_id = ""
    active_level_id = 0
    session_state = STATE_IDLE
    timer_remaining_sec = 0.0
    _active_level = {}
    _session_configuration = {}
    _normal_totals_by_level.clear()
    _normal_remaining_by_level.clear()
    _normal_completed_by_level.clear()
    _delivery_ids.clear()
    _terminal_result = {}
    _progression_result = {}
    _vip_completed = false
    _background_paused = false
    _pause_reason = ""
    _current_score = 0
    _progression_submitted = false
    vip_state_changed.emit(get_vip_state())


func _can_start_session() -> bool:
    return session_state == STATE_IDLE or session_state == STATE_TERMINAL


func _configure_objectives(orders: Variant) -> void:
    if not orders is Array:
        return
    for order in orders:
        if not order is Dictionary:
            continue
        var level := int(order.get("cocktail_level", 0))
        var quantity := maxi(0, int(order.get("quantity", 0)))
        if level <= 0 or quantity <= 0:
            continue
        _normal_totals_by_level[level] = int(_normal_totals_by_level.get(level, 0)) + quantity
        _normal_remaining_by_level[level] = int(_normal_remaining_by_level.get(level, 0)) + quantity
        _normal_completed_by_level[level] = 0


func _build_session_configuration() -> Dictionary:
    var configuration := {
        "session_serial": _session_serial,
        "island_id": active_island_id,
        "level_id": active_level_id,
        "time_limit_sec": float(_active_level.get("time_limit_sec", 0.0)),
        "orders": _active_level.get("orders", []).duplicate(true),
        "vip": _active_level.get("vip", null),
        "rewards": _active_level.get("rewards", {}).duplicate(true),
        "score_star_thresholds": _active_level.get("score_star_thresholds", {}).duplicate(true),
        "feature_flags": _active_level.get("feature_flags", {}).duplicate(true),
        "level_definition": _active_level.duplicate(true),
        "timer_configured": false,
        "vip_runtime_configured": false,
    }
    return _deep_read_only(configuration)


func _all_normal_orders_complete() -> bool:
    if _normal_totals_by_level.is_empty():
        return false
    for level in _normal_totals_by_level:
        if int(_normal_remaining_by_level.get(level, 0)) > 0:
            return false
    return true


func _vip_enabled() -> bool:
    var vip = _active_level.get("vip", null)
    return vip is Dictionary and bool(vip.get("enabled", true))


func _resolve_terminal(outcome: String, reason: String) -> Dictionary:
    if not _terminal_result.is_empty():
        return _terminal_result.duplicate(true)
    if outcome == OUTCOME_WIN and not _all_normal_orders_complete():
        return {"ok": false, "reason": "NORMAL_ORDERS_INCOMPLETE"}

    session_state = STATE_TERMINAL
    timer_remaining_sec = maxf(0.0, timer_remaining_sec)
    var mutable_result := {
        "session_serial": _session_serial,
        "island_id": active_island_id,
        "level_id": active_level_id,
        "outcome": outcome,
        "reason": reason,
        "score": _current_score,
        "remaining_time_sec": timer_remaining_sec,
        "normal_orders_completed": _normal_completed_by_level.duplicate(true),
        "normal_orders_remaining": _normal_remaining_by_level.duplicate(true),
        "vip_completed": _vip_completed,
        "stars": _derive_stars(),
        "retry_available": true,
        "next_level_available": false,
        "island_map_available": true,
    }
    if outcome == OUTCOME_WIN:
        _submit_progression(mutable_result)
        mutable_result["economy"] = _dispatch_session_rewards()
        mutable_result["next_level_available"] = bool(_progression_result.get("next_level", {}).get("ok", false))
        mutable_result["progression"] = _progression_result.duplicate(true)
    _terminal_result = _deep_read_only(mutable_result)
    session_terminal.emit(get_terminal_result())
    return get_terminal_result()


func _dispatch_session_rewards() -> Dictionary:
    if economy == null:
        return {"ok": true, "configured": false, "grants": []}
    var grants: Array = []
    var level_reward: Variant = _active_level.get("rewards", {})
    if level_reward is Dictionary and not level_reward.is_empty():
        var level_id := "level:%s:%d" % [active_island_id, active_level_id]
        var level_result: Dictionary = economy.grant_reward(level_id, level_reward)
        grants.append(level_result)
        if not bool(level_result.get("ok", false)):
            return {"ok": false, "configured": true, "grants": grants}
    if _vip_completed:
        var vip: Variant = _active_level.get("vip", null)
        var vip_reward: Variant = vip.get("reward", {}) if vip is Dictionary else {}
        if vip_reward is Dictionary and not vip_reward.is_empty():
            var vip_id := "vip:%s:%d" % [active_island_id, active_level_id]
            var vip_result: Dictionary = economy.grant_reward(vip_id, vip_reward)
            grants.append(vip_result)
            if not bool(vip_result.get("ok", false)):
                return {"ok": false, "configured": true, "grants": grants}
    economy_changed.emit(economy.export_state())
    return {"ok": true, "configured": true, "grants": grants}


func _submit_progression(result: Dictionary) -> void:
    if _progression_submitted or campaign_manager == null:
        return
    _progression_submitted = true
    _progression_result = campaign_manager.mark_level_completed(active_island_id, active_level_id, {
        "stars": int(result.get("stars", 1)),
        "score": int(result.get("score", 0)),
        "vip_completed": bool(result.get("vip_completed", false)),
    })


func _derive_stars() -> int:
    var stars := 1
    if _vip_completed:
        stars = 2
    var thresholds: Dictionary = _active_level.get("score_star_thresholds", {})
    var two_stars = thresholds.get("two_stars", null)
    var three_stars = thresholds.get("three_stars", null)
    if two_stars != null and _current_score >= int(two_stars):
        stars = maxi(stars, 2)
    if _vip_completed and three_stars != null and _current_score >= int(three_stars):
        stars = maxi(stars, 3)
    return clampi(stars, 1, 3)


func _deep_read_only(value: Variant):
    if value is Dictionary:
        var frozen_dictionary: Dictionary = {}
        for key in value:
            frozen_dictionary[key] = _deep_read_only(value[key])
        frozen_dictionary.make_read_only()
        return frozen_dictionary
    if value is Array:
        var frozen_array: Array = []
        for item in value:
            frozen_array.append(_deep_read_only(item))
        frozen_array.make_read_only()
        return frozen_array
    return value


func _deep_mutable_copy(value: Variant):
    if value is Dictionary:
        var mutable_dictionary: Dictionary = {}
        for key in value:
            mutable_dictionary[key] = _deep_mutable_copy(value[key])
        return mutable_dictionary
    if value is Array:
        var mutable_array: Array = []
        for item in value:
            mutable_array.append(_deep_mutable_copy(item))
        return mutable_array
    return value
