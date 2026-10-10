class_name PresentationFeedbackBridge
extends Node

## Sole plugin-call boundary. M22 keeps normal production dispatch disabled;
## only isolated fixture requests can execute the plugin calls below.

const CONTRACT_SCRIPT := preload("res://scripts/presentation_plugin_contract.gd")
const POLICY_SCRIPT := preload("res://scripts/presentation_effect_policy.gd")
const MAX_DIAGNOSTICS := 16
const MAX_ACTIVE_GFF_OUTPUTS := 128
const MAX_VISUAL_TRACE_EVENTS := 128
const MAX_RENDER_SAMPLES_PER_EVENT := 32
const FIXTURE_TARGET_GROUP := "m22_test_presentation_target"
const FULL_CONTACT_TINT := Color(1.0, 0.86, 0.68, 1.0)
const FULL_SCORE_TINT := Color(1.0, 0.84, 0.62, 1.0)
const REDUCED_TINT := Color(1.0, 0.98, 0.92, 1.0)
const SPARK_COLOR := Color(0.46, 0.78, 0.86, 0.95)
const SPARK_COLOR_END := Color(0.84, 0.78, 0.66, 0.0)

var _contract: PresentationPluginContract
var _policy
var _feedback_service: Node
var _production_dispatch_enabled := false
var _presentation_mode := "FULL"
var _diagnostics: Array[String] = []
var _active_gff_outputs: Array[Dictionary] = []
var _active_spark_outputs: Array[Dictionary] = []
var _active_color_outputs: Dictionary = {}
var _color_generations: Dictionary = {}
var _color_lifecycle_diagnostics: Array[Dictionary] = []
var _visual_trace: Array[Dictionary] = []
var _trace_sequence := 0
var _visual_diagnostics_enabled := false
var _last_process_delta_ms := 0.0
var _max_process_delta_ms := 0.0
var _process_delta_sample_count := 0
var _dropped_frame_estimate_count := 0
var _result_presentation_tokens: Dictionary = {}
var _pending_large_requests: Array[Dictionary] = []
var _dispatching_queued_large := false
var dispatch_count := 0
var no_op_count := 0


func configure(feedback_service: Node, capability_root: Node) -> void:
	cancel_presentation()
	_disconnect_feedback_service()
	_feedback_service = feedback_service if is_instance_valid(feedback_service) else null
	_contract = CONTRACT_SCRIPT.new()
	_policy = POLICY_SCRIPT.new()
	_contract.refresh_from_tree(capability_root)
	if is_instance_valid(_feedback_service) and _feedback_service.has_signal("semantic_requested"):
		var callback := Callable(self, "_on_semantic_requested")
		if not _feedback_service.semantic_requested.is_connected(callback):
			_feedback_service.semantic_requested.connect(callback)


func refresh_capabilities(capability_root: Node) -> Dictionary:
	cancel_presentation()
	if _contract == null:
		_contract = CONTRACT_SCRIPT.new()
	return _contract.refresh_from_tree(capability_root)


func get_listener_count() -> int:
	if not is_instance_valid(_feedback_service) or not _feedback_service.has_signal("semantic_requested"):
		return 0
	return _feedback_service.semantic_requested.get_connections().size()


func get_diagnostics() -> Array[String]:
	return _diagnostics.duplicate(true)


func get_visual_diagnostic_trace() -> Array[Dictionary]:
	return _visual_trace.duplicate(true)


func get_color_lifecycle_diagnostics() -> Array[Dictionary]:
	return _color_lifecycle_diagnostics.duplicate(true)


func set_visual_diagnostics_enabled(enabled: bool) -> void:
	_visual_diagnostics_enabled = enabled
	if not enabled:
		_visual_trace.clear()


func get_frame_diagnostics() -> Dictionary:
	return {
		"fps": Engine.get_frames_per_second(),
		"engine_max_fps": Engine.max_fps,
		"frames_drawn": Engine.get_frames_drawn(),
		"process_delta_ms_last": _last_process_delta_ms,
		"process_delta_ms_max": _max_process_delta_ms,
		"process_delta_samples": _process_delta_sample_count,
		"dropped_frame_estimate_count": _dropped_frame_estimate_count,
	}


func _process(delta: float) -> void:
	_flush_serialized_large_request()
	if not _visual_diagnostics_enabled:
		return
	_last_process_delta_ms = delta * 1000.0
	_max_process_delta_ms = maxf(_max_process_delta_ms, _last_process_delta_ms)
	_process_delta_sample_count += 1
	var fps := Engine.get_frames_per_second()
	if fps > 0.0 and _last_process_delta_ms > (2000.0 / fps):
		_dropped_frame_estimate_count += 1
	_sample_pending_visual_traces(_last_process_delta_ms)


func set_production_dispatch_enabled(enabled: bool) -> void:
	_production_dispatch_enabled = enabled
	if not enabled:
		cancel_presentation()


func set_presentation_mode(mode: String) -> bool:
	if not ["FULL", "REDUCED"].has(mode):
		return false
	if mode != _presentation_mode:
		cancel_presentation()
	_presentation_mode = mode
	return true


func cancel_presentation() -> void:
	_pending_large_requests.clear()
	for output in _active_gff_outputs:
		var plugin: Variant = output.get("plugin")
		var target: Variant = output.get("target")
		if is_instance_valid(plugin) and plugin.has_method("stop") and is_instance_valid(target):
			plugin.call("stop", target)
	_active_gff_outputs.clear()
	for target_id_value in _active_color_outputs.keys():
		var target_id := int(target_id_value)
		var generation := int(_active_color_outputs[target_id_value].get("generation", -1))
		_finish_color_output(target_id, generation, "bridge_cancel")
	for output in _active_spark_outputs:
		var plugin: Variant = output.get("plugin")
		if is_instance_valid(plugin) and plugin.has_method("clear"):
			plugin.call("clear")
	_active_spark_outputs.clear()


func dispatch_fixture_request(
	request: Dictionary,
	target: Node,
	plan: Dictionary,
	gff_fixture: Node,
	spark_fixture: Node
) -> bool:
	if not is_instance_valid(target) or not target.is_in_group(FIXTURE_TARGET_GROUP):
		return _no_op("fixture_target_not_allowlisted")
	if _contract == null:
		_contract = CONTRACT_SCRIPT.new()
	if _policy == null:
		_policy = POLICY_SCRIPT.new()
	_contract.refresh_with_nodes(gff_fixture, spark_fixture)
	return _dispatch_plan(request.duplicate(true), target, plan.duplicate(true), true)


