class_name FeedbackService
extends Node

## Safe, lightweight feedback boundary for M09.
##
## The repository has no owner-approved audio files yet, so audio dispatch is
## intentionally a no-op until a stream is registered. Event accounting still
## exists so gameplay callbacks can be tested without coupling them to a device.

signal feedback_emitted(kind: String)
signal semantic_requested(request: Dictionary)

const HAPTIC_COOLDOWN_MS := 90
const MICRO_CONTACT_COOLDOWN_MS := 120
const MAX_MICRO_CONTACT_KEYS := 256
const MAX_MICRO_TOKENS := 256
const SEMANTIC_KINDS := [
    "cocktail_launch", "table_contact", "merge", "order_progress", "order_complete",
    "vip_delivery", "vip_complete", "score_mastery", "game_success", "game_fail",
    "level_unlock", "island_milestone", "island_complete", "island_unlock",
    "reward_granted", "ui_primary",
]
const MICRO_KINDS := ["cocktail_launch", "table_contact", "ui_primary"]
const MAX_DIAGNOSTICS := 16

var audio_enabled := true
var haptics_enabled := true
var event_counts: Dictionary = {}
var audio_play_count := 0
var haptic_call_count := 0
var semantic_sequence := 0
var semantic_counts: Dictionary = {}
var session_context: Dictionary = {}
var semantic_diagnostics: Array[String] = []

var _audio_streams: Dictionary = {}
var _merge_sources: Dictionary = {}
var _completion_tokens: Dictionary = {}
var _one_shot_events: Dictionary = {}
var _semantic_tokens: Dictionary = {}
var _micro_tokens: Dictionary = {}
var _micro_contact_times: Dictionary = {}
var _haptics_supported_override: Variant = null
var _last_haptic_ms := -HAPTIC_COOLDOWN_MS


func register_audio_stream(kind: String, stream: AudioStream) -> void:
    if kind.is_empty() or stream == null:
        return
    _audio_streams[kind] = stream


func set_haptics_enabled(enabled: bool) -> void:
    haptics_enabled = enabled


func set_haptics_supported_for_testing(supported: bool) -> void:
    _haptics_supported_override = supported


func is_haptics_supported() -> bool:
    if _haptics_supported_override != null:
        return bool(_haptics_supported_override)
    return OS.has_feature("mobile")


func set_session_context(context: Dictionary) -> void:
    session_context = context.duplicate(true)


func request_semantic(
    kind: String,
    payload: Dictionary = {},
    event_id: String = "",
    source_context: Dictionary = {}
) -> bool:
    if not SEMANTIC_KINDS.has(kind):
        _record_semantic_diagnostic("unknown_kind:%s" % kind)
        return false
    var is_micro := MICRO_KINDS.has(kind)
    if not is_micro and event_id.strip_edges().is_empty():
        _record_semantic_diagnostic("missing_event_id:%s" % kind)
        return false
    if not is_micro:
        if _semantic_tokens.has(event_id):
            return false
        _semantic_tokens[event_id] = true
    if kind == "cocktail_launch" and not event_id.is_empty():
        if _micro_tokens.has(event_id):
            return false
        _micro_tokens[event_id] = true
        while _micro_tokens.size() > MAX_MICRO_TOKENS:
            _micro_tokens.erase(_micro_tokens.keys()[0])
    if kind == "table_contact":
        var source_instance := str(payload.get("source_instance", ""))
        var contact_class := str(payload.get("contact_type", ""))
        if source_instance.is_empty() or not ["drink", "rail"].has(contact_class):
            _record_semantic_diagnostic("invalid_contact_identity")
            return false
        var contact_key := "%s:%s" % [source_instance, contact_class]
        var now := Time.get_ticks_msec()
        _prune_micro_contact_times(now)
        var previous := int(_micro_contact_times.get(contact_key, -MICRO_CONTACT_COOLDOWN_MS))
        if now - previous < MICRO_CONTACT_COOLDOWN_MS:
            return false
        _micro_contact_times[contact_key] = now
    semantic_sequence += 1
    semantic_counts[kind] = int(semantic_counts.get(kind, 0)) + 1
    var merged_context := session_context.duplicate(true)
    for key in source_context:
        merged_context[key] = source_context[key].duplicate(true) if source_context[key] is Dictionary or source_context[key] is Array else source_context[key]
    var request := {
        "kind": kind,
        "payload": payload.duplicate(true),
        "event_id": event_id,
        "source_context": merged_context,
        "sequence": semantic_sequence,
    }
    semantic_requested.emit(request.duplicate(true))
    return true


func emit_cocktail_launch(level: int, position: Vector2, velocity: Vector2, source: Node = null) -> bool:
    var payload := {
        "level": level,
        "position": position,
        "velocity": velocity,
    }
    var context := {"source": "shot_controller"}
    var event_id := ""
    if is_instance_valid(source):
        payload["source_instance"] = str(source.get_instance_id())
        payload["presentation_target"] = source.get_node_or_null("Visual")
        event_id = "launch:%s" % str(source.get_instance_id())
    return request_semantic("cocktail_launch", payload, event_id, context)


func emit_table_contact(contact: Dictionary) -> bool:
    return request_semantic("table_contact", contact, "", {"source": "drink_collision"})


