class_name PresentationFeedbackBridge
extends Node

## Sole plugin-call boundary. M22 keeps normal production dispatch disabled;
## only isolated fixture requests can execute the plugin calls below.

const CONTRACT_SCRIPT := preload("res://scripts/presentation_plugin_contract.gd")
const POLICY_SCRIPT := preload("res://scripts/presentation_effect_policy.gd")
const MAX_DIAGNOSTICS := 16
const MAX_ACTIVE_GFF_OUTPUTS := 128
const FIXTURE_TARGET_GROUP := "m22_test_presentation_target"

var _contract: PresentationPluginContract
var _policy
var _feedback_service: Node
var _production_dispatch_enabled := false
var _presentation_mode := "FULL"
var _diagnostics: Array[String] = []
var _active_gff_outputs: Array[Dictionary] = []
var _active_spark_outputs: Array[Dictionary] = []
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
	if _contract == null:
		_contract = CONTRACT_SCRIPT.new()
	return _contract.refresh_from_tree(capability_root)


func get_listener_count() -> int:
	if not is_instance_valid(_feedback_service) or not _feedback_service.has_signal("semantic_requested"):
		return 0
	return _feedback_service.semantic_requested.get_connections().size()


func get_diagnostics() -> Array[String]:
	return _diagnostics.duplicate(true)


func set_production_dispatch_enabled(enabled: bool) -> void:
	_production_dispatch_enabled = enabled
	if not enabled:
		cancel_presentation()


func set_presentation_mode(mode: String) -> bool:
	if not ["FULL", "REDUCED"].has(mode):
		return false
	_presentation_mode = mode
	return true


func cancel_presentation() -> void:
	for output in _active_gff_outputs:
		var plugin: Variant = output.get("plugin")
		var target: Variant = output.get("target")
		if is_instance_valid(plugin) and plugin.has_method("stop") and is_instance_valid(target):
			plugin.call("stop", target)
	_active_gff_outputs.clear()
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
	if not _production_dispatch_enabled:
		return
	var kind := str(request.get("kind", ""))
	if not ["cocktail_launch", "table_contact", "merge", "score_mastery"].has(kind):
		return
	var payload: Dictionary = request.get("payload", {})
	var target_value: Variant = payload.get("presentation_target", null)
	if not target_value is Node or not is_instance_valid(target_value):
		_no_op("production_target_missing")
		return
	var mode := _presentation_mode
	var plan := _micro_plan(kind, mode)
	if kind == "merge":
		plan = _merge_plan(mode, payload)
	elif kind == "score_mastery":
		plan = _score_milestone_plan(mode)
	_dispatch_plan(request, target_value as Node, plan, false)