func _exit_tree() -> void:
	cancel_presentation()
	_disconnect_feedback_service()
	if _contract != null:
		_contract.refresh_with_nodes(null, null)


func _disconnect_feedback_service() -> void:
	if is_instance_valid(_feedback_service) and _feedback_service.has_signal("semantic_requested"):
		var callback := Callable(self, "_on_semantic_requested")
		if _feedback_service.semantic_requested.is_connected(callback):
			_feedback_service.semantic_requested.disconnect(callback)
	_feedback_service = null


func _on_semantic_requested(request: Dictionary) -> void:
	var kind := str(request.get("kind", ""))
	if not ["cocktail_launch", "table_contact", "merge", "score_mastery", "order_progress", "order_complete", "vip_delivery", "vip_complete", "game_success", "game_fail", "level_unlock", "island_milestone", "island_complete", "island_unlock", "reward_granted", "ui_primary"].has(kind):
		return
	var payload: Dictionary = request.get("payload", {})
	if kind == "vip_delivery" and int(payload.get("accepted", 0)) <= 0:
		return
	if kind == "vip_complete" and not bool(payload.get("completed_transition", false)):
		return
	if kind in ["island_complete", "island_unlock", "reward_granted"] and not bool(payload.get("newly_granted", payload.get("new_transition", false))):
		return
	if kind == "ui_primary" and not ["PLAY", "NEXT", "RETRY"].has(str(payload.get("action", ""))):
		return
	if not _production_dispatch_enabled:
		var disabled_trace_id := _begin_visual_trace(request)
		_update_visual_trace(disabled_trace_id, {"stage": "blocked", "dispatch_gate": "production_dispatch_disabled"})
		return
	var target_value: Variant = payload.get("presentation_target", null)
	if not is_instance_valid(target_value) or not target_value is Node:
		var missing_target_trace_id := _begin_visual_trace(request)
		_update_visual_trace(missing_target_trace_id, {"stage": "blocked", "dispatch_gate": "production_target_missing"})
		_no_op("production_target_missing")
		return
	if _policy != null and _policy.is_large_celebration(kind) and not _dispatching_queued_large:
		_prune_expired_spark_outputs()
		if _active_spark_particle_count() > 0:
			_pending_large_requests.append(request.duplicate(false))
			return
	var trace_id := _begin_visual_trace(request)
	var mode := _presentation_mode
	var plan := _micro_plan(kind, mode)
	if kind == "game_success" or kind == "game_fail":
		var token := str(request.get("event_id", ""))
		if token.is_empty() or _result_presentation_tokens.has(token):
			return
		_result_presentation_tokens[token] = true
		plan = _result_presentation_plan(kind, mode, payload)
	elif kind == "merge":
		plan = _merge_plan(mode, payload)
	elif kind == "score_mastery":
		plan = _score_milestone_plan(mode)
	elif kind == "order_progress":
		plan = _order_progress_plan(mode)
	elif kind == "order_complete":
		plan = _order_complete_plan(mode)
	elif kind == "vip_delivery":
		plan = _vip_delivery_plan(mode, payload)
	elif kind == "vip_complete":
		plan = _vip_complete_plan(mode)
	elif kind == "level_unlock":
		plan = _level_unlock_plan(mode)
	elif kind == "island_milestone":
		plan = _island_milestone_plan(mode)
	elif kind == "island_complete":
		plan = _island_complete_plan(mode)
	elif kind == "island_unlock":
		plan = _island_unlock_plan(mode)
	elif kind == "reward_granted":
		plan = _reward_granted_plan(mode)
	elif kind == "ui_primary":
		plan = _ui_primary_plan(mode)
	_update_visual_trace(trace_id, {
		"target": _canvas_item_snapshot(target_value as Node),
		"plan": plan.duplicate(true),
		"dispatch_gate": "enabled",
	})
	_dispatch_plan(request, target_value as Node, plan, false, trace_id)


func _result_presentation_plan(kind: String, mode: String, payload: Dictionary) -> Dictionary:
	var reduced := mode == "REDUCED"
	var is_win := kind == "game_success"
	var plan := {
		"mode": mode,
		"gff_effect": "color",
		"gff_params": {"duration": 0.10 if reduced else 0.24, "color": REDUCED_TINT if reduced else Color(1.0, 0.86, 0.58, 1.0)} if is_win else {"duration": 0.08 if reduced else 0.18, "color": REDUCED_TINT if reduced else Color(0.94, 0.88, 0.72, 1.0)},
	}
	if not is_win or reduced:
		return plan
	var progression: Dictionary = payload.get("progression", {}) if payload.get("progression", {}) is Dictionary else {}
	var economy: Dictionary = payload.get("economy", {}) if payload.get("economy", {}) is Dictionary else {}
	var grants: Array = economy.get("grants", []) if economy.get("grants", []) is Array else []
	var has_new_reward := false
	for grant in grants:
		if grant is Dictionary and bool(grant.get("granted", false)) and not str(grant.get("reward_id", "")).is_empty():
			has_new_reward = true
			break
	var tier := "WIN"
	if int(payload.get("stars", 0)) >= 3:
		tier = "MASTERY"
	if bool(progression.get("first_clear", false)):
		tier = "FIRST_CLEAR"
	if has_new_reward or (progression.get("cumulative_rewards", []) is Array and not progression.get("cumulative_rewards", []).is_empty()):
		tier = "REWARD"
	var amount := 30
	if tier == "MASTERY":
		amount = 48
	elif tier == "FIRST_CLEAR":
		amount = 36
	elif tier == "REWARD":
		amount = 40
	amount = mini(amount, maxi(0, 48 - _active_spark_particle_count()))
	plan["tier"] = tier
	if amount > 0:
		plan["spark_preset"] = "confetti"
		plan["spark_overrides"] = {
			"amount": amount,
			"lifetime": 0.90,
			"speed": 105.0,
			"size": 3.25,
			"size_end": 0.8,
			"gravity": 460.0,
			"color": Color(1.0, 0.78, 0.30, 0.96),
			"color2": Color(0.95, 0.48, 0.31, 0.0),
		}
	return plan