func _prune_micro_contact_times(now: int) -> void:
    for key in _micro_contact_times.keys():
        if now - int(_micro_contact_times[key]) >= MICRO_CONTACT_COOLDOWN_MS:
            _micro_contact_times.erase(key)
    if _micro_contact_times.size() > MAX_MICRO_CONTACT_KEYS:
        var oldest_key := ""
        var oldest_time := now
        for key in _micro_contact_times:
            var timestamp := int(_micro_contact_times[key])
            if timestamp < oldest_time:
                oldest_key = str(key)
                oldest_time = timestamp
        if not oldest_key.is_empty():
            _micro_contact_times.erase(oldest_key)


func emit_merge(source: Node, details: Dictionary = {}) -> void:
    if source == null or not is_instance_valid(source):
        return
    var key := str(source.get_instance_id())
    if _merge_sources.has(key):
        return
    _merge_sources[key] = true
    source.tree_exited.connect(_forget_merge_source.bind(key), CONNECT_ONE_SHOT)
    _emit_feedback("merge", 35, 0.35)
    var payload := details.duplicate(true)
    payload["source_instance"] = key
    request_semantic("merge", payload, "merge:%s:%s" % [_session_token(), key], {"source": "game_manager"})


func emit_order_complete(completion_token: Variant, level: int, details: Dictionary = {}) -> void:
    var key := str(completion_token)
    if _completion_tokens.has(key):
        return
    _completion_tokens[key] = true
    _emit_feedback("order_complete", 45, 0.45)
    var payload := details.duplicate(true)
    payload["completion_token"] = completion_token
    payload["level"] = level
    request_semantic("order_complete", payload, "order-complete:%s:%s" % [_session_token(), key], {"source": "gameplay_session_bridge"})


func emit_order_progress(event_token: String, progress: Dictionary) -> bool:
    return request_semantic("order_progress", progress, "order-progress:%s:%s" % [_session_token(), event_token], {"source": "gameplay_session_bridge"})


func emit_vip_delivery(event_token: String, delivery: Dictionary) -> bool:
    return request_semantic("vip_delivery", delivery, "vip-delivery:%s:%s" % [_session_token(), event_token], {"source": "gameplay_session_bridge"})


func emit_vip_complete(event_token: String, state: Dictionary) -> bool:
    return request_semantic("vip_complete", state, "vip-complete:%s:%s" % [_session_token(), event_token], {"source": "gameplay_session_bridge"})


func emit_game_fail(result: Dictionary = {}) -> void:
    if _one_shot_events.has("game_fail"):
        return
    _one_shot_events["game_fail"] = true
    _emit_feedback("game_fail", 65, 0.55)
    request_semantic("game_fail", result, "game-fail:%s" % _session_token(), {"source": "gameplay_session_bridge"})


func emit_game_success(result: Dictionary = {}) -> void:
    if _one_shot_events.has("game_success"):
        return
    _one_shot_events["game_success"] = true
    _emit_feedback("game_success", 65, 0.55)
    request_semantic("game_success", result, "game-success:%s" % _session_token(), {"source": "gameplay_session_bridge"})
    if int(result.get("stars", 0)) >= 3:
        request_semantic("score_mastery", result, "score-mastery:%s" % _session_token(), {"source": "gameplay_session_bridge"})
    var economy: Variant = result.get("economy", {})
    if economy is Dictionary:
        for grant in economy.get("grants", []):
            if not grant is Dictionary or not bool(grant.get("granted", false)):
                continue
            var reward_id := str(grant.get("reward_id", ""))
            if reward_id.is_empty():
                continue
            request_semantic("reward_granted", grant, "reward-granted:%s:%s" % [_session_token(), reward_id], {"source": "gameplay_session_bridge"})


func emit_terminal_result(result: Dictionary) -> void:
    if str(result.get("outcome", "")) == "WIN":
        emit_game_success(result)
    else:
        emit_game_fail(result)


func emit_ui_tap() -> void:
    _emit_feedback("ui_tap", 18, 0.20)


func event_count(kind: String) -> int:
    return int(event_counts.get(kind, 0))


func _forget_merge_source(key: String) -> void:
    _merge_sources.erase(key)


func _session_token() -> String:
    var session_id := str(session_context.get("session_id", ""))
    return session_id if not session_id.is_empty() else "service-%d" % get_instance_id()


func _record_semantic_diagnostic(message: String) -> void:
    if semantic_diagnostics.size() >= MAX_DIAGNOSTICS:
        return
    semantic_diagnostics.append(message)


func _emit_feedback(kind: String, haptic_duration_ms: int, haptic_amplitude: float) -> void:
    event_counts[kind] = event_count(kind) + 1
    feedback_emitted.emit(kind)
    _play_audio_if_available(kind)
    _try_haptic(haptic_duration_ms, haptic_amplitude)


func _play_audio_if_available(kind: String) -> void:
    if not audio_enabled or not _audio_streams.has(kind):
        return
    var stream := _audio_streams[kind] as AudioStream
    if stream == null:
        return
    var player := AudioStreamPlayer.new()
    player.stream = stream
    add_child(player)
    player.finished.connect(player.queue_free, CONNECT_ONE_SHOT)
    player.play()
    audio_play_count += 1


func _try_haptic(duration_ms: int, amplitude: float) -> void:
    if not haptics_enabled or not is_haptics_supported():
        return
    var now := Time.get_ticks_msec()
    if now - _last_haptic_ms < HAPTIC_COOLDOWN_MS:
        return
    _last_haptic_ms = now
    haptic_call_count += 1
    Input.vibrate_handheld(duration_ms, amplitude)