func _micro_plan(kind: String, mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	var amount := 0
	var lifetime := 0.0
	var speed := 0.0
	var preset := ""
	var effect := "color"
	if not reduced:
		if kind == "cocktail_launch":
			amount = 4
			lifetime = 0.14
			speed = 45.0
			preset = "hit"
			effect = "punch_scale"
		else:
			amount = 5
			lifetime = 0.16
			speed = 40.0
			preset = "hit"
	var overrides := {"amount": amount, "lifetime": lifetime, "speed": speed}
	var duration := 0.10 if reduced else (0.14 if kind == "cocktail_launch" else 0.16)
	var result := {"mode": mode, "gff_effect": effect, "gff_params": {"duration": duration}}
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
	if not reduced:
		if chain >= 5:
			amount = 18
			lifetime = 0.35
			speed = 105.0
			duration = 0.25
		elif chain >= 3:
			amount = 10
			lifetime = 0.30
			speed = 90.0
			duration = 0.22
		else:
			amount = 10
			lifetime = 0.28
			speed = 90.0
			duration = 0.22
	var result := {
		"mode": mode,
		"gff_effect": "color" if reduced else "punch_scale",
		"gff_params": {"duration": duration},
	}
	if amount > 0:
		result["spark_preset"] = "hit"
		result["spark_overrides"] = {"amount": amount, "lifetime": lifetime, "speed": speed}
	return result


func _score_milestone_plan(mode: String) -> Dictionary:
	var reduced := mode == "REDUCED"
	return {
		"mode": mode,
		"gff_effect": "color" if reduced else "punch_scale",
		"gff_params": {"duration": 0.10 if reduced else 0.20},
	}


func _dispatch_plan(request: Dictionary, target: Node, plan: Dictionary, fixture: bool) -> bool:
	if not _valid_request(request):
		return _no_op("unknown_semantic_kind")
	if not _is_presentation_target(target, fixture):
		return _no_op("target_not_allowlisted")
	if _policy == null:
		_policy = POLICY_SCRIPT.new()
	var mode := str(plan.get("mode", "FULL"))
	_prune_expired_gff_outputs()
	_prune_expired_spark_outputs()
	var validation_plan := plan.duplicate(true)
	validation_plan["active_live_particles"] = _active_spark_particle_count()
	var policy_result: Dictionary = _policy.validate_dispatch(request, mode, validation_plan)
	if not bool(policy_result.get("ok", false)):
		return _no_op("policy:%s" % str(policy_result.get("reason", "invalid")))
	var effect_name := str(plan.get("gff_effect", ""))
	var gff_params_value: Variant = plan.get("gff_params", {})
	var spark_preset := str(plan.get("spark_preset", ""))
	var has_effect := not effect_name.is_empty()
	var has_spark := not spark_preset.is_empty()
	if not has_effect and not has_spark:
		return _no_op("unknown_mapping")
	if has_effect and (_contract == null or not _contract.has_game_feel_flow_effect(effect_name)):
		return _no_op("gff_effect_unavailable:%s" % effect_name)
	var spark_options: Dictionary = {}
	if has_spark:
		if _contract == null or not _contract.has_spark_preset(spark_preset):
			return _no_op("spark_preset_unavailable:%s" % spark_preset)
		spark_options = _build_spark_options(spark_preset, plan.get("spark_overrides", {}), str(request.kind), mode, int(request.get("payload", {}).get("chain", 1)))
		if spark_options.is_empty():
			return _no_op("spark_overrides_invalid")
	# Preflight all requested components before invoking either plugin.
	if has_effect:
		if _active_gff_outputs.size() >= MAX_ACTIVE_GFF_OUTPUTS:
			return _no_op("gff_output_capacity")
		var gff_args: Array = [effect_name, target]
		if gff_params_value is Dictionary and not gff_params_value.is_empty():
			gff_args.append(gff_params_value.duplicate(true))
		var result: Variant = _contract.game_feel_flow.callv("play", gff_args)
		if result is bool and not result:
			return _no_op("gff_call_failed")
		var effect_duration := float(gff_params_value.get("duration", 0.30)) if gff_params_value is Dictionary else 0.30
		_active_gff_outputs.append({
			"plugin": _contract.game_feel_flow,
			"target": target,
			"expires_at_ms": Time.get_ticks_msec() + int(ceil(maxf(effect_duration, 0.25) * 1000.0)),
		})
	if has_spark:
		var position := _target_global_position(target)
		var result: Variant = _contract.spark.callv("burst", [position, spark_options])
		if result is bool and not result:
			cancel_presentation()
			return _no_op("spark_call_failed")
		_active_spark_outputs.append({
			"plugin": _contract.spark,
			"amount": int(spark_options.get("amount", 0)),
			"expires_at_ms": Time.get_ticks_msec() + int(ceil(float(spark_options.get("lifetime", 0.0)) * (1.0 + maxf(float(spark_options.get("lifetime_rand", 0.0)), 0.0)) * 1000.0)),
		})
	dispatch_count += 1
	return true


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
	var total := 0
	for output in _active_spark_outputs:
		total += int(output.get("amount", 0))
	return total


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
