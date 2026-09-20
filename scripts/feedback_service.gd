class_name FeedbackService
extends Node

## Safe, lightweight feedback boundary for M09.
##
## The repository has no owner-approved audio files yet, so audio dispatch is
## intentionally a no-op until a stream is registered. Event accounting still
## exists so gameplay callbacks can be tested without coupling them to a device.

signal feedback_emitted(kind: String)

const HAPTIC_COOLDOWN_MS := 90

var audio_enabled := true
var haptics_enabled := true
var event_counts: Dictionary = {}
var audio_play_count := 0
var haptic_call_count := 0

var _audio_streams: Dictionary = {}
var _merge_sources: Dictionary = {}
var _completion_tokens: Dictionary = {}
var _one_shot_events: Dictionary = {}
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


func emit_merge(source: Node) -> void:
    if source == null or not is_instance_valid(source):
        return
    var key := str(source.get_instance_id())
    if _merge_sources.has(key):
        return
    _merge_sources[key] = true
    source.tree_exited.connect(_forget_merge_source.bind(key), CONNECT_ONE_SHOT)
    _emit_feedback("merge", 35, 0.35)


func emit_order_complete(completion_token: int, _level: int) -> void:
    var key := str(completion_token)
    if _completion_tokens.has(key):
        return
    _completion_tokens[key] = true
    _emit_feedback("order_complete", 45, 0.45)


func emit_game_fail() -> void:
    if _one_shot_events.has("game_fail"):
        return
    _one_shot_events["game_fail"] = true
    _emit_feedback("game_fail", 65, 0.55)


func emit_game_success() -> void:
    if _one_shot_events.has("game_success"):
        return
    _one_shot_events["game_success"] = true
    _emit_feedback("game_success", 65, 0.55)


func emit_ui_tap() -> void:
    _emit_feedback("ui_tap", 18, 0.20)


func event_count(kind: String) -> int:
    return int(event_counts.get(kind, 0))


func _forget_merge_source(key: String) -> void:
    _merge_sources.erase(key)


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