func _micro_plan(kind: String, mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	var amount := 0
	var lifetime := 0.0
	var speed := 0.0
	var preset := ""
	var effect := "color"
	var gff_params := {"duration": 0.10 if reduced else 0.16, "color": REDUCED_TINT if reduced else FULL_CONTACT_TINT}
	if not reduced:
		if kind == "cocktail_launch":
			amount = 4
			lifetime = 0.14
			speed = 45.0
			preset = "hit"
			effect = "punch_scale"
			gff_params = {"duration": 0.14, "intensity": 0.48}
		else:
			amount = 5
			lifetime = 0.16
			speed = 40.0
			preset = "hit"
	var overrides := {"amount": amount, "lifetime": lifetime, "speed": speed}
	if preset == "hit":
		overrides.merge({"size": 4.0 if kind == "cocktail_launch" else 4.25, "size_end": 0.8, "color": SPARK_COLOR, "color2": SPARK_COLOR_END}, true)
	var result := {"mode": mode, "gff_effect": effect, "gff_params": gff_params}
	if not preset.is_empty():
		result["spark_preset"] = preset
		result["spark_overrides"] = overrides
	return result


func _merge_plan(mode: String, payload: Dictionary) -> Dictionary:
	var chain := maxi(1, int(payload.get("chain", 1)))
	var reduced := mode == "REDUCED"
	var amount := 0
	var lifetime := 0.0
	var speed := 0.0
	var duration := 0.10
	var intensity := 1.0
	var particle_size := 0.0
	if not reduced:
		if chain >= 5:
			amount = 18
			lifetime = 0.35
			speed = 105.0
			duration = 0.28
			intensity = 0.68
			particle_size = 5.0
		elif chain >= 3:
			amount = 10
			lifetime = 0.30
			speed = 70.0
			duration = 0.23
			intensity = 0.48
			particle_size = 4.5
		else:
			amount = 10
			lifetime = 0.28
			speed = 55.0
			duration = 0.18
			intensity = 0.30
			particle_size = 4.0
	var result := {
		"mode": mode,
		"gff_effect": "color" if reduced else "punch_scale",
		"gff_params": {"duration": duration, "color": REDUCED_TINT} if reduced else {"duration": duration, "intensity": intensity},
	}
	if amount > 0:
		result["spark_preset"] = "hit"
		result["spark_overrides"] = {
			"amount": amount,
			"lifetime": lifetime,
			"speed": speed,
			"size": particle_size,
			"size_end": 1.5,
			"color": SPARK_COLOR,
			"color2": SPARK_COLOR_END,
		}
	return result


func _score_milestone_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	return {
		"mode": mode,
		"gff_effect": "color",
		"gff_params": {"duration": 0.10, "color": REDUCED_TINT} if reduced else {"duration": 0.20, "color": FULL_SCORE_TINT},
	}


func _order_progress_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	var result := {
		"mode": mode,
		"gff_effect": "color",
		"gff_params": {"duration": 0.10 if reduced else 0.18, "color": REDUCED_TINT if reduced else Color(1.0, 0.91, 0.64, 1.0)},
	}
	if not reduced:
		result["spark_preset"] = "pickup"
		result["spark_overrides"] = {
			"amount": 8,
			"lifetime": 0.25,
			"speed": 65.0,
			"size": 4.0,
			"size_end": 1.0,
			"color": SPARK_COLOR,
			"color2": SPARK_COLOR_END,
		}
	return result


func _order_complete_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	var result := {
		"mode": mode,
		"gff_effect": "color" if reduced else "punch_scale",
		"gff_params": {"duration": 0.12, "color": REDUCED_TINT} if reduced else {"duration": 0.24, "intensity": 0.32},
	}
	if not reduced:
		result["spark_preset"] = "pickup"
		result["spark_overrides"] = {
			"amount": 12,
			"lifetime": 0.36,
			"speed": 82.0,
			"size": 4.5,
			"size_end": 1.0,
			"color": Color(1.0, 0.80, 0.38, 0.96),
			"color2": SPARK_COLOR_END,
		}
	return result


func _vip_delivery_plan(mode: String, payload: Dictionary) -> Dictionary:
	var reduced := mode == "REDUCED"
	var result := {
		"mode": mode,
		"gff_effect": "color",
		"gff_params": {"duration": 0.10 if reduced else 0.20, "color": REDUCED_TINT if reduced else Color(0.68, 0.90, 1.0, 1.0)},
	}
	# When this accepted delivery also completes VIP, the completion event owns
	# the single premium burst; the delivery cue remains a brief local tint.
	if not reduced and not bool(payload.get("completed_transition", false)):
		result["spark_preset"] = "pickup"
		result["spark_overrides"] = {
			"amount": 10,
			"lifetime": 0.30,
			"speed": 76.0,
			"size": 4.0,
			"size_end": 1.0,
			"color": Color(0.44, 0.82, 0.96, 0.96),
			"color2": Color(0.96, 0.82, 0.48, 0.0),
		}
	return result


func _vip_complete_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	var result := {
		"mode": mode,
		"gff_effect": "color" if reduced else "punch_scale",
		"gff_params": {"duration": 0.12, "color": REDUCED_TINT} if reduced else {"duration": 0.38, "intensity": 0.42},
	}
	if not reduced:
		result["spark_preset"] = "pickup"
		result["spark_overrides"] = {
			"amount": 20,
			"lifetime": 0.55,
			"speed": 90.0,
			"size": 4.75,
			"size_end": 1.0,
			"color": Color(0.44, 0.82, 0.96, 0.96),
			"color2": Color(0.96, 0.82, 0.48, 0.0),
		}
	return result


func _level_unlock_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	var result := {
		"mode": mode,
		"gff_effect": "color",
		"gff_params": {"duration": 0.10, "color": REDUCED_TINT} if reduced else {"duration": 0.24, "color": Color(0.62, 0.92, 0.76, 1.0)},
	}
	if not reduced:
		result["spark_preset"] = "pickup"
		result["spark_overrides"] = {"amount": 10, "lifetime": 0.35, "speed": 70.0, "size": 4.0, "size_end": 1.0, "color": Color(0.50, 0.88, 0.66, 0.96), "color2": SPARK_COLOR_END}
	return result


func _island_milestone_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	var result := {
		"mode": mode,
		"gff_effect": "color",
		"gff_params": {"duration": 0.10, "color": REDUCED_TINT} if reduced else {"duration": 0.30, "color": Color(1.0, 0.82, 0.42, 1.0)},
	}
	result["spark_preset"] = "dust" if reduced else "pickup"
	result["spark_overrides"] = {
		"amount": 4 if reduced else 18,
		"lifetime": 0.20 if reduced else 0.55,
		"speed": 35.0 if reduced else 90.0,
		"size": 4.0,
		"size_end": 0.8,
		"color": Color(0.78, 0.92, 0.72, 0.9) if reduced else Color(1.0, 0.78, 0.32, 0.96),
		"color2": SPARK_COLOR_END,
	}
	return result


func _island_complete_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	return {
		"mode": mode,
		"gff_effect": "color",
		"gff_params": {"duration": 0.10, "color": REDUCED_TINT} if reduced else {"duration": 0.32, "color": Color(1.0, 0.82, 0.42, 1.0)},
		"spark_preset": "dust" if reduced else "pickup",
		"spark_overrides": {
			"amount": 10 if reduced else 40,
			"lifetime": 0.44 if reduced else 1.10,
			"speed": 38.0 if reduced else 105.0,
			"size": 4.5,
			"size_end": 1.0,
			"color": Color(0.80, 0.91, 0.76, 0.9) if reduced else Color(1.0, 0.78, 0.32, 0.96),
			"color2": SPARK_COLOR_END,
		},
	}


func _island_unlock_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	return {
		"mode": mode,
		"gff_effect": "color",
		"gff_params": {"duration": 0.10, "color": REDUCED_TINT} if reduced else {"duration": 0.34, "color": Color(0.62, 0.92, 0.76, 1.0)},
		"spark_preset": "dust" if reduced else "pickup",
		"spark_overrides": {
			"amount": 10 if reduced else 48,
			"lifetime": 0.48 if reduced else 1.60,
			"speed": 35.0 if reduced else 120.0,
			"size": 4.0,
			"size_end": 0.9,
			"color": Color(0.78, 0.92, 0.78, 0.9) if reduced else Color(0.50, 0.88, 0.66, 0.96),
			"color2": SPARK_COLOR_END,
		},
	}


func _reward_granted_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	var result := {
		"mode": mode,
		"gff_effect": "color",
		"gff_params": {"duration": 0.10, "color": REDUCED_TINT} if reduced else {"duration": 0.24, "color": Color(1.0, 0.88, 0.58, 1.0)},
	}
	if not reduced:
		result["spark_preset"] = "pickup"
		result["spark_overrides"] = {"amount": 5, "lifetime": 0.30, "speed": 35.0, "size": 3.5, "size_end": 0.9, "color": Color(1.0, 0.80, 0.38, 0.95), "color2": SPARK_COLOR_END}
	return result


func _ui_primary_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	return {
		"mode": mode,
		"gff_effect": "color",
		"gff_params": {"duration": 0.08, "color": REDUCED_TINT} if reduced else {"duration": 0.10, "color": Color(1.0, 0.91, 0.68, 1.0)},
	}


func _flush_serialized_large_request() -> void:
	_prune_expired_spark_outputs()
	if _pending_large_requests.is_empty() or _active_spark_particle_count() > 0:
		return
	var request: Dictionary = _pending_large_requests.pop_front()
	_dispatching_queued_large = true
	_on_semantic_requested(request)
	_dispatching_queued_large = false


func _dispatch_plan(request: Dictionary, target: Node, plan: Dictionary, fixture: bool, trace_id: String = "") -> bool:
	_update_visual_trace(trace_id, {"stage": "dispatch_validating"})
	if not _valid_request(request):
		_update_visual_trace(trace_id, {"stage": "blocked", "dispatch_gate": "unknown_semantic_kind"})
		return _no_op("unknown_semantic_kind")
	if not _is_presentation_target(target, fixture):
		_update_visual_trace(trace_id, {"stage": "blocked", "dispatch_gate": "target_not_allowlisted"})
		return _no_op("target_not_allowlisted")
	if _policy == null:
		_policy = POLICY_SCRIPT.new()
	var mode := str(plan.get("mode", "FULL"))
	_prune_expired_gff_outputs()
	_prune_expired_spark_outputs()
	var validation_plan := plan.duplicate(true)
	validation_plan["active_live_particles"] = _active_spark_particle_count()
	var policy_result: Dictionary = _policy.validate_dispatch(request, mode, validation_plan)
	_update_visual_trace(trace_id, {
		"policy": policy_result.duplicate(true),
		"active_particles_before": _active_spark_particle_count(),
		"capabilities": _contract.snapshot() if _contract != null else {},
	})
	if not bool(policy_result.get("ok", false)):
		_update_visual_trace(trace_id, {"stage": "blocked", "dispatch_gate": "policy_rejected"})
		return _no_op("policy:%s" % str(policy_result.get("reason", "invalid")))
	var effect_name := str(plan.get("gff_effect", ""))
	var gff_params_value: Variant = plan.get("gff_params", {})
	var spark_preset := str(plan.get("spark_preset", ""))
	var has_effect := not effect_name.is_empty()
	var has_spark := not spark_preset.is_empty()
	if not has_effect and not has_spark:
		return _no_op("unknown_mapping")
	if has_effect and (_contract == null or not _contract.has_game_feel_flow_effect(effect_name)):
		if effect_name == "color":
			_cancel_color_for_target(target, "plugin_effect_unavailable")
		return _no_op("gff_effect_unavailable:%s" % effect_name)
	var spark_options: Dictionary = {}
	if has_spark:
		if _contract == null or not _contract.has_spark_preset(spark_preset):
			return _no_op("spark_preset_unavailable:%s" % spark_preset)
		spark_options = _build_spark_options(spark_preset, plan.get("spark_overrides", {}), str(request.kind), mode, int(request.get("payload", {}).get("chain", 1)))
		if spark_options.is_empty():
			_update_visual_trace(trace_id, {"stage": "blocked", "dispatch_gate": "spark_overrides_invalid"})
			return _no_op("spark_overrides_invalid")
	# Preflight all requested components before invoking either plugin.
	if has_effect:
		if _active_gff_outputs.size() >= MAX_ACTIVE_GFF_OUTPUTS:
			return _no_op("gff_output_capacity")
		var gff_started_ms := Time.get_ticks_msec()
		var result: Variant
		var color_output: Dictionary = {}
		if effect_name == "color":
			color_output = _start_color_output(target, gff_params_value, str(request.get("event_id", "")), str(request.get("kind", "")), trace_id)
			if color_output.is_empty():
				_update_visual_trace(trace_id, {"stage": "blocked", "dispatch_gate": "gff_color_call_failed"})
				return _no_op("gff_color_call_failed")
			result = color_output.get("play_result")
		else:
			var gff_args: Array = [effect_name, target]
			if effect_name == "alpha":
				var alpha_template: Variant = _contract.game_feel_flow.call("get_effect", "alpha")
				if alpha_template is GFFEffect:
					var alpha_effect := (alpha_template as GFFEffect).duplicate(true) as GFFEffect
					alpha_effect.restore_after_play = false
					alpha_effect.duration = float(gff_params_value.get("duration", 0.24)) if gff_params_value is Dictionary else 0.24
					var alpha_target: Variant = alpha_effect.get("target")
					if alpha_target != null and alpha_target.has_method("set"):
						alpha_target.set("target_alpha", float(gff_params_value.get("target_alpha", 1.0)))
					gff_args = [alpha_effect, target]
			else:
				if gff_params_value is Dictionary and not gff_params_value.is_empty():
					gff_args.append(gff_params_value.duplicate(true))
			result = _contract.game_feel_flow.callv("play", gff_args)
			if result is bool and not result:
				_update_visual_trace(trace_id, {"stage": "blocked", "dispatch_gate": "gff_call_failed"})
				return _no_op("gff_call_failed")
		var effect_duration := float(gff_params_value.get("duration", 0.30)) if gff_params_value is Dictionary else 0.30
		var active_output := {
			"plugin": _contract.game_feel_flow,
			"target": target,
			"expires_at_ms": Time.get_ticks_msec() + int(ceil(maxf(effect_duration, 0.25) * 1000.0)),
		}
		if not color_output.is_empty():
			active_output["effect"] = color_output.get("effect")
		_active_gff_outputs.append(active_output)
		_update_visual_trace(trace_id, {
			"gff_call": {"invoked": true, "effect": effect_name, "params": gff_params_value.duplicate(true) if gff_params_value is Dictionary else {}, "returned": str(result), "started_ms": gff_started_ms},
			"gff_active_effect_count": _gff_active_effect_count(),
			"color_lifecycle": color_output.get("trace", {}) if not color_output.is_empty() else {},
		})
	if has_spark:
		var position := _target_global_position(target)
		var pool := get_node_or_null("/root/Spark/SaltmireSparkPool")
		var emitter_ids_before: Dictionary = {}
		if is_instance_valid(pool):
			for emitter in pool.get_children():
				emitter_ids_before[emitter.get_instance_id()] = true
		var result: Variant = _contract.spark.callv("burst", [position, spark_options])
		if result is bool and not result:
			_update_visual_trace(trace_id, {"stage": "blocked", "dispatch_gate": "spark_call_failed"})
			cancel_presentation()
			return _no_op("spark_call_failed")
		var emitter_id := _find_new_spark_emitter_id(pool, emitter_ids_before)
		_active_spark_outputs.append({
			"plugin": _contract.spark,
			"amount": int(spark_options.get("amount", 0)),
			"expires_at_ms": Time.get_ticks_msec() + int(ceil(float(spark_options.get("lifetime", 0.0)) * (1.0 + maxf(float(spark_options.get("lifetime_rand", 0.0)), 0.0)) * 1000.0)),
		})
		_update_visual_trace(trace_id, {
			"spark_call": {"invoked": true, "requested_canvas_position": position, "options": spark_options.duplicate(true), "emitter_instance_id": emitter_id, "pool_children_after": pool.get_child_count() if is_instance_valid(pool) else -1},
		})
	dispatch_count += 1
	_update_visual_trace(trace_id, {
		"stage": "awaiting_render",
		"dispatch_completed_ms": Time.get_ticks_msec(),
		"frames_drawn_at_dispatch": Engine.get_frames_drawn(),
	})
	return true


func _start_color_output(target: Node, params_value: Variant, event_id: String, kind: String, trace_id: String) -> Dictionary:
	if not is_instance_valid(target) or not target is CanvasItem or _contract == null or not _contract.has_game_feel_flow():
		_cancel_color_for_target(target, "plugin_or_target_unavailable")
		return {}
	var target_id := target.get_instance_id()
	var original_modulate: Color = (target as CanvasItem).modulate
	var previous: Dictionary = _active_color_outputs.get(target_id, {})
	if not previous.is_empty():
		original_modulate = previous.get("original_modulate", original_modulate)
		_finish_color_output(target_id, int(previous.get("generation", -1)), "replaced")
	var generation := int(_color_generations.get(target_id, 0)) + 1
	_color_generations[target_id] = generation
	var plugin: Node = _contract.game_feel_flow
	var effect_template: Variant = plugin.call("get_effect", "color")
	if not effect_template is GFFEffect or not plugin.has_method("play"):
		_record_color_lifecycle(target, generation, event_id, kind, "plugin_failure", "get_effect_unavailable", original_modulate, (target as CanvasItem).modulate, Color.WHITE, trace_id)
		return {}
	# Pass an isolated resource instance through the installed public play API. The bridge
	# owns exact per-target restoration, so GFF must not restore a transient overlap snapshot.
	var effect_instance := (effect_template as GFFEffect).duplicate(true) as GFFEffect
	effect_instance.restore_after_play = false
	var requested_color: Color = params_value.get("color", Color.WHITE) if params_value is Dictionary else Color.WHITE
	var play_args: Array = [effect_instance, target]
	if params_value is Dictionary and not params_value.is_empty():
		play_args.append(params_value.duplicate(true))
	var duration := float(params_value.get("duration", 0.16)) if params_value is Dictionary else 0.16
	var exit_callback := Callable(self, "_on_color_target_exiting").bind(target_id, generation)
	if not target.tree_exiting.is_connected(exit_callback):
		target.tree_exiting.connect(exit_callback)
	var trace := {
		"target_instance_id": target_id,
		"target_path": str(target.get_path()),
		"generation": generation,
		"event_id": event_id,
		"kind": kind,
		"original_modulate": original_modulate,
		"modulate_at_start": (target as CanvasItem).modulate,
		"requested_color": requested_color,
		"started_ms": Time.get_ticks_msec(),
		"prior_generation_replaced": int(previous.get("generation", 0)) if not previous.is_empty() else 0,
	}
	var output := {
		"target": target,
		"plugin": plugin,
		"target_id": target_id,
		"generation": generation,
		"original_modulate": original_modulate,
		"exit_callback": exit_callback,
		"event_id": event_id,
		"kind": kind,
		"requested_color": requested_color,
		"trace_id": trace_id,
		"trace": trace,
		"duration": duration,
	}
	_active_color_outputs[target_id] = output
	_record_color_lifecycle(target, generation, event_id, kind, "started", "plugin_call", original_modulate, (target as CanvasItem).modulate, requested_color, trace_id)
	output["effect"] = effect_instance
	_active_color_outputs[target_id] = output
	if _uses_async_gff_play(plugin):
		_invoke_color_effect.call_deferred(plugin, play_args, target_id, generation)
		_await_color_completion.call_deferred(target_id, generation, duration)
	else:
		var play_result: Variant = plugin.callv("play", play_args)
		if play_result is bool and not play_result:
			_finish_color_output(target_id, generation, "plugin_failure")
			return {}
		_finish_color_output(target_id, generation, "natural_completion")
	return output


func _uses_async_gff_play(plugin: Node) -> bool:
	if not is_instance_valid(plugin):
		return false
	var script := plugin.get_script() as Script
	return is_instance_valid(script) and script.resource_path == "res://addons/game_feel_flow/core/game_feel_flow.gd"


func _invoke_color_effect(plugin: Node, play_args: Array, target_id: int, generation: int) -> void:
	if not is_inside_tree() or not _active_color_outputs.has(target_id):
		return
	if int(_active_color_outputs[target_id].get("generation", -1)) != generation:
		return
	var play_result: Variant = await plugin.callv("play", play_args)
	if not _active_color_outputs.has(target_id) or int(_active_color_outputs[target_id].get("generation", -1)) != generation:
		return
	if play_result is bool and not play_result:
		_finish_color_output(target_id, generation, "plugin_failure")
	else:
		_finish_color_output(target_id, generation, "natural_completion")


func _cancel_color_for_target(target: Node, reason: String) -> void:
	if not is_instance_valid(target):
		return
	var target_id := target.get_instance_id()
	if not _active_color_outputs.has(target_id):
		return
	_finish_color_output(target_id, int(_active_color_outputs[target_id].get("generation", -1)), reason)


func _await_color_completion(target_id: int, generation: int, duration: float) -> void:
	if not is_inside_tree():
		return
	await get_tree().create_timer(maxf(duration, 0.0) + 0.15, true, false, true).timeout
	if not is_inside_tree():
		return
	_finish_color_output(target_id, generation, "completion_timeout")


func _on_color_target_exiting(target_id: int, generation: int) -> void:
	_finish_color_output(target_id, generation, "target_exit")


func _finish_color_output(target_id: int, generation: int, reason: String) -> void:
	if not _active_color_outputs.has(target_id):
		return
	var output: Dictionary = _active_color_outputs[target_id]
	if int(output.get("generation", -1)) != generation:
		return
	var target: Variant = output.get("target")
	var plugin: Variant = output.get("plugin")
	if reason != "natural_completion" and is_instance_valid(plugin) and plugin.has_method("stop") and is_instance_valid(target):
		plugin.call("stop", target)
	var original_modulate: Color = output.get("original_modulate", Color.WHITE)
	var final_modulate := Color.WHITE
	if is_instance_valid(target) and target is CanvasItem:
		(target as CanvasItem).modulate = original_modulate
		final_modulate = (target as CanvasItem).modulate
	var exit_callback: Callable = output.get("exit_callback", Callable())
	if is_instance_valid(target) and target.has_signal("tree_exiting") and target.tree_exiting.is_connected(exit_callback):
		target.tree_exiting.disconnect(exit_callback)
	_record_color_lifecycle(
		target if is_instance_valid(target) else null,
		generation,
		str(output.get("event_id", "")),
		str(output.get("kind", "")),
		"restored",
		reason,
		original_modulate,
		final_modulate,
		output.get("requested_color", Color.WHITE),
		str(output.get("trace_id", ""))
	)
	_active_color_outputs.erase(target_id)


func _record_color_lifecycle(
	target: Node,
	generation: int,
	event_id: String,
	kind: String,
	operation: String,
	reason: String,
	original_modulate: Color,
	final_modulate: Color,
	requested_color: Color,
	trace_id: String
) -> void:
	var record := {
		"target_instance_id": target.get_instance_id() if is_instance_valid(target) else 0,
		"target_path": str(target.get_path()) if is_instance_valid(target) and target.is_inside_tree() else "",
		"generation": generation,
		"event_id": event_id,
		"kind": kind,
		"operation": operation,
		"reason": reason,
		"original_modulate": original_modulate,
		"final_modulate": final_modulate,
		"requested_color": requested_color,
		"matches_original": final_modulate == original_modulate,
		"restored_exactly": operation == "restored" and final_modulate == original_modulate,
		"timestamp_ms": Time.get_ticks_msec(),
	}
	_color_lifecycle_diagnostics.append(record)
	while _color_lifecycle_diagnostics.size() > MAX_VISUAL_TRACE_EVENTS * 2:
		_color_lifecycle_diagnostics.pop_front()
	if not trace_id.is_empty():
		_update_visual_trace(trace_id, {"color_lifecycle": record})


func _begin_visual_trace(request: Dictionary) -> String:
	if not _visual_diagnostics_enabled:
		return ""
	_trace_sequence += 1
	var trace_id := "m23-r02-%d" % _trace_sequence
	var payload: Dictionary = request.get("payload", {})
	var target_value: Variant = payload.get("presentation_target", null)
	_visual_trace.append({
		"trace_id": trace_id,
		"event_id": str(request.get("event_id", "")),
		"semantic_sequence": int(request.get("sequence", 0)),
		"kind": str(request.get("kind", "")),
		"payload": _trace_safe_value(payload),
		"source_context": _trace_safe_value(request.get("source_context", {})),
		"trigger_timestamp_ms": Time.get_ticks_msec(),
		"trigger_fps": Engine.get_frames_per_second(),
		"frames_drawn_at_trigger": Engine.get_frames_drawn(),
		"mode": _presentation_mode,
		"stage": "semantic_received",
		"stages": ["semantic_received"],
		"target": _canvas_item_snapshot(target_value as Node) if typeof(target_value) == TYPE_OBJECT and is_instance_valid(target_value) and target_value is Node else {},
		"render_samples": [],
	})
	while _visual_trace.size() > MAX_VISUAL_TRACE_EVENTS:
		_visual_trace.pop_front()
	return trace_id


func _update_visual_trace(trace_id: String, patch: Dictionary) -> void:
	if trace_id.is_empty():
		return
	for index in range(_visual_trace.size() - 1, -1, -1):
		if str(_visual_trace[index].get("trace_id", "")) != trace_id:
			continue
		for key in patch:
			_visual_trace[index][key] = patch[key].duplicate(true) if patch[key] is Dictionary or patch[key] is Array else patch[key]
		var stage := str(patch.get("stage", ""))
		if not stage.is_empty():
			var stages: Array = _visual_trace[index].get("stages", [])
			if stages.is_empty() or str(stages[stages.size() - 1]) != stage:
				stages.append(stage)
			_visual_trace[index]["stages"] = stages
		return


func _sample_pending_visual_traces(process_delta_ms: float) -> void:
	var current_frame := Engine.get_frames_drawn()
	for index in range(_visual_trace.size() - 1, -1, -1):
		var entry: Dictionary = _visual_trace[index]
		if str(entry.get("stage", "")) != "awaiting_render":
			continue
		if current_frame <= int(entry.get("frames_drawn_at_dispatch", current_frame)):
			continue
		var samples: Array = entry.get("render_samples", [])
		if samples.size() >= MAX_RENDER_SAMPLES_PER_EVENT:
			entry["stage"] = "render_sample_complete"
			entry["stages"].append("render_sample_complete")
			continue
		var sample := {
			"frame": current_frame,
			"elapsed_ms": Time.get_ticks_msec() - int(entry.get("trigger_timestamp_ms", Time.get_ticks_msec())),
			"process_delta_ms": process_delta_ms,
			"fps": Engine.get_frames_per_second(),
			"target": _target_live_sample(entry),
			"spark": _spark_live_sample(int(entry.get("spark_call", {}).get("emitter_instance_id", 0))),
		}
		samples.append(sample)
		entry["render_samples"] = samples
		entry["rendered_frame_count"] = current_frame - int(entry.get("frames_drawn_at_dispatch", current_frame))
		if int(sample["spark"].get("visible_particle_count", 0)) > 0:
			entry["active_drawn_frame_count"] = int(entry.get("active_drawn_frame_count", 0)) + 1
			entry["first_visible_frame"] = int(entry.get("first_visible_frame", current_frame))
			entry["last_visible_frame"] = current_frame
			entry["last_visible_elapsed_ms"] = int(sample["elapsed_ms"])
		var spark_options: Dictionary = entry.get("spark_call", {}).get("options", {})
		var gff_params: Dictionary = entry.get("gff_call", {}).get("params", {})
		var observation_ms := int(ceil(maxf(float(spark_options.get("lifetime", 0.0)), float(gff_params.get("duration", 0.0))) * 1000.0)) + 50
		var elapsed_ms := int(sample["elapsed_ms"])
		if elapsed_ms >= observation_ms:
			entry["stage"] = "render_sample_complete"
			entry["stages"].append("render_sample_complete")
			entry["active_drawn_frame_count"] = int(entry.get("active_drawn_frame_count", 0))
			entry["observation_window_ms"] = observation_ms
		elif samples.size() >= MAX_RENDER_SAMPLES_PER_EVENT:
			entry["stage"] = "render_sample_capped"
			entry["stages"].append("render_sample_capped")
		_visual_trace[index] = entry


func _target_live_sample(entry: Dictionary) -> Dictionary:
	var target_path := str(entry.get("target", {}).get("path", ""))
	if target_path.is_empty() or not is_inside_tree():
		return {}
	var target := get_node_or_null(NodePath(target_path))
	if not is_instance_valid(target):
		return {"valid": false}
	var result := {"valid": true, "visible_in_tree": (target as CanvasItem).is_visible_in_tree() if target is CanvasItem else false}
	if target is CanvasItem:
		var item := target as CanvasItem
		result["screen_position"] = item.get_global_transform_with_canvas().origin
		result["modulate"] = item.modulate
		result["self_modulate"] = item.self_modulate
		if item is Node2D:
			result["scale"] = (item as Node2D).scale
	return result


func _spark_live_sample(emitter_id: int) -> Dictionary:
	if emitter_id <= 0:
		return {"emitter_found": false}
	var pool := get_node_or_null("/root/Spark/SaltmireSparkPool")
	if not is_instance_valid(pool):
		return {"emitter_found": false, "pool_found": false}
	for emitter in pool.get_children():
		if emitter.get_instance_id() != emitter_id or not emitter is CanvasItem:
			continue
		var options: Variant = emitter.get("_opts")
		var parts: Variant = emitter.get("_parts")
		var active_particle_count := 0
		var visible_particle_count := 0
		var max_draw_radius := 0.0
		if parts is Array and options is Dictionary:
			var size_start := float(options.get("size", 0.0))
			var size_end := float(options.get("size_end", 0.0))
			var end_color: Color = options.get("color2", Color.WHITE)
			for part_value in parts:
				if not part_value is Dictionary:
					continue
				var part: Dictionary = part_value
				var age := float(part.get("age", 0.0))
				var life := maxf(float(part.get("life", 0.0)), 0.001)
				if age >= life:
					continue
				active_particle_count += 1
				var progress := clampf(age / life, 0.0, 1.0)
				var radius := lerpf(size_start, size_end, progress)
				var start_color: Color = part.get("col", Color.WHITE)
				var particle_color := start_color.lerp(end_color, progress)
				if radius > 0.15 and particle_color.a > 0.01:
					visible_particle_count += 1
					max_draw_radius = maxf(max_draw_radius, radius)
		var sample := {
			"emitter_found": true,
			"path": str(emitter.get_path()),
			"visible_in_tree": (emitter as CanvasItem).is_visible_in_tree(),
			"screen_position": (emitter as CanvasItem).get_global_transform_with_canvas().origin,
			"global_position": (emitter as Node2D).global_position,
			"z_index": (emitter as CanvasItem).z_index,
			"canvas_layer": _canvas_layer_snapshot(emitter),
			"part_count": parts.size() if parts is Array else -1,
			"active_particle_count": active_particle_count,
			"visible_particle_count": visible_particle_count,
			"max_draw_radius": max_draw_radius,
			"emitter_age_ms": float(emitter.get("_age")) * 1000.0,
			"size": options.get("size", -1.0) if options is Dictionary else -1.0,
			"size_end": options.get("size_end", -1.0) if options is Dictionary else -1.0,
			"color": options.get("color", Color.WHITE) if options is Dictionary else Color.WHITE,
			"color2": options.get("color2", Color.WHITE) if options is Dictionary else Color.WHITE,
			"modulate": (emitter as CanvasItem).modulate,
		}
		return sample
	return {"emitter_found": false, "pool_found": true}


func _canvas_item_snapshot(node: Node) -> Dictionary:
	if not is_instance_valid(node) or not node is CanvasItem:
		return {"valid": is_instance_valid(node), "path": str(node.get_path()) if is_instance_valid(node) else "", "canvas_item": false}
	var item := node as CanvasItem
	var result := {
		"valid": true,
		"canvas_item": true,
		"path": str(node.get_path()),
		"class": node.get_class(),
		"visible_in_tree": item.is_visible_in_tree(),
		"global_position": _target_global_position(node),
		"screen_position": item.get_global_transform_with_canvas().origin,
		"z_index": item.z_index,
		"modulate": item.modulate,
		"self_modulate": item.self_modulate,
		"scale": item.scale if item is Node2D else Vector2.ONE,
		"canvas_layer": _canvas_layer_snapshot(node),
		"clipping_ancestors": _clipping_ancestors(node),
	}
	return result


func _canvas_layer_snapshot(node: Node) -> Dictionary:
	var ancestor := node
	while is_instance_valid(ancestor):
		if ancestor is CanvasLayer:
			var layer := ancestor as CanvasLayer
			return {"path": str(layer.get_path()), "layer": layer.layer, "visible": layer.visible, "follow_viewport_enabled": layer.follow_viewport_enabled, "transform": layer.transform}
		ancestor = ancestor.get_parent()
	return {"path": "default_world_canvas", "layer": 0, "visible": true}


func _clipping_ancestors(node: Node) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var ancestor := node.get_parent()
	while is_instance_valid(ancestor):
		if ancestor is Control and (ancestor as Control).clip_contents:
			result.append({"path": str(ancestor.get_path()), "clip_contents": true, "visible": (ancestor as Control).is_visible_in_tree()})
		ancestor = ancestor.get_parent()
	return result


func _find_new_spark_emitter_id(pool: Node, ids_before: Dictionary) -> int:
	if not is_instance_valid(pool):
		return 0
	for emitter in pool.get_children():
		if not ids_before.has(emitter.get_instance_id()):
			return emitter.get_instance_id()
	return 0


func _gff_active_effect_count() -> int:
	if _contract == null or not is_instance_valid(_contract.game_feel_flow):
		return -1
	var stack: Variant = _contract.game_feel_flow.get("_effect_stack")
	if not is_instance_valid(stack):
		return -1
	var active: Variant = stack.get("_active_effects")
	return active.size() if active is Dictionary else -1


func _trace_safe_value(value: Variant) -> Variant:
	if typeof(value) == TYPE_OBJECT:
		if not is_instance_valid(value):
			return {"invalid_object": true}
	if value is Node:
		return {"path": str(value.get_path()), "class": value.get_class(), "instance_id": value.get_instance_id()}
	if value is Dictionary:
		var copied: Dictionary = {}
		for key in value:
			copied[str(key)] = _trace_safe_value(value[key])
		return copied
	if value is Array:
		var copied: Array = []
		for item in value:
			copied.append(_trace_safe_value(item))
		return copied
	return value


func _build_spark_options(preset_name: String, overrides_value: Variant, kind: String, mode: String, chain: int) -> Dictionary:
	if not overrides_value is Dictionary or _contract == null or not _contract.has_spark() or _policy == null:
		return {}
	var policy_budget: Dictionary = _policy.get_spark_budget(kind, mode, chain)
	if policy_budget.is_empty() or not policy_budget.get("presets", []).has(preset_name):
		return {}
	var preset_table: Variant = _contract.spark.get("presets")
	var base: Variant = _contract.spark.get("base")
	if not preset_table is Dictionary or not base is Dictionary:
		return {}
	var merged: Dictionary = base.duplicate(true)
	var preset: Variant = preset_table.get(preset_name, null)
	if not preset is Dictionary:
		return {}
	for key in preset:
		merged[key] = preset[key]
	for key in overrides_value:
		if not POLICY_SCRIPT.SAFE_SPARK_OPTIONS.has(str(key)):
			return {}
		merged[key] = overrides_value[key]
	for required in ["amount", "lifetime", "speed"]:
		if not overrides_value.has(required):
			return {}
	var amount_value: Variant = merged.get("amount", -1)
	var lifetime_value: Variant = merged.get("lifetime", -1.0)
	var speed_value: Variant = merged.get("speed", -1.0)
	if not _is_finite_number(amount_value) or not is_equal_approx(float(amount_value), float(int(amount_value))) or int(amount_value) < 0 or int(amount_value) > int(policy_budget.max_amount):
		return {}
	if not _is_finite_number(lifetime_value) or float(lifetime_value) < 0.0 or float(lifetime_value) > float(policy_budget.max_lifetime):
		return {}
	if not _is_finite_number(speed_value) or float(speed_value) < 0.0 or float(speed_value) > float(policy_budget.max_speed):
		return {}
	return merged


func _prune_expired_spark_outputs() -> void:
	var now := Time.get_ticks_msec()
	for index in range(_active_spark_outputs.size() - 1, -1, -1):
		if now >= int(_active_spark_outputs[index].get("expires_at_ms", 0)):
			_active_spark_outputs.remove_at(index)


func _prune_expired_gff_outputs() -> void:
	var now := Time.get_ticks_msec()
	for index in range(_active_gff_outputs.size() - 1, -1, -1):
		if now >= int(_active_gff_outputs[index].get("expires_at_ms", 0)):
			_active_gff_outputs.remove_at(index)


func _active_spark_particle_count() -> int:
	var pool := get_node_or_null("/root/Spark/SaltmireSparkPool")
	var live_total := 0
	if is_instance_valid(pool):
		for emitter in pool.get_children():
			var parts: Variant = emitter.get("_parts")
			if not parts is Array:
				continue
			for particle in parts:
				if particle is Dictionary and float(particle.get("age", 0.0)) < float(particle.get("life", 0.0)):
					live_total += 1
	var total := 0
	for output in _active_spark_outputs:
		total += int(output.get("amount", 0))
	# The bridge estimate also covers accepted outputs when the plugin pool is
	# present but has not materialized particles yet (and test/plugin adapters
	# that record calls without constructing emitters). Taking the larger count
	# avoids double-counting real outputs while keeping the 48-particle ceiling
	# fail-closed during that gap.
	return maxi(live_total, total)


func _valid_request(request: Dictionary) -> bool:
	return FeedbackService.SEMANTIC_KINDS.has(str(request.get("kind", "")))


func _is_presentation_target(target: Node, fixture: bool) -> bool:
	if not is_instance_valid(target):
		return false
	if fixture:
		return target.is_in_group(FIXTURE_TARGET_GROUP) and not target is CollisionObject2D and not target is Camera2D
	return target.is_in_group("presentation_effect_target") and not target is CollisionObject2D and not target is Camera2D


func _target_global_position(target: Node) -> Vector2:
	if target is Node2D:
		return (target as Node2D).global_position
	if target is Control:
		return (target as Control).global_position
	return Vector2.ZERO


func _is_finite_number(value: Variant) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and is_finite(float(value))


func _no_op(reason: String) -> bool:
	no_op_count += 1
	if _diagnostics.size() < MAX_DIAGNOSTICS:
		_diagnostics.append(reason)
	return false
